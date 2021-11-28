-- Instructions:
-- The Tx pin of the Raspberry Pi will first transmit the instructions to the FSM Controller.
-- This instruction will contain 24 bits, and the FSM controller will handle what signals will be set
-- depending on the active mode specified.
--
-- Each byte sent will then be concatenated to a register with a width of (23 downto 0)
-- Then, the FSM controller decodes the 24-bit data
--
-- Drive Mode Example:
-- If drive_mode = '1' and 3 bytes are transmitted to the FPGA -> 1111 1111 1110 0110 0000 0001
-- The Raspberry Pi will send this instruction sequentially as such:
-- GPIO.output(drive_mode_pin, 1)
-- ser.write(b'\x01') [0000 0001]
-- ser.write(b'\xE6') [1110 0110]
-- ser.write(b'\xFF') [1111 1111]
--
-- First Upper Byte: PWM Enable and Motor Direction: 11111111
--      The upper 4 bits enable all the PWM outputs for the 4 DC motors (in this case, all of them are on)
--      The lower 4 bits set the direction for the 4 DC motors (in this case, all forward)
-- Second Middle Byte: The duty cycle amount: 11100110
--      In this case, since 11100110 = 230 in decimal, about 90% duty cycle is set for the four motors
--      The range is 0 to 255
-- Third Lower Byte: Sets the active mode.
--      Modes Available:
--          Drive Mode:             0000 0001
--          Spatial Filter Mode:    0000 0010
--          Sensor Mode:            0000 0100
--
-- Spatial Filter Mode Example:
-- If spatial_filter_mode = '1' and 3 bytes are transmitted to the FPGA -> 0000 0000 0000 0001 0000 0010
-- The Raspberry Pi will send this instruction sequentially as such:
-- GPIO.output(spatial_filter_mode, 1)
-- ser.write(b'\x02') [0000 0010]
-- ser.write(b'\x01') [0000 0001]
-- ser.write(b'\x00') [0000 0000]
--
-- First Upper and Second Middle Byte: Reserved for Spatial Filter Index
--      Example: 0000 0001 -> Chooses the Laplacian Filter
--      Bits Enabled for Filters:
--      0000 0000: Average Filter
--      0000 0001: Laplacian Filter
--      0000 0010: Threshold Filter
--      0000 0011: Image Inversion
-- Third Lower Byte: Sets the active mode. See above.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity top_fsm_controller is
    generic(
        data_width:                         integer := 8;
        addr_width:                         integer := 18;
        filters_width:                      integer := 8;
        num_instruction_bytes:              integer := 3;
        instruction_reg_width:              integer := 24;
        num_elements_input:                 integer := 242_004;
        num_elements_output:                integer := 240_000;
        g_clk_cycles_bit:                   integer := 135 -- Baud rate set to 921600
    );
    Port (
        i_clk:                              in std_logic;
        i_reset:                            in std_logic;
        i_data_in_rx:                       in std_logic;
        write_enable_input_bram:            in std_logic;
        read_enable_input_bram:             in std_logic;
        write_enable_output_bram:           in std_logic;
        read_enable_output_bram:            in std_logic;
        i_rx_instruction_active:            in std_logic;
        o_filter_done:                      out std_logic
    );
end top_fsm_controller;

architecture Behavioral of top_fsm_controller is

component uart_rx_for_fsm is
    generic (
        g_clk_cycles_bit:                   integer := 135;
        data_width:                         integer := 8;
        num_instruction_bytes:              integer := 3;
        instruction_reg_width:              integer := 24
    );
    port (
        i_clk:                              in std_logic;
        i_reset:                            in std_logic;
        i_data_in_rx:                       in std_logic;
        i_rx_instruction_active:            in std_logic;
        o_data_out_byte_rx:                 out std_logic_vector(data_width-1 downto 0);
        o_rx_dv:                            out std_logic;
        rx_num_counter:                     out integer;
        o_rx_instruction_done:              out std_logic;
        o_data_out_byte_rx_instruction:     out std_logic_vector(instruction_reg_width-1 downto 0)
    );
end component uart_rx_for_fsm;

type state_type is (
    IDLE,
    DRIVE_MODE_ACTIVE,
    SPATIAL_FILTER_ACTIVE,
    DONE
    );

signal current_state, next_state:           state_type;
signal filter_select:                       std_logic_vector(filters_width-1 downto 0);
signal start_filtering:                     std_logic;
signal filter_done_sig:                     std_logic;

-- Signals for UART Rx (Instruction Handler)
signal data_out_byte_rx_instruction_reg:    std_logic_vector(instruction_reg_width-1 downto 0);
signal data_out_byte_rx_reg:                std_logic_vector(data_width-1 downto 0);
signal instruction_dv_flag:                 std_logic;
signal rx_num_counter:                      integer := 0;
signal o_rx_instruction_done:               std_logic;

-- Registers for Decoding Instruction Bytes
signal active_mode_reg:                     std_logic_vector(data_width-1 downto 0) := (others => '0');
signal filter_select_reg:                   std_logic_vector(filters_width-1 downto 0) := (others => '0');
signal duty_cycle_reg:                      std_logic_vector(data_width-1 downto 0) := (others => '0');
signal PWM_and_motor_direction_reg:         std_logic_vector(data_width-1 downto 0) := (others => '0');
signal filter_mode:                         std_logic;
signal drive_mode:                          std_logic;

-- Signals for Motor Controller

begin

uart_rx_for_fsm_instance: uart_rx_for_fsm
    generic map(
        g_clk_cycles_bit => g_clk_cycles_bit,
        data_width => data_width,
        num_instruction_bytes => num_instruction_bytes
    )
    port map(
        i_clk => i_clk,
        i_reset => i_reset,
        i_data_in_rx => i_data_in_rx,
        i_rx_instruction_active => i_rx_instruction_active,
        o_data_out_byte_rx => data_out_byte_rx_reg,
        o_rx_dv => instruction_dv_flag,
        rx_num_counter => rx_num_counter,
        o_rx_instruction_done => o_rx_instruction_done,
        o_data_out_byte_rx_instruction => data_out_byte_rx_instruction_reg
    );

current_state_proc: process(i_clk, i_reset)
begin
    if (i_reset = '1') then
        current_state <= IDLE;
    elsif (rising_edge(i_clk)) then
        current_state <= next_state;
    end if;
end process current_state_proc;

next_state_proc: process(current_state, drive_mode, filter_mode, i_rx_instruction_active)
begin
    case (current_state) is
        when IDLE =>
            start_filtering <= '0';
            if (o_rx_instruction_done = '1') then
                if (drive_mode = '1' and filter_mode = '0' and i_rx_instruction_active = '0') then
                    next_state <= DRIVE_MODE_ACTIVE;
                elsif (filter_mode = '1' and drive_mode = '0' and i_rx_instruction_active = '0') then
                    next_state <= SPATIAL_FILTER_ACTIVE;
                else
                    next_state <= IDLE;
                end if;
            else
                next_state <= IDLE;
            end if;
        
        when DRIVE_MODE_ACTIVE =>
            if (drive_mode = '1') then
                next_state <= DRIVE_MODE_ACTIVE;
            else
                next_state <= IDLE;
            end if;
        
        when SPATIAL_FILTER_ACTIVE =>
            if (filter_mode = '1') then
                start_filtering <= '1';
                if (filter_done_sig = '1') then
                    next_state <= DONE;
                    start_filtering <= '0';
                else
                    next_state <= SPATIAL_FILTER_ACTIVE;
                end if;
            else
                next_state <= IDLE;
            end if;
        
        when DONE =>
            next_state <= IDLE;
    end case;
end process next_state_proc;

active_mode_decoder_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            active_mode_reg <= (others => '0');
            filter_mode <= '0';
            drive_mode <= '0';
        else
            if (o_rx_instruction_done = '1' and i_rx_instruction_active = '0') then
                active_mode_reg <= data_out_byte_rx_instruction_reg(7 downto 0);
                filter_mode <= active_mode_reg(1);
                drive_mode <= active_mode_reg(0);
            end if;
        end if;
    end if;
end process active_mode_decoder_proc;

filter_select_decoder_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            filter_select_reg <= (others => '0');
            filter_select <= (others => '0');
        else
            if (filter_mode = '1') then
                filter_select_reg <= data_out_byte_rx_instruction_reg(15 downto 8);
                filter_select <= filter_select_reg;
            else
                filter_select_reg <= (others => '0');
            end if;
        end if;
    end if;
end process filter_select_decoder_proc;

o_filter_done <= filter_done_sig;

end Behavioral;
