----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2021 08:39:57 PM
-- Design Name: 
-- Module Name: filter_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;

entity filter_tb is
--  Port ( );
end filter_tb;

architecture Behavioral of filter_tb is
component top_level_filter_fsm is
    generic(
        data_width:         integer := 8;
        addr_width:         integer := 18;
        filters_width:        integer := 2;
        num_elements_input:       integer := 242_004;
        num_elements_output:       integer := 240_000
    );
    Port (  clk, rst: in std_logic;
            wea1, wea2, rea1, rea2: in  std_logic;
            start_filtering: in std_logic;
            filter_select: in std_logic_vector(filters_width - 1 downto 0);
            bram1_a, bram2_a: in std_logic_vector(addr_width-1 downto 0);
            bram1_din, bram2_din: in std_logic_vector(data_width-1 downto 0);
            bram1_dout, bram2_dout: out std_logic_vector(data_width-1 downto 0);
            done, busy: out std_logic);
end component top_level_filter_fsm;



signal clk_tb, rst_tb, ena_tb, done_tb, wea_tb, start_filtering_tb, busy_tb: std_logic;
signal wea1_tb, wea2_tb, rea1_tb, rea2_tb: std_logic;
signal filter_select_tb: std_logic_vector(1 downto 0);
signal bram1_a_tb, bram2_a_tb: std_logic_vector(17 downto 0);
signal bram1_din_tb, bram2_din_tb: std_logic_vector(7 downto 0);
signal bram1_dout_tb, bram2_dout_tb: std_logic_vector(7 downto 0);
signal count_tb: unsigned(17 downto 0) := (others => '0');
constant CLK_PER: time := 40ns;
begin
 
    uut: top_level_filter_fsm port map (clk => clk_tb, rst => rst_tb, start_filtering => start_filtering_tb, filter_select => filter_select_tb,
                                        wea1 => wea1_tb, wea2 => wea2_tb, rea1 => rea1_tb, rea2 => rea2_tb,
                                        bram1_a => bram1_a_tb, bram2_a => bram2_a_tb, bram1_din => bram1_din_tb, bram2_din => bram2_din_tb,
                                        bram1_dout => bram1_dout_tb, bram2_dout => bram2_dout_tb, done => done_tb, busy => busy_tb);
 
 process
    file     out_file: text open write_mode is "D:\Labs\ECE524\fpga-telemetry-bot\spatial_filter\spatial_filter.srcs\sources_1\lapacian_output.txt";
    variable outline: line;
 begin
    bram2_a_tb <= (others => '0');
    wait for 106ms;
    for i in 0 to 239999 loop
        bram2_a_tb <= std_logic_vector(to_unsigned(i, 18));
        write(outline, to_integer(signed(bram2_dout_tb)));
        writeline(out_file, outline);
        wait for CLK_PER;
    end loop;
    file_close(out_file);
 end process;
 
  process
    file     in_file: text open read_mode is "D:\Labs\ECE524\fpga-telemetry-bot\spatial_filter\spatial_filter.srcs\sources_1\image.txt";
    variable inline: line;
    variable data: integer;
 begin
    for i in 0 to 242003 loop
        readline(in_file, inline);
        read(inline, data);
        bram1_din_tb <= std_logic_vector(to_unsigned(data, 8));
        bram1_a_tb <= std_logic_vector(to_unsigned(i, 18));
        wait for CLK_PER;
    end loop;
    file_close(in_file);
    wait;
 end process;
 
clk_process: process
begin
    clk_tb <= '0';
    wait for (CLK_PER/2);
    clk_tb <= '1';
    wait for (CLK_PER/2);
end process;

process
begin
    wea_tb <= '1';
    wea1_tb <= '1';
    rea1_tb <= '0';
    wea2_tb <= '0';
    rea2_tb <= '0';
    rst_tb <= '1';
    ena_tb <= '1';
    start_filtering_tb <= '0';
    filter_select_tb <= "01";
    wait for CLK_PER;
    rst_tb <= '0';
    wait for CLK_PER * 242004;
    wea1_tb <= '0';
    rea1_tb <= '0';
    wea2_tb <= '0';
    rea2_tb <= '0';
    start_filtering_tb <= '1';
    rst_tb <= '0';
    wait for CLK_PER * 240000 * 10;
    wea1_tb <= '0';
    rea1_tb <= '0';
    wea2_tb <= '0';
    rea2_tb <= '1';
    wait;
end process;



end Behavioral;
