
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity top_level_filter_test is
--    Port ( );
end top_level_filter_test;

architecture Behavioral of top_level_filter_test is
component average_filter_fsm is
    Port ( clk: in std_logic;
           rst: in std_logic;
           ena: in std_logic;
           done: out std_logic;
           addr0: out std_logic_vector(17 downto 0);
           din0: in std_logic_vector(7 downto 0);
           wea: out std_logic;
           output_a: out std_logic_vector(7 downto 0);
           output_d: out std_logic_vector(7 downto 0));
end component average_filter_fsm;
begin


end Behavioral;
