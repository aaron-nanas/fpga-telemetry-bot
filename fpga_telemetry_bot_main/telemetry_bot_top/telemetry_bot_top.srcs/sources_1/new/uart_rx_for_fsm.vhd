-- Author: Aaron Nanas
-- File: uart_rx_for_fsm.vhd
-- Purpose:
--      Receives 3 bytes of data from the Raspberry Pi first, then creates a 24-bit instruction register 
--      The first lower byte determines the active mode
--
-- For this UART Rx, the config is:
-- One start bit
-- One stop bit
-- No parity bit
-- Receives incoming 8 bits of serial data
--
-- The number of clocks needed for a given baud rate can be calculated as follows:
-- (Clock Frequency / Baud Rate)
-- Example:
--      (125 MHz / 921600) = 135

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
 
entity uart_rx_for_fsm is
    generic (
        g_clk_cycles_bit:           integer := 135;
        data_width:                 integer := 8;
        num_instruction_bytes:      integer := 3;
        instruction_reg_width:      integer := 24
    );
    port (
        i_clk:                              in std_logic;
        i_reset:                            in std_logic;
        i_data_in_rx:                       in std_logic;
        rx_instruction_active:              in std_logic;
        o_data_out_byte_rx:                 out std_logic_vector(data_width-1 downto 0);
        o_rx_dv:                            out std_logic;
        rx_num_counter:                     out integer;
        o_rx_instruction_done:              out std_logic;
        o_data_out_byte_rx_instruction:     out std_logic_vector(instruction_reg_width-1 downto 0);
        o_led:                              out std_logic_vector(3 downto 0)
    );
end uart_rx_for_fsm;

architecture Behavioral of uart_rx_for_fsm is
    type t_state_type is (
        Idle,
        Rx_Start_Bit,
        Rx_Data,
        Rx_Stop_Bit,
        Rx_Byte_Fully_Received,
        Rx_Update_Byte_Count,
        Rx_Instruction_Done
    );
    
    constant c_baud_count_limit:                    integer := (g_clk_cycles_bit-1)/2;
    signal Rx_Instruction_UART_State:               t_state_type := Idle;
    signal s_baud_counter:                          integer range 0 to (g_clk_cycles_bit-1) := 0;
    signal s_rx_bit_counter:                        integer range 0 to (data_width-1) := 0;
    signal s_data_out_byte_rx:                      std_logic_vector(data_width-1 downto 0) := (others => '0');
    signal s_data_in_rx:                            std_logic;
    signal s_data_in_reg:                           std_logic;
    signal rx_num_counter_reg:                      integer := 0;
    signal data_out_byte_rx_instruction_reg:        std_logic_vector(instruction_reg_width-1 downto 0) := (others => '0');

begin

proc_incoming_data: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        s_data_in_reg <= i_data_in_rx;
        s_data_in_rx <= s_data_in_reg;
    end if;  
end process proc_incoming_data;

proc_Rx: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            rx_num_counter_reg <= 0;
            data_out_byte_rx_instruction_reg <= (others => '0');
            Rx_Instruction_UART_State <= Idle;
            o_led <= "0000";
        else
            if (rx_instruction_active = '1') then
                case (Rx_Instruction_UART_State) is
                    -- Wait for start bit to trigger the FSM
                    when Idle =>
                        o_led <= "0001";
                        s_baud_counter <= 0;
                        s_rx_bit_counter <= 0;
                        o_rx_dv <= '0';
                        o_rx_instruction_done <= '0';
                        s_data_out_byte_rx <= (others => '0');
                        
                        if (s_data_in_rx = '0') then
                            Rx_Instruction_UART_State <= Rx_Start_Bit;
                        else
                            Rx_Instruction_UART_State <= Idle;
                        end if;
                    
                    -- Indicates the start of incoming byte
                    when Rx_Start_Bit =>
                        if (s_baud_counter = c_baud_count_limit) then
                            if (s_data_in_rx = '0') then
                                s_baud_counter <= 0; -- Reset the counter when there is an incoming data stream
                                Rx_Instruction_UART_State <= Rx_Data;
                            else
                                Rx_Instruction_UART_State <= Idle;
                            end if;
                        else
                            s_baud_counter <= s_baud_counter + 1;
                            Rx_Instruction_UART_State <= Rx_Start_Bit; -- Remain in current state if counter has not reached baud count limit yet
                        end if;
                    
                    -- Handle incoming serial data and store as a byte
                    when Rx_Data =>
                        if (s_baud_counter < g_clk_cycles_bit-1) then
                            s_baud_counter <= s_baud_counter + 1;
                            Rx_Instruction_UART_State <= Rx_Data;
                        else
                            s_baud_counter <= 0;
                            s_data_out_byte_rx(s_rx_bit_counter) <= s_data_in_rx;
                            
                            if (s_rx_bit_counter < (data_width-1)) then
                                s_rx_bit_counter <= s_rx_bit_counter + 1;
                                Rx_Instruction_UART_State <= Rx_Data;
                            else
                                s_rx_bit_counter <= 0;
                                Rx_Instruction_UART_State <= Rx_Stop_Bit;
                            end if;
                        end if;
                    
                    -- Indicates the end of incoming byte
                    when Rx_Stop_Bit =>
                        if (s_baud_counter < g_clk_cycles_bit-1) then
                            s_baud_counter <= s_baud_counter + 1;
                            Rx_Instruction_UART_State <= Rx_Stop_Bit;    
                        else
                            s_baud_counter <= 0;
                            o_rx_dv <= '1'; -- Indicates that data has been fully received
                            Rx_Instruction_UART_State <= Rx_Byte_Fully_Received;
                        end if;
                    
                    -- Indicates when a byte has been fully received
                    when Rx_Byte_Fully_Received =>
                        Rx_Instruction_UART_State <= Rx_Update_Byte_Count;
                        o_rx_dv <= '0';
        
                    -- Updates the Rx byte count and stores the instruction bytes into a 24-bit register when it has received 3 bytes of data from the Raspberry Pi
                    when Rx_Update_Byte_Count =>
                        if (rx_num_counter_reg < num_instruction_bytes) then
                            rx_num_counter_reg <= rx_num_counter_reg + 1;
                            Rx_Instruction_UART_State <= Idle;
                            if (rx_num_counter_reg = 0) then
                                data_out_byte_rx_instruction_reg(7 downto 0) <= s_data_out_byte_rx;
                            elsif (rx_num_counter_reg = 1) then
                                data_out_byte_rx_instruction_reg(15 downto 8) <= s_data_out_byte_rx;
                            elsif (rx_num_counter_reg = 2) then
                                data_out_byte_rx_instruction_reg(23 downto 16) <= s_data_out_byte_rx;
                            end if;
                        else
                            rx_num_counter_reg <= rx_num_counter_reg;
                            Rx_Instruction_UART_State <= Rx_Instruction_Done;
                        end if;
                    when Rx_Instruction_Done =>
                        o_led <= "1111";
                        o_rx_instruction_done <= '1';
                        Rx_Instruction_UART_State <= Rx_Instruction_Done;
                    when others =>
                        Rx_Instruction_UART_State <= Idle;
                end case;
            end if;
        end if;
    end if;
end process proc_Rx;

rx_num_counter <= rx_num_counter_reg;
o_data_out_byte_rx <= s_data_out_byte_rx;
o_data_out_byte_rx_instruction <= data_out_byte_rx_instruction_reg;

end Behavioral;