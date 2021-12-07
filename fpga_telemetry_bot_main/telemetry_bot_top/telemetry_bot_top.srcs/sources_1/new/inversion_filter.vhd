library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity inversion_filter is
    generic(
        data_width:         integer := 8;
        addr_width:         integer := 18;
        num_elements:       integer := 240_000
    );
    Port (
        clk:                in std_logic;
        rst:                in std_logic; 
        ena:                in std_logic;
        din0:               in std_logic_vector(data_width-1 downto 0);
        done:               out std_logic;
        wea:                out std_logic;
        addr0:              out std_logic_vector(addr_width-1 downto 0);
        output_a:           out std_logic_vector(addr_width-1 downto 0);
        output_d:           out std_logic_vector(data_width-1 downto 0)
    );
end inversion_filter;

architecture Behavioral of inversion_filter is

signal countV, countP, countH, countU: integer := 0; -- countV (kernel) countP(whole image)
signal pixel_result: integer := 0;
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
                    pixel_result <= 255 - to_integer(unsigned(din0));
                    output_d <= std_logic_vector(to_unsigned(pixel_result, output_d'length));
                    output_a <= std_logic_vector(to_unsigned(BASE_ADDR_W + countU, 18));
                    countP <= countP + 1;
                    countH <= countH + 1;
                    countU <= countU + 1;
                else
                    countV <= 0;
                    wea <= '1';
                    addr0 <= std_logic_vector(to_unsigned(BASE_ADDR_R + countP, 18));
                    pixel_result <= 255 - to_integer(unsigned(din0));
                    output_d <= std_logic_vector(to_unsigned(pixel_result, output_d'length));
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