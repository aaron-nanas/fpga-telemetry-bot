-- Author: Aaron Nanas
-- File: image_rx_tx_with_filter.vhd
-- The purpose of this is to bridge the spatial filter controller
-- and the UART Rx/Tx. First, the image matrix gets sent from the Raspberry Pi
-- to the FPGA's BRAM. After the selected spatial filter has been applied,
-- the output image matrix is stored in a separate BRAM.
-- The contents of the new BRAM is transmitted to the Raspberry Pi.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity image_rx_tx_with_filter is
    generic(
        data_width:                 integer := 8;
        addr_width:                 integer := 18;
        filters_width:              integer := 8;
        num_elements_input:         integer := 242_004;
        num_elements_output:        integer := 240_000;
        num_instruction_bytes:      integer := 3;
        instruction_reg_width:      integer := 24;
        g_clk_cycles_bit:           integer := 135 -- Baud rate set to 921600
    );
    Port (
        i_clk:                      in std_logic;
        i_reset:                    in std_logic;
        i_data_in_rx:               in std_logic;
        write_enable_input_bram:    in std_logic;
        read_enable_input_bram:     in std_logic;
        write_enable_output_bram:   in std_logic;
        read_enable_output_bram:    in std_logic;
        rx_instruction_active:      in std_logic;
        i_start_filtering:          in std_logic;
        i_rx_instruction_in:        in std_logic;
        i_rx_image_in:              in std_logic;
        filter_select:              in std_logic_vector(filters_width-1 downto 0);
        threshold_value:            in std_logic_vector(filters_width-1 downto 0);
        o_tx_serial_data:           out std_logic;
        o_rx_instruction_done:      out std_logic;
        o_rx_instruction_reg:       out std_logic_vector(instruction_reg_width-1 downto 0);
        filter_done:                out std_logic;
        o_led:                      out std_logic_vector(3 downto 0)
    );
end image_rx_tx_with_filter;

architecture Behavioral of image_rx_tx_with_filter is

component uart_tx is
    generic (
        g_clk_cycles_bit:           integer := 1085;
        num_elements_input:         integer := 242_004;
        num_elements_output:        integer := 240_000;
        data_width:                 integer := 8
    );
    
    Port (
        i_clk:                      in std_logic;
        i_reset:                    in std_logic;
        i_tx_data_byte:             in std_logic_vector(data_width-1 downto 0);
        i_tx_dv:                    in std_logic;
        write_enable_input_bram:    in std_logic;
        read_enable_input_bram:     in std_logic;
        write_enable_output_bram:   in std_logic;
        read_enable_output_bram:    in std_logic;
        o_tx_active:                out std_logic;
        o_tx_serial_data:           out std_logic;
        o_tx_done:                  out std_logic;
        tx_num_counter:             out integer
    );
end component uart_tx;

component uart_rx is
    generic (
        g_clk_cycles_bit:           integer := 1085;
        num_elements_input:         integer := 242_004;
        num_elements_output:        integer := 240_000;
        data_width:                 integer := 8
    );
    port (
        i_clk:                      in std_logic;
        i_reset:                    in std_logic;
        i_data_in_rx:               in std_logic;
        write_enable_input_bram:    in std_logic;
        read_enable_input_bram:     in std_logic;
        write_enable_output_bram:   in std_logic;
        read_enable_output_bram:    in std_logic;
        o_data_out_byte_rx:         out std_logic_vector(data_width-1 downto 0);
        o_rx_dv:                    out std_logic;
        rx_num_counter:             out integer
    );
end component uart_rx;

component uart_rx_for_fsm is
    generic (
        g_clk_cycles_bit:           integer := 135;
        data_width:                 integer := 8;
        num_instruction_bytes:      integer := 3;
        instruction_reg_width:      integer := 24
    );
    port (
        i_clk:                              in std_logic;
        i_reset:                            in std_logic;
        i_data_in_rx:                       in std_logic;
        rx_instruction_active:              in std_logic;
        o_data_out_byte_rx:                 out std_logic_vector(data_width-1 downto 0);
        o_rx_dv:                            out std_logic;
        rx_num_counter:                     out integer;
        o_rx_instruction_done:              out std_logic;
        o_data_out_byte_rx_instruction:     out std_logic_vector(instruction_reg_width-1 downto 0);
        o_led:                              out std_logic_vector(3 downto 0)
    );
end component uart_rx_for_fsm;

component top_level_filter_fsm is
    generic(
        data_width:                 integer := 8;
        addr_width:                 integer := 18;
        filters_width:              integer := 2;
        num_elements_input:         integer := 242_004;
        num_elements_output:        integer := 240_000
    );
    Port (  clk, rst: in std_logic;
            wea1, wea2, rea1, rea2: in  std_logic;
            start_filtering: in std_logic;
            filter_select: in std_logic_vector(filters_width-1 downto 0);
            threshold_value: in std_logic_vector(filters_width-1 downto 0);
            bram1_a, bram2_a: in std_logic_vector(addr_width-1 downto 0);
            bram1_din, bram2_din: in std_logic_vector(data_width-1 downto 0);
            bram1_dout, bram2_dout: out std_logic_vector(data_width-1 downto 0);
            o_led: out std_logic_vector(3 downto 0);
            done, busy: out std_logic
            );
end component top_level_filter_fsm;

---- BRAM Signals
signal data_out_from_bram_reg:      std_logic_vector(data_width-1 downto 0);

-- Rx Signals
signal data_out_byte_from_rx_reg:   std_logic_vector(data_width-1 downto 0);
signal rx_num_counter:              integer;
signal rx_instruction_num_counter:  integer;

-- Tx Signals
signal tx_num_counter:              integer := 0;
signal o_tx_active:                 std_logic;
signal o_tx_done:                   std_logic;

-- Rx/Tx DV flag (Data Valid)
signal rx_tx_dv_flag:               std_logic;

-- Top-Level Filter FSM Signals 
signal bram_input_addr:             std_logic_vector(addr_width-1 downto 0);
signal bram_output_addr:            std_logic_vector(addr_width-1 downto 0);
signal bram_input_data_in:          std_logic_vector(data_width-1 downto 0);
signal bram_input_data_out:         std_logic_vector(data_width-1 downto 0);
signal bram_output_data_in:         std_logic_vector(data_width-1 downto 0);
signal bram_output_data_out:        std_logic_vector(data_width-1 downto 0);
--signal done:                        std_logic;
signal busy:                        std_logic;

-- Rx Instruction Signals
signal rx_instruction_byte_reg:     std_logic_vector(data_width-1 downto 0);
signal rx_instruction_dv:           std_logic;
signal rx_instruction_done_flag:    std_logic;
signal rx_instruction_reg:          std_logic_vector(instruction_reg_width-1 downto 0);
signal rx_active_mode:              std_logic_vector(7 downto 0);

begin

uart_rx_instance: uart_rx
    generic map(
        g_clk_cycles_bit            => g_clk_cycles_bit,
        num_elements_input          => num_elements_input,
        num_elements_output         => num_elements_output,
        data_width                  => data_width
    )
    port map(
        i_clk                       => i_clk,
        i_reset                     => i_reset,
        i_data_in_rx                => i_rx_image_in,
        write_enable_input_bram     => write_enable_input_bram,
        read_enable_input_bram      => read_enable_input_bram,
        write_enable_output_bram    => write_enable_output_bram,
        read_enable_output_bram     => read_enable_output_bram,
        o_data_out_byte_rx          => data_out_byte_from_rx_reg,
        o_rx_dv                     => rx_tx_dv_flag,
        rx_num_counter              => rx_num_counter
    );

uart_rx_for_fsm_instance: uart_rx_for_fsm
    generic map(
        g_clk_cycles_bit => g_clk_cycles_bit,
        data_width => data_width,
        num_instruction_bytes => num_instruction_bytes,
        instruction_reg_width => instruction_reg_width
    )
    port map(
        i_clk => i_clk,
        i_reset => i_reset,
        i_data_in_rx => i_rx_instruction_in,
        rx_instruction_active => rx_instruction_active,
        o_data_out_byte_rx => rx_instruction_byte_reg,
        o_rx_dv => rx_instruction_dv,
        rx_num_counter => rx_instruction_num_counter,
        o_rx_instruction_done => rx_instruction_done_flag,
        o_data_out_byte_rx_instruction => rx_instruction_reg,
        o_led => o_led
    );

uart_tx_instance: uart_tx
    generic map(
        g_clk_cycles_bit            => g_clk_cycles_bit,
        num_elements_input          => num_elements_input,
        num_elements_output         => num_elements_output,
        data_width                  => data_width
    )
    port map(
        i_clk                       => i_clk,
        i_reset                     => i_reset,
        i_tx_data_byte              => data_out_from_bram_reg,
        i_tx_dv                     => rx_tx_dv_flag,
        write_enable_input_bram     => write_enable_input_bram,
        read_enable_input_bram      => read_enable_input_bram,
        write_enable_output_bram    => write_enable_output_bram,
        read_enable_output_bram     => read_enable_output_bram,
        o_tx_active                 => o_tx_active,
        o_tx_serial_data            => o_tx_serial_data,
        o_tx_done                   => o_tx_done,
        tx_num_counter              => tx_num_counter
    );

top_level_filter_fsm_instance: top_level_filter_fsm
    generic map(
        data_width                  => data_width,
        addr_width                  => addr_width,
        filters_width               => filters_width,
        num_elements_input          => num_elements_input,
        num_elements_output         => num_elements_output
    )
    port map(
        clk                         => i_clk,
        rst                         => i_reset,
        wea1                        => write_enable_input_bram,
        wea2                        => write_enable_output_bram,
        rea1                        => read_enable_input_bram,
        rea2                        => read_enable_output_bram,
        start_filtering             => i_start_filtering,
        filter_select               => filter_select,
        threshold_value             => threshold_value,
        bram1_a                     => bram_input_addr,
        bram2_a                     => bram_output_addr,
        bram1_din                   => bram_input_data_in,
        bram2_din                   => bram_output_data_in,
        bram1_dout                  => bram_input_data_out,
        bram2_dout                  => bram_output_data_out,
        done                        => filter_done,
        busy                        => busy,
        o_led                       => o_led
    );

addr_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (write_enable_input_bram = '1' and read_enable_input_bram = '1' and write_enable_output_bram = '0' and read_enable_output_bram = '0') then
            bram_input_addr <= std_logic_vector(to_unsigned(rx_num_counter, bram_input_addr'length));
            bram_input_data_in <= data_out_byte_from_rx_reg;
            data_out_from_bram_reg <= bram_input_data_out;
        elsif (write_enable_input_bram = '0' and read_enable_input_bram = '0' and write_enable_output_bram = '0' and read_enable_output_bram = '1') then
            bram_output_addr <= std_logic_vector(to_unsigned(tx_num_counter, bram_output_addr'length));
            bram_output_data_in <= data_out_byte_from_rx_reg;
            data_out_from_bram_reg <= bram_output_data_out;
        end if;
   end if;
end process addr_proc;

o_rx_instruction_reg <= rx_instruction_reg;
o_rx_instruction_done <= rx_instruction_done_flag;

end Behavioral;