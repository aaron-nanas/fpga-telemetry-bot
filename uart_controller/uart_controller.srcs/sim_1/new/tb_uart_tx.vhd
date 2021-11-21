library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity tb_uart_tx is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
end tb_uart_tx;

architecture Behavioral of tb_uart_tx is

component uart_tx is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
    
    Port (
        i_clk:                  in std_logic;
        i_tx_data_byte:         in std_logic_vector(7 downto 0);
        i_tx_dv:                in std_logic;
        o_tx_active:            out std_logic;
        o_tx_serial_data:       out std_logic;
        o_tx_done:              out std_logic
    );
end component uart_tx;

signal i_clk:                   std_logic;
signal i_tx_data_byte:          std_logic_vector(7 downto 0);
signal i_tx_dv:                 std_logic;
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

uart_tx_instance: uart_tx
    generic map (
        g_clk_cycles_bit        => g_clk_cycles_bit
    )
    port map (
        i_clk                   => i_clk,
        i_tx_data_byte          => i_tx_data_byte,
        i_tx_dv                 => i_tx_dv,
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

test_uart_tx_proc: process
begin
    wait until rising_edge(i_clk);
    wait until rising_edge(i_clk);
    
    i_tx_data_byte <= (others => '0'); i_tx_dv <= '0';
    wait for uart_bit_period;
    
    -- Transmitting 8-bit data of 0xFA
    i_tx_data_byte <= x"FA"; i_tx_dv <= '1';
    wait for 8 * uart_bit_period;
    
    i_tx_dv <= '0';
    wait for uart_bit_period;
    
    -- Transmitting 8-bit data of 0xAB
    i_tx_data_byte <= x"AB"; i_tx_dv <= '1';
    wait for 8 * uart_bit_period;
    
    i_tx_dv <= '0';
    wait for uart_bit_period;
    
end process test_uart_tx_proc;

end Behavioral;
