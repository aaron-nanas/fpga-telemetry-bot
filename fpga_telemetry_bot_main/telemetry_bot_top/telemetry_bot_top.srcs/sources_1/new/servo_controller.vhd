--Author: Aaron Nanas
--File: servo_controller.vhd
--Purpose:
--    Interfaces the servo that controls the position of the camera, with a total of 10 positions
--    Generates the PWM signal for the HS-311 servo motor
--    Refresh rate of 50 Hz, which is typical for servo motors
--    Minimum PWM Signal: 575 μsec
--    Maximum PWM Signal: 2460 μsec
--    The position increments or decrements by 1 depending on which button the user has pressed from the Web UI

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity servo_controller is
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
end servo_controller;

architecture Behavioral of servo_controller is

    -- Function to convert count to seconds first, and then it starts the division to count number of cycles needed
    function cycles_per_us(count_in_us: integer) return integer is
        variable num_of_cycles: integer := main_clk_freq / 1000000 * count_in_us;
    begin
        return num_of_cycles;
    end function;
    
    constant min_count:         integer := cycles_per_us(min_PWM_in_us);
    constant max_count:         integer := cycles_per_us(max_PWM_in_us);
    constant servo_PWM_range:   integer := max_PWM_in_us - min_PWM_in_us;
    constant step_in_us:        integer := servo_PWM_range / (servo_max_step_count - 1);
    constant cycles_per_step:   positive := cycles_per_us(step_in_us);
    constant counter_max:       integer := (main_clk_freq / servo_refresh_rate) - 1;
    
    signal counter:             integer range 0 to counter_max;
    signal duty_cycle:          integer range 0 to max_count;
    signal servo_position:      integer range 0 to servo_max_step_count;

begin

counter_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            counter <= 0;
        else
            if (servo_enable = '1') then
                if (counter < counter_max) then
                    counter <= counter + 1;
                else
                    counter <= 0;
                end if;
            end if;
        end if;
    end if;
end process counter_proc;

PWM_and_duty_cycle_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            servo_PWM <= '0';
            duty_cycle <= min_count;
        else
            if (servo_enable = '1') then
                servo_PWM <= '0';
                duty_cycle <= (servo_position * cycles_per_step) + min_count;
                if (counter < duty_cycle) then
                    servo_PWM <= '1';
                end if;
            end if;
        end if;
    end if;
end process PWM_and_duty_cycle_proc;

servo_position_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            servo_position <= 0;
        else
            if (servo_enable = '1') then
                if (to_integer(unsigned(servo_position_reg)) < (servo_max_step_count + 1)) then
                    servo_position <= to_integer(unsigned(servo_position_reg));
                else
                    servo_position <= 0;
                end if;
            end if;
        end if;
    end if;
end process servo_position_proc;

end Behavioral;
