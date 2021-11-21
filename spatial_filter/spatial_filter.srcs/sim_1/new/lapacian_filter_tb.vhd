----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2021 08:39:57 PM
-- Design Name: 
-- Module Name: lapacian_filter_tb - Behavioral
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

entity lapacian_filter_tb is
--  Port ( );
end lapacian_filter_tb;

architecture Behavioral of lapacian_filter_tb is
component lapacian_filter is
    Port ( clk: in std_logic;
           rst: in std_logic;
           ena: in std_logic;
           done: out std_logic;
           addr0: out std_logic_vector(17 downto 0);
           din0: in std_logic_vector(7 downto 0);
           wea: out std_logic;
           output_a: out std_logic_vector(7 downto 0);
           output_d: out std_logic_vector(11 downto 0));
end component lapacian_filter;

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

signal clk_tb, rst_tb, ena_tb, done_tb, wea_tb: std_logic;
signal addr0_tb: std_logic_vector(17 downto 0);
signal din0_tb, output_a_tb: std_logic_vector(7 downto 0);
signal output_d_tb: std_logic_vector(11 downto 0);
constant CLK_PER: time := 40ns;
begin

BRAM0 : blk_mem_gen_0
  PORT MAP (
    clka => clk_tb,
    wea => "0",
    addra => addr0_tb,
    dina => "00000000",
    douta => din0_tb
  );
  
AVE_FILTER: lapacian_filter port map (clk => clk_tb, rst => rst_tb, ena => ena_tb, done => done_tb, addr0 => addr0_tb, 
                                         din0 => din0_tb, wea => wea_tb, output_a => output_a_tb, output_d => output_d_tb);
  
 process
    file out_file: text open write_mode is "D:\Labs\ECE524\fpga-telemetry-bot\spatial_filter\spatial_filter.srcs\sources_1\lapacian_output.txt";
    variable outline: line;
 begin
    wait for 470ns;
    for i in 0 to 249999 loop
        write(outline, to_integer(signed(output_d_tb)));
        writeline(out_file, outline);
        wait for 240ns;
    end loop;
    file_close(out_file);
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
    rst_tb <= '1';
    ena_tb <= '1';
    wait for CLK_PER * 2;
    rst_tb <= '0';
    wait;
end process;



end Behavioral;
