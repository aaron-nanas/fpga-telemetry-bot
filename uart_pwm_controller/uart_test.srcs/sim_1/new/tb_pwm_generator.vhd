library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity tb_pwm_generator is
    -- Port ( );
end tb_pwm_generator;

architecture Behavioral of tb_pwm_generator is

component pwm_generator is
    Port (
        i_clk:              in std_logic;
        i_reset:            in std_logic;
        i_enable:           in std_logic;
        i_duty_cycle:       in integer range 0 to 255;
        o_PWM:              out std_logic
     );
end component pwm_generator;

signal i_clk:               std_logic;
signal i_reset:             std_logic;
signal i_enable:            std_logic;
signal i_duty_cycle:        integer range 0 to 255;
signal o_PWM:               std_logic;
constant clk_per:           time := 8 ns; -- 125 Mhz

begin

UUT_pwm_generator: pwm_generator
    port map (
        i_clk           =>  i_clk,
        i_reset         =>  i_reset,
        i_enable        =>  i_enable,
        i_duty_cycle    =>  i_duty_cycle,
        o_PWM           =>  o_PWM
    );

clk_proc: process
begin
    i_clk <= '0';
    wait for clk_per/2;
    
    i_clk <= '1';
    wait for clk_per/2;

end process clk_proc;

reset_proc: process
begin
    i_reset <= '1';
    wait for clk_per;
    
    i_reset <= '0';
    wait for clk_per;
    wait;
    
end process reset_proc;

enable_proc: process
begin
    i_enable <= '0';
    wait for clk_per;
    
    i_enable <= '1';
    wait for clk_per;
    wait;
    
end process enable_proc;

pwm_test_proc: process
begin
    i_duty_cycle <= 0;
    wait for 200 us;
    
    i_duty_cycle <= 20;
    wait for 200 us;
    
    i_duty_cycle <= 40;
    wait for 200 us;

    i_duty_cycle <= 60;
    wait for 200 us;    
    
    i_duty_cycle <= 80;
    wait for 200 us;
    
    i_duty_cycle <= 100;
    wait for 200 us;
    
    i_duty_cycle <= 127;
    wait for 200 us;
    
    i_duty_cycle <= 160;
    wait for 200 us;
    
    i_duty_cycle <= 200;
    wait for 200 us;
    
    i_duty_cycle <= 230;
    wait for 200 us;
    
    i_duty_cycle <= 255;
    wait for 200 us;
    
end process pwm_test_proc;

end Behavioral;