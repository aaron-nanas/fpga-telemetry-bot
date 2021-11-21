library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity tb_inferred_bram_for_image is
    generic(
        data_width:             integer := 8;
        addr_width:             integer := 18;
        num_elements:           integer := 240_000
    );
end tb_inferred_bram_for_image;

architecture Behavioral of tb_inferred_bram_for_image is

component inferred_bram_for_image is
    generic(
        data_width:             integer := 8;
        addr_width:             integer := 18;
        num_elements:           integer := 240_000
    );
    Port (
        i_clk:                  in std_logic;
        write_ena:              in std_logic;
        read_enable:            in std_logic;
        addr:                   in std_logic_vector(addr_width-1 downto 0);
        data_in:                in std_logic_vector(data_width-1 downto 0);
        data_out:               out std_logic_vector(data_width-1 downto 0)
    );
end component inferred_bram_for_image;

signal i_clk:                   std_logic;
signal write_ena:               std_logic := '0';
signal read_enable:             std_logic := '0';
signal addr:                    std_logic_vector(addr_width-1 downto 0);
signal data_in:                 std_logic_vector(data_width-1 downto 0) := (others => '0');
signal data_out:                std_logic_vector(data_width-1 downto 0) := (others => '0');
signal addr_counter:            integer := 0;
signal data_as_integer:         integer := 0;
signal read_bram_counter:       integer := 0;

-- Flag to indicate if there are 240,000 elements in the BRAM
signal write_to_bram_done:      boolean := false;

constant clk_per:               time := 8 ns; -- 125 MHz Clock

begin

DUT_single_port_bram: inferred_bram_for_image
    generic map (
        data_width => data_width,
        addr_width => addr_width,
        num_elements => num_elements
    )
    port map (
        i_clk => i_clk,
        write_ena => write_ena,
        read_enable => read_enable,
        addr => addr,
        data_in => data_in,
        data_out => data_out
    );

clk_proc: process
begin
    i_clk <= '0';
    wait for clk_per/2;
    
    i_clk <= '1';
    wait for clk_per/2;
end process clk_proc;

-- Write data to BRAM while incrementing its address value
-- Then, when it has finished writing to BRAM, it sets a done flag high (i.e. write_to_bram_done = true)
write_bram_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        data_as_integer <= to_integer(unsigned(data_in)); -- Convert data_in to integer
        data_in <= std_logic_vector(to_unsigned(data_as_integer, data_in'length)); -- Then, typecast data_as_integer back to std_logic_vector
        
        if (addr_counter < num_elements) then
            write_to_bram_done <= false;
            write_ena <= '1';
            read_enable <= '0';
            addr <= std_logic_vector(to_unsigned(addr_counter, addr'length));
            addr_counter <= addr_counter + 1;
            data_as_integer <= data_as_integer + 1;
        else
            write_to_bram_done <= true;
            data_as_integer <= 0;
            addr_counter <= addr_counter;
            write_ena <= '0';
            read_enable <= '1';
            addr <= std_logic_vector(to_unsigned(read_bram_counter, addr'length));
        end if;  
   
    end if;
end process write_bram_proc;

read_bram_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (read_enable = '1' and write_to_bram_done = true) then
            if (read_bram_counter < num_elements) then
                read_bram_counter <= read_bram_counter + 1;
            else
                read_bram_counter <= read_bram_counter;
            end if;
        end if;
    end if;
end process read_bram_proc;

end Behavioral;
