-- Author: Aaron Nanas
-- File: top_level_controller.vhd
-- Purpose:
--      Interfaces the following controllers:
--          - Spatial Filter FSM Controller
--          - Quad DC Motor Controller
--          - Servo Controller
--      Initially receives 3 bytes from the Raspberry Pi via UART, which is turned into a 24-bit instruction
--      Processes the 24-bit instruction received from the Raspberry Pi and applies enable signals accordingly
--
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

entity top_level_controller is
    generic(
        data_width:                 integer := 8;
        addr_width:                 integer := 18;
        filters_width:              integer := 8;
        num_elements_input:         integer := 242_004;
        num_elements_output:        integer := 240_000;
        num_instruction_bytes:      integer := 3;
        instruction_reg_width:      integer := 24;
        num_motors:                 integer := 4;
        clk_freq:                   integer := 125;
        g_clk_cycles_bit:           integer := 135; -- Baud rate set to 921600
        main_clk_freq:              integer := 125000000;   -- 125 MHz Zybo Clock Frequency
        servo_refresh_rate:         integer := 50;          -- 50 Hz (20 ms) required for servo refresh rate; Typically a servo gets updated every 20 ms with a pulse between 1 ms and 2 ms
        servo_max_step_count:       positive := 10;         -- Maximum number of steps; incrementing 10 will turn the servo 180 to degrees and back to original position when decrementing
        min_PWM_in_us:              integer := 575;         -- Minimum PWM signal range from HS-311 datasheet
        max_PWM_in_us:              integer := 2460         -- Maximum PWM signal range from HS-311 datasheet
    );
    Port (
        i_clk:                      in std_logic;
        i_reset:                    in std_logic;
        i_data_in_rx:               in std_logic;
        write_enable_input_bram:    in std_logic;
        read_enable_input_bram:     in std_logic;
        write_enable_output_bram:   in std_logic;
        read_enable_output_bram:    in std_logic;
        rx_instruction_active:      in std_logic;
        sensor_pulse:               in std_logic;
        sensor_enable:              out std_logic;
        o_tx_serial_data:           out std_logic;
        o_PWM_1:                    out std_logic;
        o_PWM_2:                    out std_logic;
        o_PWM_3:                    out std_logic;
        o_PWM_4:                    out std_logic;
        o_PWM_5:                    out std_logic;
        o_PWM_6:                    out std_logic;
        o_PWM_7:                    out std_logic;
        o_PWM_8:                    out std_logic;
        servo_PWM:                  out std_logic;
        o_ssd:                      out std_logic_vector(6 downto 0);
        o_ssd_cat:                  out std_logic;
        o_led:                      out std_logic_vector(3 downto 0)
    );
end top_level_controller;

architecture Behavioral of top_level_controller is

component image_rx_tx_with_filter is
    generic(
        data_width:                 integer := 8;
        addr_width:                 integer := 18;
        filters_width:              integer := 8;
        num_elements_input:         integer := 242_004;
        num_elements_output:        integer := 240_000;
        num_instruction_bytes:      integer := 3;
        instruction_reg_width:      integer := 24;
        g_clk_cycles_bit:           integer := 135 -- Baud rate set to 921600
    );
    Port (
        i_clk:                      in std_logic;
        i_reset:                    in std_logic;
        i_data_in_rx:               in std_logic;
        write_enable_input_bram:    in std_logic;
        read_enable_input_bram:     in std_logic;
        write_enable_output_bram:   in std_logic;
        read_enable_output_bram:    in std_logic;
        rx_instruction_active:      in std_logic;
        i_start_filtering:          in std_logic;
        i_rx_instruction_in:        in std_logic;
        i_rx_image_in:              in std_logic;
        filter_select:              in std_logic_vector(filters_width-1 downto 0);
        threshold_value:            in std_logic_vector(filters_width-1 downto 0);
        o_tx_serial_data:           out std_logic;
        o_rx_instruction_done:      out std_logic;
        o_rx_instruction_reg:       out std_logic_vector(instruction_reg_width-1 downto 0);
        filter_done:                out std_logic;
        o_led:                      out std_logic_vector(3 downto 0)
    );
end component image_rx_tx_with_filter;

component motor_controller is
    generic (
        data_width:             integer := 8;
        num_motors:             integer := 4;
        clk_freq:               integer := 125
    );
    port (
        i_clk:                  in std_logic;
        i_reset:                in std_logic;
        start_drive_mode:       in std_logic;
        duty_cycle_value_reg:   in std_logic_vector(data_width-1 downto 0);
        PWM_enable_reg:         in std_logic_vector(num_motors-1 downto 0);
        motor_direction_reg:    in std_logic_vector(num_motors-1 downto 0);
        sensor_pulse:           in std_logic;
        sensor_enable:          out std_logic;
        o_PWM_1:                out std_logic;
        o_PWM_2:                out std_logic;
        o_PWM_3:                out std_logic;
        o_PWM_4:                out std_logic;
        o_PWM_5:                out std_logic;
        o_PWM_6:                out std_logic;
        o_PWM_7:                out std_logic;
        o_PWM_8:                out std_logic;
        o_ssd:                  out std_logic_vector(6 downto 0);
        o_ssd_cat:              out std_logic
    );
end component motor_controller;

component servo_controller is
    generic (
        main_clk_freq:          integer := 125000000;   -- 125 MHz Zybo Clock Frequency
        servo_refresh_rate:     integer := 50;          -- 50 Hz (20 ms) required for servo refresh rate; Typically a servo gets updated every 20 ms with a pulse between 1 ms and 2 ms
        servo_max_step_count:   positive := 10;         -- Maximum number of steps; incrementing 10 will turn the servo 180 to degrees and back to original position when decrementing
        min_PWM_in_us:          integer := 575;         -- Minimum PWM signal range from HS-311 datasheet
        max_PWM_in_us:          integer := 2460         -- Maximum PWM signal range from HS-311 datasheet
    );
    Port (
        i_clk:                  in std_logic;
        i_reset:                in std_logic;
        servo_enable:           in std_logic;
        servo_position_reg:     in std_logic_vector(7 downto 0);
        servo_PWM:              out std_logic
     );
end component servo_controller;

-- Instruction Rx Signals
signal rx_instruction_reg:          std_logic_vector(instruction_reg_width-1 downto 0);
signal rx_instruction_in_reg:       std_logic;
signal rx_image_in_reg:             std_logic;
signal rx_instruction_done:         std_logic;

-- Spatial Filter Signals
signal enable_filter_bit:           std_logic;
signal start_filtering:             std_logic; -- Used to synchronize with filter select
signal filter_select:               std_logic_vector(filters_width-1 downto 0);
signal threshold_value:             std_logic_vector(data_width-1 downto 0);
signal filter_done:                 std_logic;

-- Drive Mode Signals
signal enable_drive_bit:            std_logic;
signal start_drive_mode:            std_logic; -- Used to synchronize with duty cycle, PWM output, and motor dir values
signal duty_cycle_value_reg:        std_logic_vector(data_width-1 downto 0); -- This corresponds to rx_instruction_reg(15 downto 8)
signal PWM_enable_reg:              std_logic_vector(num_motors-1 downto 0); -- This corresponds to rx_instruction_reg(19 downto 16)
signal motor_direction_reg:         std_logic_vector(num_motors-1 downto 0); -- This corresponds to rx_instruction_reg(23 downto 20)

-- Signals for synchronizing start signals
signal start_filtering_reg:         std_logic;
signal start_drive_mode_reg:        std_logic;

-- Servo Signals
signal servo_position_reg:          std_logic_vector(7 downto 0);
signal servo_enable:                std_logic;

begin

image_rx_tx_with_filter_instance: image_rx_tx_with_filter
    generic map(
        data_width => data_width,
        addr_width => addr_width,
        filters_width => filters_width,
        num_elements_input => num_elements_input,
        num_elements_output => num_elements_output,
        num_instruction_bytes => num_instruction_bytes,
        instruction_reg_width => instruction_reg_width,
        g_clk_cycles_bit => g_clk_cycles_bit
    )
    port map(
        i_clk => i_clk,
        i_reset => i_reset,
        i_data_in_rx => i_data_in_rx,
        write_enable_input_bram => write_enable_input_bram,
        read_enable_input_bram => read_enable_input_bram,
        write_enable_output_bram => write_enable_output_bram,
        read_enable_output_bram => read_enable_output_bram,
        rx_instruction_active => rx_instruction_active,
        i_start_filtering => start_filtering_reg,
        i_rx_instruction_in => rx_instruction_in_reg,
        i_rx_image_in => rx_image_in_reg,
        filter_select => filter_select,
        threshold_value => threshold_value,
        o_tx_serial_data => o_tx_serial_data,
        o_rx_instruction_done => rx_instruction_done,
        o_rx_instruction_reg => rx_instruction_reg,
        o_led => o_led
    );

motor_controller_instance: motor_controller
    generic map(
        data_width => data_width,
        num_motors => num_motors,
        clk_freq => clk_freq
    )
    port map(
        i_clk => i_clk,
        i_reset => i_reset,
        start_drive_mode => start_drive_mode_reg,
        duty_cycle_value_reg => duty_cycle_value_reg,
        PWM_enable_reg => PWM_enable_reg,
        motor_direction_reg => motor_direction_reg,
        sensor_pulse => sensor_pulse,
        sensor_enable => sensor_enable,
        o_PWM_1 => o_PWM_1,
        o_PWM_2 => o_PWM_2,
        o_PWM_3 => o_PWM_3,
        o_PWM_4 => o_PWM_4,
        o_PWM_5 => o_PWM_5,
        o_PWM_6 => o_PWM_6,
        o_PWM_7 => o_PWM_7,
        o_PWM_8 => o_PWM_8,
        o_ssd => o_ssd,
        o_ssd_cat => o_ssd_cat
    );

servo_controller_instance: servo_controller
    generic map (
        main_clk_freq => main_clk_freq,
        servo_refresh_rate => servo_refresh_rate,
        servo_max_step_count => servo_max_step_count,
        min_PWM_in_us => min_PWM_in_us,
        max_PWM_in_us => max_PWM_in_us
    )
    port map (
        i_clk => i_clk,
        i_reset => i_reset,
        servo_enable => servo_enable,
        servo_position_reg => servo_position_reg,
        servo_PWM => servo_PWM
    );

sync_start_signals_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        start_filtering_reg <= start_filtering;
        start_drive_mode_reg <= start_drive_mode;
    end if;
end process sync_start_signals_proc;

-- Process to handle incoming serial data from the Raspberry Pi
-- If rx_instruction_active is set high, then redirect i_data_in_rx to the UART Rx side used to handle instructions
-- Otherwise, the Raspberry Pi must be transmitting the image matrix
instruction_rx_data_in_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (rx_instruction_active = '1') then
            rx_instruction_in_reg <= i_data_in_rx;
        else
            rx_image_in_reg <= i_data_in_rx;
        end if;
    end if;
end process instruction_rx_data_in_proc;

-- Process for handling current active mode
-- Note:
--      start_drive_mode corresponds to rx_instruction_reg(0)
--      start_filtering corresponds to rx_instruction_reg(1)
active_mode_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            start_filtering <= '0';
            start_drive_mode <= '0';
            servo_enable <= '0';
        else
            if (rx_instruction_done = '1') then
                start_drive_mode <= rx_instruction_reg(0);
                start_filtering <= rx_instruction_reg(1);
                servo_enable <= rx_instruction_reg(2);
                if (write_enable_input_bram = '0' and read_enable_input_bram = '0' and write_enable_output_bram = '0' and read_enable_output_bram = '0') then
                    start_filtering <= '0';
                end if;
            else
                start_filtering <= '0';
                start_drive_mode <= '0';
                servo_enable <= '0';
            end if;
        end if;
    end if;
end process active_mode_proc;

-- Process for handling filter_select and threshold_value
-- Note:
--      filter_select corresponds to rx_instruction_reg(15 downto 8)
--      threshold_value corresponds to rx_instruction_reg(23 downto 16)
filter_select_reg_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            threshold_value <= (others => '0');
            filter_select <= (others => '0');
        else
            if (rx_instruction_done = '1' and start_filtering = '1' and start_drive_mode = '0' and servo_enable = '0') then
                threshold_value <= rx_instruction_reg(23 downto 16);
                filter_select <= rx_instruction_reg(15 downto 8);
            end if;
        end if;
    end if;
end process filter_select_reg_proc;

-- Process for handling PWM enable and motor direction bits
-- Note:
--      motor_direction_reg corresponds to rx_instruction_reg(23 downto 20)
--      PWM_enable_reg corresponds to rx_instruction_reg(19 downto 16)
--      duty_cycle_value_reg corresponds to rx_instruction_reg(15 downto 8)
pwm_and_motor_dir_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            duty_cycle_value_reg <= (others => '0');
            PWM_enable_reg <= (others => '0');
            motor_direction_reg <= (others => '0');
        else
            if (rx_instruction_done = '1' and start_drive_mode = '1' and start_filtering = '0' and servo_enable = '0') then
                motor_direction_reg <= rx_instruction_reg(23 downto 20);
                PWM_enable_reg <= rx_instruction_reg(19 downto 16);
                duty_cycle_value_reg <= rx_instruction_reg(15 downto 8);
            elsif (start_drive_mode = '0' and start_filtering = '0' and servo_enable = '0') then
                motor_direction_reg <= (others => '0');
                PWM_enable_reg <= (others => '0');
                duty_cycle_value_reg <= (others => '0');
            end if;
        end if;
    end if;
end process pwm_and_motor_dir_proc;

servo_position_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            servo_position_reg <= (others => '0');
        else
            if (rx_instruction_done = '1' and start_filtering = '0' and start_drive_mode = '0' and servo_enable = '1') then
                servo_position_reg <= rx_instruction_reg(15 downto 8);
            elsif (start_drive_mode = '0' and start_filtering = '0' and servo_enable = '0') then
                servo_position_reg <= (others => '0');
            end if;
        end if;
    end if;
end process servo_position_proc;

sensor_enable <= '1';

end Behavioral;
