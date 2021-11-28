library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity tb_top_fsm_controller is
    generic(
        data_width:                         integer := 8;
        addr_width:                         integer := 18;
        filters_width:                      integer := 8;
        num_instruction_bytes:              integer := 3;
        instruction_reg_width:              integer := 24;
        num_elements_input:                 integer := 242_004;
        num_elements_output:                integer := 240_000;
        g_clk_cycles_bit:                   integer := 135 -- Baud rate set to 921600
    );
end tb_top_fsm_controller;

architecture Behavioral of tb_top_fsm_controller is

component top_fsm_controller is
    generic(
        data_width:                         integer := 8;
        addr_width:                         integer := 18;
        filters_width:                      integer := 8;
        num_instruction_bytes:              integer := 3;
        instruction_reg_width:              integer := 24;
        num_elements_input:                 integer := 242_004;
        num_elements_output:                integer := 240_000;
        g_clk_cycles_bit:                   integer := 135 -- Baud rate set to 921600
    );
    Port (
        i_clk:                              in std_logic;
        i_reset:                            in std_logic;
        i_data_in_rx:                       in std_logic;
        write_enable_input_bram:            in std_logic;
        read_enable_input_bram:             in std_logic;
        write_enable_output_bram:           in std_logic;
        read_enable_output_bram:            in std_logic;
        i_rx_instruction_active:            in std_logic;
        o_tx_serial_data:                   out std_logic;
        o_led:                              out std_logic_vector(3 downto 0)
    );
end component top_fsm_controller;

signal i_clk: std_logic;
signal i_reset: std_logic;
signal i_data_in_rx: std_logic;
signal write_enable_input_bram: std_logic := '0';
signal read_enable_input_bram: std_logic := '0';
signal write_enable_output_bram: std_logic := '0';
signal read_enable_output_bram: std_logic := '0';
signal i_rx_instruction_active: std_logic := '0';
signal o_tx_serial_data: std_logic;
signal o_led: std_logic_vector(3 downto 0) := (others => '0');
constant clk_per: time := 8 ns;
constant uart_bit_period: time := 1085 ns;
begin

UUT_top_fsm_controller: top_fsm_controller
    generic map(
        data_width => data_width,
        addr_width => addr_width,
        filters_width => filters_width,
        num_instruction_bytes => num_instruction_bytes,
        instruction_reg_width => instruction_reg_width,
        num_elements_input => num_elements_input,
        num_elements_output => num_elements_output,
        g_clk_cycles_bit => g_clk_cycles_bit
    )
    port map(
        i_clk => i_clk,
        i_reset => i_reset,
        i_data_in_rx => i_data_in_rx,
        write_enable_input_bram => write_enable_input_bram,
        read_enable_input_bram => read_enable_input_bram,
        write_enable_output_bram => write_enable_output_bram,
        read_enable_output_bram => read_enable_output_bram,
        i_rx_instruction_active => i_rx_instruction_active,
        o_tx_serial_data => o_tx_serial_data,
        o_led => o_led
    );

clk_proc: process
begin
    i_clk <= '0';
    wait for clk_per/2;
    
    i_clk <= '1';
    wait for clk_per/2;
end process clk_proc;

reset_proc: process
begin
    i_reset <= '1';
    wait for clk_per;
    
    i_reset <= '0';
    wait for clk_per;
    wait;
end process reset_proc;

test_fsm_proc: process
begin
    wait until rising_edge(i_clk);
    wait until rising_edge(i_clk);
    
    -- Idle bit
    i_data_in_rx <= '1'; i_rx_instruction_active <= '1';
    wait for uart_bit_period;
    
    -- Start bit for Rx
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
------------- Start of Bit Vector -----------------
    -- Serially send out bit vector of "10001110"
    -- Note: LSB goes first
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '0';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
------------- End of Bit vector -----------------
    
    -- Stop bit for rx
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    -- Idle bit for rx
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    -- Start bit
    i_data_in_rx <= '0';
    wait for uart_bit_period;

------------- Start of Bit Vector -----------------
    -- Send out bit vector of "10101010"
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

------------- End of Bit vector -----------------

    -- Idle bit
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    -- Start bit for Rx
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
------------- Start of Bit Vector -----------------
    -- Serially send out bit vector of "10001111"
    -- Note: LSB goes first
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '0';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
------------- End of Bit vector -----------------
    
    -- Stop bit for rx
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    -- Idle bit for rx
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    -- Start bit for Rx
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
------------- Start of Bit Vector -----------------
    -- Serially send out bit vector of "10001111"
    -- Note: LSB goes first
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;

    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    
    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
    i_data_in_rx <= '0';
    wait for uart_bit_period;

    i_data_in_rx <= '0';
    wait for uart_bit_period;
    
------------- End of Bit vector -----------------
    
    -- Stop bit for rx
    i_data_in_rx <= '1'; i_rx_instruction_active <= '0';
    wait for uart_bit_period;
    
    -- Idle bit for rx
    i_data_in_rx <= '1';
    wait for uart_bit_period;
    wait;

end process test_fsm_proc;

end Behavioral;
