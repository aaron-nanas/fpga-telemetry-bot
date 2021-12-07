----------------------------------------------------------------------------------
-- Company: California State University Northridge
-- Engineer: Jose Luis Martinez
-- 
-- Create Date: 11/09/2021 08:37:22 PM
-- Design Name: Threshold Filter
-- Module Name: threshold_filter - Behavioral
-- Project Name: FPGA Telemetry Robot
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity threshold_filter is
    Port ( clk, rst, ena: in std_logic;
           done: out std_logic;
           addr0: out std_logic_vector(17 downto 0);
           din0: in std_logic_vector(7 downto 0);
           threshold_value: in std_logic_vector(7 downto 0);
           wea: out std_logic;
           output_a: out std_logic_vector(17 downto 0);
           output_d: out std_logic_vector(7 downto 0));
end threshold_filter;

architecture Behavioral of threshold_filter is

signal countV, countP, countH, countU: integer := 0; -- countV (kernel) countP(whole image)
constant MAX: integer := 240000; -- 602 * 402
constant MAX_HORIZONTAL: integer := 600;
constant BASE_ADDR_W: integer := 0; 
constant BASE_ADDR_R: integer := 604;

begin

process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            countP <= 0;
            countV <= 0;
            countH <= 0;
            countU <= 0;
            wea <= '0';
            done <= '0';
            output_a <= std_logic_vector(to_unsigned(BASE_ADDR_W, 18));
            output_d <= std_logic_vector(to_unsigned(0, 8));
        elsif(ena = '1') then
            if(countP < MAX) then
                if(countH < MAX_HORIZONTAL) then
                    countV <= 0;
                    wea <= '1';
                    addr0 <= std_logic_vector(to_unsigned(BASE_ADDR_R + countP, 18));
                    if(unsigned(din0) < unsigned(threshold_value)) then
                        output_d <= (others => '0');
                    else 
                        output_d <= std_logic_vector(to_unsigned(255, 8));
                    end if;
                    output_a <= std_logic_vector(to_unsigned(BASE_ADDR_W + countU, 18));
                    countP <= countP + 1;
                    countH <= countH + 1;
                    countU <= countU + 1;
                else
                    countV <= 0;
                    wea <= '1';
                    addr0 <= std_logic_vector(to_unsigned(BASE_ADDR_R + countP, 18));
                    if(unsigned(din0) < unsigned(threshold_value)) then
                        output_d <= (others => '0');
                    else 
                        output_d <= std_logic_vector(to_unsigned(255, 8));
                    end if;
                    output_a <= std_logic_vector(to_unsigned(BASE_ADDR_W + countU, 18));
                    countH <= 0; 
                    countU <= countU + 1;
                    countP <= countP + 3;
                end if;
            else
                done <= '1';
            end if;
        end if;
    end if;
end process;

end Behavioral;