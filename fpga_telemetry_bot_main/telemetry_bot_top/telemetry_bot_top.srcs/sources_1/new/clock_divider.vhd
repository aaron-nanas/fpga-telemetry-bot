library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity clock_divider is
    Port(
        i_clk:              in std_logic; -- Main clock
        i_reset:            in std_logic; -- Active high reset
        o_clk_2Hz:          out std_logic -- Slower frequency clock
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal s_clk_2Hz_counter: integer := 1;
    signal s_clk_2Hz: std_logic := '0';
    
    begin

clk_div_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then -- Synchronous reset signal
            s_clk_2Hz_counter <= 1;
            s_clk_2Hz <= '0';
        else
            s_clk_2Hz_counter <= s_clk_2Hz_counter + 1;
            -- Formula: (Main Clock Freq / (Desired Frequency / 50% Duty Cycle))
            -- Example: (125 MHz / (2 Hz / 0.5)) -> Count = 31250000
            if (s_clk_2Hz_counter = 31250000) then
                -- Toggle between 0 and 1 every time the counter reaches the final value
                -- Triggered every second
                s_clk_2Hz <= not s_clk_2Hz;
                s_clk_2Hz_counter <= 1;
            end if;
        end if;
    end if;
 end process clk_div_proc;
    
 o_clk_2Hz <= s_clk_2Hz;
     
end Behavioral;