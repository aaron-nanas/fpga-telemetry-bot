library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity tb_uart_rx is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
end tb_uart_rx;

architecture Behavioral of tb_uart_rx is

component uart_rx is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
    port (
        i_clk:                  in std_logic;
        i_data_in_rx:           in std_logic;
        o_data_out_byte_rx:     out std_logic_vector(7 downto 0);
        o_rx_dv:                out std_logic
    );
end component uart_rx;

signal i_clk:                   std_logic;
signal i_data_in_rx:            std_logic;
signal o_data_out_byte_rx:      std_logic_vector(7 downto 0);
signal o_rx_dv:                 std_logic;

-- Bit period can be obtained by the following formula:
-- Bit Period = (1 / Baud Rate)
-- In this case:
-- Bit Period = (1 / 115200) = 8680 ns
constant uart_bit_period:       time := 8680 ns;

-- Zybo's Main Clock Frequency of 125 MHz
constant clk_per:               time := 8 ns;

begin

uart_rx_instance: uart_rx
    generic map (
        g_clk_cycles_bit        => g_clk_cycles_bit
    )
    
    port map (
        i_clk                   => i_clk,
        i_data_in_rx            => i_data_in_rx,
        o_data_out_byte_rx      => o_data_out_byte_rx,
        o_rx_dv                 => o_rx_dv
    );

clk_proc: process
begin
    i_clk <= '0';
    wait for clk_per/2;
    
    i_clk <= '1';
    wait for clk_per/2;
end process clk_proc;

test_uart_rx_proc: process
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
    
    -- Start bit
    i_data_in_rx <= '0';
    wait for uart_bit_period;

------------- Start of Bit Vector -----------------
    -- Send out bit vector of "10101010"
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

------------- End of Bit vector -----------------

    -- Idle bit
    i_data_in_rx <= '1';
    wait for uart_bit_period;

end process test_uart_rx_proc;

end Behavioral;
