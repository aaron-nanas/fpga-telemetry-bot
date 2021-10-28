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
        o_data_out_byte_rx:     out std_logic_vector(7 downto 0);
        o_PWM:                  out std_logic
    );
end top_bot_controller;

architecture Behavioral of top_bot_controller is

signal s_enable_PWM:            std_logic := '0';
signal s_data_out_byte_rx:      std_logic_vector(7 downto 0);

component pwm_generator is
    port (
        i_clk:                  in std_logic;
        i_reset:                in std_logic;
        i_enable:               in std_logic;
        o_PWM:                  out std_logic
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

pwm_generator_instance: pwm_generator
    port map (
        i_clk               =>  i_clk,
        i_reset             =>  i_reset,
        i_enable            =>  s_enable_PWM,
        o_PWM               =>  o_PWM
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
    
motor_control_proc: process(i_clk)
begin
    if (s_data_out_byte_rx = "10101010") then
        s_enable_PWM <= '1';
    elsif (s_data_out_byte_rx = "01010101") then
        s_enable_PWM <= '0';
    elsif (s_data_out_byte_rx = "00000000") then
        s_enable_PWM <= '0';
    else
        s_enable_PWM <= '0';
    end if;
end process motor_control_proc;

o_data_out_byte_rx <= s_data_out_byte_rx;

end Behavioral;
