library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity top_bot_controller is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
    port (
        i_clk:                  in std_logic;
        i_reset:                in std_logic;
        i_data_in_rx:           in std_logic;
        i_switch_duty_cycle:    in std_logic_vector(3 downto 0);
        i_set_direction:        in std_logic;
        o_direction_1:          out std_logic;
        o_direction_2:          out std_logic;
        o_direction_3:          out std_logic;
        o_direction_4:          out std_logic;
        o_data_out_byte_rx:     out std_logic_vector(7 downto 0);
        o_PWM_1:                out std_logic;
        o_PWM_2:                out std_logic;
        o_PWM_3:                out std_logic;
        o_PWM_4:                out std_logic
    );
end top_bot_controller;

architecture Behavioral of top_bot_controller is

signal s_enable_PWM_1:          std_logic := '0';
signal s_enable_PWM_2:          std_logic := '0';
signal s_enable_PWM_3:          std_logic := '0';
signal s_enable_PWM_4:          std_logic := '0';
signal s_data_out_byte_rx:      std_logic_vector(7 downto 0);
signal s_duty_cycle:            integer range 0 to 255 := 0;

component pwm_generator is
    Port (
        i_clk:              in std_logic;
        i_reset:            in std_logic;
        i_enable:           in std_logic;
        i_duty_cycle:       in integer range 0 to 255;
        o_PWM:              out std_logic
     );
end component pwm_generator;

component uart_rx is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
    port (
        i_clk:                  in std_logic;
        i_data_in_rx:           in std_logic;
        o_data_out_byte_rx:     out std_logic_vector(7 downto 0)
    );
end component uart_rx;

begin

pwm_generator_instance_1: pwm_generator
    port map (
        i_clk               =>  i_clk,
        i_reset             =>  i_reset,
        i_enable            =>  s_enable_PWM_1,
        i_duty_cycle        =>  s_duty_cycle,
        o_PWM               =>  o_PWM_1
    );
    
pwm_generator_instance_2: pwm_generator
    port map (
        i_clk               =>  i_clk,
        i_reset             =>  i_reset,
        i_enable            =>  s_enable_PWM_2,
        i_duty_cycle        =>  s_duty_cycle,
        o_PWM               =>  o_PWM_2
    );
    
pwm_generator_instance_3: pwm_generator
    port map (
        i_clk               =>  i_clk,
        i_reset             =>  i_reset,
        i_enable            =>  s_enable_PWM_3,
        i_duty_cycle        =>  s_duty_cycle,
        o_PWM               =>  o_PWM_3
    );
    
pwm_generator_instance_4: pwm_generator
    port map (
        i_clk               =>  i_clk,
        i_reset             =>  i_reset,
        i_enable            =>  s_enable_PWM_4,
        i_duty_cycle        =>  s_duty_cycle,
        o_PWM               =>  o_PWM_4
    );

uart_rx_instance: uart_rx
    generic map (
        g_clk_cycles_bit    =>  g_clk_cycles_bit
    )
    port map (
        i_clk               =>  i_clk,
        i_data_in_rx        =>  i_data_in_rx,
        o_data_out_byte_rx  =>  s_data_out_byte_rx
    );

-- Test data being received with LEDs
motor_control_proc: process(i_clk)
begin
    if (s_data_out_byte_rx = "10101010") then
        s_enable_PWM_1 <= '1';
        s_enable_PWM_2 <= '1';
    elsif (s_data_out_byte_rx = "01010101") then
        s_enable_PWM_1 <= '0';
        s_enable_PWM_2 <= '0';
    elsif (s_data_out_byte_rx = "00000000") then
        s_enable_PWM_1 <= '0';
        s_enable_PWM_2 <= '0';
    else
        s_enable_PWM_1 <= '0';
        s_enable_PWM_2 <= '0';
    end if;
end process motor_control_proc;

-- Test duty cycle changes with the Zybo's switches
duty_cycle_proc: process(i_clk)
begin
    if (i_switch_duty_cycle(0) = '1') then
        s_duty_cycle <= 0;
    end if;
    
    if (i_switch_duty_cycle(1) = '1') then
        s_duty_cycle <= 80;
    end if;
    
    if (i_switch_duty_cycle(2) = '1') then
        s_duty_cycle <= 160;
    end if;
    
    if (i_switch_duty_cycle(3) = '1') then
        s_duty_cycle <= 240;
    end if;
    
end process duty_cycle_proc;

o_data_out_byte_rx <= s_data_out_byte_rx;
o_direction_1 <= i_set_direction;
o_direction_2 <= i_set_direction;
o_direction_3 <= i_set_direction;
o_direction_4 <= i_set_direction;

end Behavioral;
