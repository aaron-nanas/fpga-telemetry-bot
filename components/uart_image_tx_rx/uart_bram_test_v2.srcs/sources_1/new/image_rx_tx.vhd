library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity image_rx_tx is
    generic(
        data_width:         integer := 8;
        addr_width:         integer := 18;
        num_elements:       integer := 240_000;
        g_clk_cycles_bit:   integer := 1085
    );
    Port (
        i_clk:              in std_logic;
        i_reset:            in std_logic;
        i_data_in_rx:       in std_logic;
        write_enable:       in std_logic;
        read_enable:        in std_logic;
        o_tx_serial_data:   out std_logic;
        o_led:              out std_logic_vector(3 downto 0)
    );
end image_rx_tx;

architecture Behavioral of image_rx_tx is

component inferred_bram_for_image is
    generic(
        data_width:         integer := 8;
        addr_width:         integer := 18;
        num_elements:       integer := 240_000
    );
    Port (
        i_clk:              in std_logic;
        write_enable:       in std_logic;
        read_enable:        in std_logic;
        addr:               in std_logic_vector(addr_width-1 downto 0);
        data_in:            in std_logic_vector(data_width-1 downto 0);
        data_out:           out std_logic_vector(data_width-1 downto 0)
    );
end component inferred_bram_for_image;

component uart_tx is
    generic (
        g_clk_cycles_bit:       integer := 1085;
        num_elements:           integer := 240_000;
        data_width:             integer := 8
    );
    
    Port (
        i_clk:                  in std_logic;
        i_reset:                in std_logic;
        i_tx_data_byte:         in std_logic_vector(data_width-1 downto 0);
        i_tx_dv:                in std_logic;
        write_enable:           in std_logic;
        read_enable:            in std_logic;
        o_tx_active:            out std_logic;
        o_tx_serial_data:       out std_logic;
        o_tx_done:              out std_logic;
        tx_num_counter:         out integer;
        o_led:                  out std_logic_vector(3 downto 0)
    );
end component uart_tx;

component uart_rx is
    generic (
        g_clk_cycles_bit:       integer := 1085;
        num_elements:           integer := 240_000;
        data_width:             integer := 8
    );
    port (
        i_clk:                  in std_logic;
        i_reset:                in std_logic;
        i_data_in_rx:           in std_logic;
        write_enable:           in std_logic;
        read_enable:            in std_logic;
        o_data_out_byte_rx:     out std_logic_vector(data_width-1 downto 0);
        o_rx_dv:                out std_logic;
        rx_num_counter:         out integer;
        o_led:                  out std_logic_vector(3 downto 0)
    );
end component uart_rx;

-- BRAM Signals
signal addr:                            std_logic_vector(addr_width-1 downto 0);
signal data_out_from_bram_reg:          std_logic_vector(data_width-1 downto 0);

-- Rx Signals
signal data_out_byte_from_rx_reg:       std_logic_vector(data_width-1 downto 0);
signal rx_num_counter:                  integer := 0;

-- Tx Signals
signal tx_num_counter:                  integer := 0;
signal o_tx_active:                     std_logic;
signal o_tx_done:                       std_logic;

-- Rx/Tx DV flag (Data Valid)
signal rx_tx_dv_flag:                   std_logic;

begin

inferred_bram_for_image_instance: inferred_bram_for_image
    generic map(
        data_width => data_width,
        addr_width => addr_width,
        num_elements => num_elements
    )
    
    port map(
        i_clk => i_clk,
        write_enable => write_enable,
        read_enable => read_enable,
        addr => addr,
        data_in => data_out_byte_from_rx_reg,
        data_out => data_out_from_bram_reg
    );
    
uart_rx_instance: uart_rx
    generic map(
        g_clk_cycles_bit => g_clk_cycles_bit,
        num_elements => num_elements,
        data_width => data_width
    )
    port map(
        i_clk => i_clk,
        i_reset => i_reset,
        i_data_in_rx => i_data_in_rx,
        write_enable => write_enable,
        read_enable => read_enable,
        o_data_out_byte_rx => data_out_byte_from_rx_reg,
        o_rx_dv => rx_tx_dv_flag,
        rx_num_counter => rx_num_counter,
        o_led => o_led
    );

uart_tx_instance: uart_tx
    generic map(
        g_clk_cycles_bit => g_clk_cycles_bit,
        num_elements => num_elements,
        data_width => data_width
    )
    port map(
        i_clk => i_clk,
        i_reset => i_reset,
        i_tx_data_byte => data_out_from_bram_reg,
        i_tx_dv => rx_tx_dv_flag,
        write_enable => write_enable,
        read_enable => read_enable,
        o_tx_active => o_tx_active,
        o_tx_serial_data => o_tx_serial_data,
        o_tx_done => o_tx_done,
        tx_num_counter => tx_num_counter,
        o_led => o_led
    );

addr_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (write_enable = '1' and read_enable = '1') then
            addr <= std_logic_vector(to_unsigned(rx_num_counter, addr'length));
        elsif (write_enable = '0' and read_enable = '1') then
            addr <= std_logic_vector(to_unsigned(tx_num_counter, addr'length));
        end if;
   end if;

end process addr_proc;

end Behavioral;
