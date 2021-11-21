-- Author: Aaron Nanas
-- File: inferred_bram_for_image.vhd
--
-- Function: Used to store an input image matrix's values coming from
-- the Raspberry Pi's Tx pin. This BRAM can then be used to transmit back
-- the filtered image to the Raspberry Pi via UART
--
-- Block Ram Configuration:
--     Single Port Block RAM with registered outputs
--     Data Width: 8 bits
--     Address Width: 18 bits (with 240,000 elements)
--     Enabled option for registered outputs when reading
--     Parameterized allowed number of elements & data and address widths

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity inferred_bram_for_image is
    generic(
        data_width:         integer := 8;
        addr_width:         integer := 18;
        num_elements:       integer := 240_000
    );
    Port (
        i_clk:              in std_logic;
        write_ena:          in std_logic;
        read_enable:        in std_logic;
        addr:               in std_logic_vector(addr_width-1 downto 0);
        data_in:            in std_logic_vector(data_width-1 downto 0);
        data_out:           out std_logic_vector(data_width-1 downto 0)
    );
end inferred_bram_for_image;

architecture Behavioral of inferred_bram_for_image is
    type ram_type is array (num_elements downto 0) of std_logic_vector(data_width-1 downto 0);
    signal single_port_bram: ram_type;
    signal data_out_reg: std_logic_vector(data_width-1 downto 0);

begin

write_bram_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (write_ena = '1') then
            single_port_bram(conv_integer(addr)) <= data_in;
        end if;
        data_out_reg <= single_port_bram(conv_integer(addr));
    end if;
end process write_bram_proc;

read_bram_registered_output_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (read_enable = '1') then
            data_out <= data_out_reg;
        end if;
    end if;
end process read_bram_registered_output_proc;

end Behavioral;
