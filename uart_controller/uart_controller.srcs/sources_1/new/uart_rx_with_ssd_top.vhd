-- Author: Aaron Nanas
-- File: uart_rx_with_ssd_top.vhd
-- This serves as another way of verifying the UART data stream between the Zybo and the Raspberry Pi.
-- The Zybo will receive 8 bits of data from the Raspberry Pi's TX pin.
-- Then, the incoming data will be shown on the Seven-Segment Display (SSD)
--
-- For this UART Rx, the config is:
-- One start bit
-- One stop bit
-- No parity bit
-- Receives incoming 8 bits of serial data
--
-- The number of clocks needed for a given baud rate can be calculated as follows:
-- (Clock Frequency / Baud Rate)
-- Example:
--      (125 MHz / 115200) = 1085

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity uart_rx_with_ssd_top is
    generic (
        g_clk_cycles_bit:   integer := 1085
    );
    Port (
        i_clk:              in std_logic;
        i_data_in_rx:       in std_logic;
        o_ssd:              out std_logic_vector(6 downto 0);
        o_led:              out std_logic_vector(7 downto 0);
        o_ssd_cat:          out std_logic
    );
end uart_rx_with_ssd_top;

architecture Behavioral of uart_rx_with_ssd_top is

component uart_rx_with_ssd is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
    port (
        i_clk:                  in std_logic;
        i_data_in_rx:           in std_logic;
        o_data_out_byte_rx:     out std_logic_vector(7 downto 0)
    );
end component uart_rx_with_ssd;

signal s_data_out_byte_rx:  std_logic_vector(7 downto 0);
signal s_data_out_byte_rx_rearranged: std_logic_vector(7 downto 0);
signal s_data_out_nibble_rx: std_logic_vector(3 downto 0);
signal ssd_counter: integer := 0;
signal ssd_pulse: std_logic := '0';
signal ssd_cat_signal: std_logic;

begin

uart_rx_instance: uart_rx_with_ssd
    generic map(
        g_clk_cycles_bit => g_clk_cycles_bit
    )
    port map(
        i_clk               => i_clk,
        i_data_in_rx        => i_data_in_rx,
        o_data_out_byte_rx  => s_data_out_byte_rx
    );

binary_to_hex_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        case (s_data_out_nibble_rx) is
            when "0000" =>
                o_ssd <= "1111110";
            when "0001" =>
                o_ssd <= "0110000";
            when "0010" =>
                o_ssd <= "1101101";
            when "0011" =>
                o_ssd <= "1111001";
            when "0100" =>
                o_ssd <= "0110011";          
            when "0101" =>
                o_ssd <= "1011011";
            when "0110" =>
                o_ssd <= "1011111";
            when "0111" =>
                o_ssd <= "1110000";
            when "1000" =>
                o_ssd <= "1111111";
            when "1001" =>
                o_ssd <= "1110011";
            when "1010" =>
                o_ssd <= "1110111";
            when "1011" =>
                o_ssd <= "0011111";
            when "1100" =>
                o_ssd <= "1001110";
            when "1101" =>
                o_ssd <= "0111101";
            when "1110" =>
                o_ssd <= "1001111";
            when "1111" =>
                o_ssd <= "1000111";
        end case;
    end if;
end process binary_to_hex_proc;

ssd_counter_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (ssd_counter = 99999) then
            ssd_counter <= 0;
            ssd_pulse <= '1';
        else
            ssd_counter <= ssd_counter + 1;
            ssd_pulse <= '0';
        end if;
    end if;
end process;

ssd_pulse_proc: process(i_clk)
begin
    if (ssd_pulse = '1') then
        ssd_cat_signal <= not(ssd_cat_signal);
    end if;

end process;

s_data_out_byte_rx_rearranged <= s_data_out_byte_rx(3 downto 0) & s_data_out_byte_rx(7 downto 4);
o_led <= s_data_out_byte_rx;
o_ssd_cat <= ssd_cat_signal;
s_data_out_nibble_rx <= s_data_out_byte_rx_rearranged(3 downto 0) when (ssd_cat_signal = '1') else s_data_out_byte_rx_rearranged(7 downto 4);

end Behavioral;
