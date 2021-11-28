-- Author: Aaron Nanas
-- File: uart_top_controller.vhd
-- Serves as the top controller for the UART between the Zybo FPGA and the Raspberry Pi.
-- 
-- For this UART, the config is:
-- One start bit
-- One stop bit
-- No parity bit
-- Baud Rate = 115200
--
-- The number of clocks needed for a given baud rate can be calculated as follows:
-- (Clock Frequency / Baud Rate)
-- Example:
--      (125 MHz / 115200) = 1085

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity uart_top_controller is
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
end uart_top_controller;

architecture Behavioral of uart_top_controller is

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

signal reg_data_out_byte_rx:    std_logic_vector(7 downto 0);
signal dv_flag_signal:          std_logic;

begin

uart_rx_instance: uart_rx
    generic map (
        g_clk_cycles_bit        => g_clk_cycles_bit
    )
    
    port map (
        i_clk                   => i_clk,
        i_data_in_rx            => i_data_in_rx,
        o_data_out_byte_rx      => reg_data_out_byte_rx,
        o_rx_dv                 => dv_flag_signal
    );
    
uart_tx_instance: uart_tx
    generic map (
        g_clk_cycles_bit        => g_clk_cycles_bit
    )

    port map (
        i_clk                   => i_clk,
        i_tx_data_byte          => reg_data_out_byte_rx,
        i_tx_dv                 => dv_flag_signal,
        o_tx_active             => o_tx_active,
        o_tx_serial_data        => o_tx_serial_data,
        o_tx_done               => o_tx_done
    );

end Behavioral;
