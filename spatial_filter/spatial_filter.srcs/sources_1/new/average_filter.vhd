----------------------------------------------------------------------------------
-- Company: California State Universitry Northridge
-- Engineer: Jose Luis Martinez
-- 
-- Create Date: 11/09/2021 08:37:22 PM
-- Design Name: Average Filter 
-- Module Name: average_filter - Behavioral
-- Project Name: FPGA Telemetry Robot
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity average_filter is
    generic(
        data_width:         integer := 8;
        addr_width:         integer := 18;
        num_elements:       integer := 240_000
    );
    Port ( clk, rst, ena: in std_logic;
           done, wea: out std_logic;
           addr0: out std_logic_vector(addr_width-1 downto 0);
           din0: in std_logic_vector(data_width-1 downto 0);
           output_a: out std_logic_vector(addr_width-1 downto 0);
           output_d: out std_logic_vector(data_width-1 downto 0));
end average_filter;

architecture Behavioral of average_filter is

type pl is array (8 downto 0) of integer;
signal pixel_locations: pl := (600, -600, 1, -1, -599, -601, 601, 599, 0);
signal accu: unsigned(11 downto 0);
signal countV, countP, countH, countU: integer; -- countV (kernal) countP(whole image)
constant MAX_VAL: integer := 9;
constant MAX: integer := 240000; -- 602 * 402
constant MAX_HORIZONTAL: integer := 600;
constant BASE_ADDR_W: integer := 0; 
constant BASE_ADDR_R: integer := 604;


begin

process(clk)
begin
    if(rising_edge(clk)) then
        if(rst = '1') then
            accu <= (others => '0');
            countP <= 0;
            countV <= 0;
            countU <= 0;
            countH <= 0;
            wea <= '0';
            done <= '0';
            output_a <= std_logic_vector(to_unsigned(BASE_ADDR_W, 18));
            output_d <= std_logic_vector(to_unsigned(0, 8));
        elsif(ena = '1') then
            if(countU < MAX) then
                if(countV < 9) then
                    addr0 <= std_logic_vector(to_unsigned(BASE_ADDR_R + countP + pixel_locations(countV), 18));
                    accu <= accu + unsigned(din0);
                    wea <= '0';
                    countV <= countV + 1;
                else
                    if(countH < MAX_HORIZONTAL) then
                        countV <= 0;
                        wea <= '1';
                        output_d <= std_logic_vector(resize((accu / 9), 8));
                        output_a <= std_logic_vector(to_unsigned(BASE_ADDR_W + countP, 18));
                        countP <= countP + 1;
                        countH <= countH + 1;
                        countU <= countU + 1;
                        accu <= (others => '0');
                    else
                        countV <= 0;
                        wea <= '1';
                        output_d <= std_logic_vector(resize(accu/9, 8));
                        output_a <= std_logic_vector(to_unsigned(BASE_ADDR_W + countP, 18));
                        countU <= countU + 1;
                        accu <= (others => '0');
                        countH <= 0; 
                        countP <= countP + 3;
                    end if;
                end if;
            else
                done <= '1';
            end if;
        end if;
    end if;
end process;

end Behavioral;
