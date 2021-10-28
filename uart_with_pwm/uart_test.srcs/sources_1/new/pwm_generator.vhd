-- Author: Aaron Nanas
-- File: pwm_generator.vhd
-- Purpose: Generates multiple PWM signals to control four DC motors

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity pwm_generator is
    port (
        i_clk:                  in std_logic;
        i_reset:                in std_logic;
        i_enable:               in std_logic;
        o_PWM:                  out std_logic
        );
end pwm_generator;

architecture Behavioral of pwm_generator is
    signal r_frequency_counter:     integer := 0;
    signal r_PWM:                   std_logic := '0';
    
    -- This constant serves as a limit for the counter
    -- to toggle between 0 and 1
    -- Formula: (Main Clock Frequency / (Motor Driver Frequency)(% Duty Cycle))
    -- In this case: (125 MHz / (20 kHz * 50% Duty Cycle) = (6250 * 0.50) = 3125
    constant c_counter_limit:       integer := 3125;
begin

-- TODO: 
--  Add speed control (make duty cycle variable)
--  Add direction input
--  Extend PWM signal output to a total of four 
proc_pwm: process(i_clk)
begin
    if (i_reset = '1') then
        r_frequency_counter <= 0;
    elsif (rising_edge(i_clk)) then
        if (i_enable = '1') then
            if (r_frequency_counter = c_counter_limit) then
                r_frequency_counter <= 0;
                r_PWM <= not(r_PWM);
            else
                r_frequency_counter <= r_frequency_counter + 1;
            end if;
        else
            r_frequency_counter <= 0;
        end if;
    end if;
end process proc_pwm;

o_PWM <= r_PWM;

end Behavioral;