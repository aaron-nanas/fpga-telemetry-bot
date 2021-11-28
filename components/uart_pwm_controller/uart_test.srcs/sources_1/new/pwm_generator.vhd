-- Author: Aaron Nanas
-- File: pwm_generator.vhd
-- Purpose: Generates multiple PWM signals to control four DC motors

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity pwm_generator is
    Port (
        i_clk:              in std_logic;
        i_reset:            in std_logic;
        i_enable:           in std_logic;
        i_duty_cycle:       in integer range 0 to 255;
        o_PWM:              out std_logic
     );
end pwm_generator;

architecture Behavioral of pwm_generator is

    -- Formula to determine the number of clocks needed for the prescale value
    -- (Main Clock Frequency / (255 * Desired Frequency)
    -- In this case: (125 MHz / (255 * 20kHz)) = 24
    constant prescale_value:    integer range 0 to 255 := 24;
    constant end_value:         integer range 0 to 255 := 255;
    signal pwm_clk_counter:     integer := 0;
    signal duty_cycle_counter:  integer range 0 to 255 := 0;
    signal s_PWM:               std_logic := '0';
    
begin

counter_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            pwm_clk_counter <= 0;
            duty_cycle_counter <= 0;
        else
            if (i_enable = '1') then
                o_PWM <= s_PWM;
                if (pwm_clk_counter = prescale_value) then
                    pwm_clk_counter <= 0;
                    if (duty_cycle_counter = end_value) then
                        duty_cycle_counter <= 0;
                    else
                        duty_cycle_counter <= duty_cycle_counter + 1;
                    end if;
                else
                    pwm_clk_counter <= pwm_clk_counter + 1;
                end if;
            else
                pwm_clk_counter <= 0;
                duty_cycle_counter <= 0;
            end if;
        end if;
    end if;
end process counter_proc;

generate_pwm_proc: process(duty_cycle_counter)
begin
    if (duty_cycle_counter <= i_duty_cycle) then
        s_PWM <= '0';
    end if;
    
    if (duty_cycle_counter > (end_value - i_duty_cycle)) then
        s_PWM <= '1';
    end if;
end process generate_pwm_proc;

end Behavioral;