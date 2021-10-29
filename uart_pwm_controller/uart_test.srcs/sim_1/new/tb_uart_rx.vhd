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
        o_data_out_byte_rx:     out std_logic_vector(7 downto 0)
    );
end component uart_rx;

signal i_clk:                   std_logic;
signal i_data_in_rx:            std_logic := '0';
signal o_data_out_byte_rx:      std_logic_vector(7 downto 0);
constant clk_per:               time := 8 ns; -- 125 Mhz
signal s_baud_counter:          integer range 0 to (g_clk_cycles_bit-1) := 0;
signal s_bit_counter:           integer range 0 to 7 := 0;

begin

UUT_uart_rx: uart_rx
    generic map (
        g_clk_cycles_bit    =>  g_clk_cycles_bit
    )
    port map (
        i_clk               =>  i_clk,
        i_data_in_rx        =>  i_data_in_rx,
        o_data_out_byte_rx  =>  o_data_out_byte_rx
    );

clk_proc: process
begin
    i_clk <= '0';
    wait for clk_per/2;
    
    i_clk <= '1';
    wait for clk_per/2;

end process clk_proc;

-- Run for 100 us simulation time
test_uart_rx_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (s_baud_counter < g_clk_cycles_bit-1) then
            s_baud_counter <= s_baud_counter + 1;
        else
            s_baud_counter <= 0;
            if (s_bit_counter < 9) then
                s_bit_counter <= s_bit_counter + 1;
                i_data_in_rx <= '1'; -- If all the bits received are 1s, then the output should be 0xAA
            else
                s_bit_counter <= 0;
            end if;
            
        end if;
    end if;

end process test_uart_rx_proc;

end Behavioral;
