library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity tb_uart_top_controller is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
end tb_uart_top_controller;

architecture Behavioral of tb_uart_top_controller is

component uart_top_controller is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
    Port (
        i_clk:                  in std_logic;
        i_data_in_rx:           in std_logic;
        o_tx_active:            out std_logic;
        o_tx_serial_data:       out std_logic;
        o_tx_done:              out std_logic
    );
end component uart_top_controller;

signal i_clk:                   std_logic;
signal i_data_in_rx:            std_logic;
signal o_tx_active:             std_logic;
signal o_tx_serial_data:        std_logic;
signal o_tx_done:               std_logic;

-- Bit period can be obtained by the following formula:
-- Bit Period = (1 / Baud Rate)
-- In this case:
-- Bit Period = (1 / 115200) = 8680 ns
constant uart_bit_period:       time := 8680 ns;

-- Zybo's Main Clock Frequency of 125 MHz
constant clk_per:               time := 8 ns;

begin

UUT_uart_top_controller: uart_top_controller
    generic map (
        g_clk_cycles_bit        => g_clk_cycles_bit
    )
    
    port map (
        i_clk                   => i_clk,
        i_data_in_rx            => i_data_in_rx,
        o_tx_active             => o_tx_active,
        o_tx_serial_data        => o_tx_serial_data,
        o_tx_done               => o_tx_done
    );

clk_proc: process
begin
    i_clk <= '0';
    wait for clk_per/2;
    
    i_clk <= '1';
    wait for clk_per/2;
end process clk_proc;

test_uart_proc: process
begin
    wait until rising_edge(i_clk);
    wait until rising_edge(i_clk);
    
    -- Idle bit
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    -- Start bit for Rx
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
------------- Start of Bit Vector -----------------
    -- Serially send out bit vector of "10001111"
    -- Note: LSB goes first
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '0';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
------------- End of Bit vector -----------------
    
    -- Stop bit for rx
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    -- Idle bit for rx
    i_data_in_rx <= '1';
    wait for uart_bit_period;

end process test_uart_proc;

end Behavioral;
