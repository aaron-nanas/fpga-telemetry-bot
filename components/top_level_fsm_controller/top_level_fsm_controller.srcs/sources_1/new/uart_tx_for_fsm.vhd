-- Author: Aaron Nanas
-- File: uart_tx.vhd
-- Purpose: Transmit an 8-bit data serially to the Raspberry Pi's RX pin
--
-- The number of clocks needed for a given baud rate can be calculated as follows:
-- (Clock Frequency / Baud Rate)
-- Example:
--      (125 MHz / 921600) = 135

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity uart_tx_for_fsm is
    generic (
        g_clk_cycles_bit:           integer := 135;
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
end uart_tx_for_fsm;

architecture Behavioral of uart_tx_for_fsm is
    type t_state_type is (
        Idle,
        Tx_Start_Bit,
        Tx_Serial_Data,
        Tx_Stop_Bit,
        Tx_Done
    );   
    signal Tx_UART_State:           t_state_type := Idle;
    signal s_baud_counter:          integer range 0 to (g_clk_cycles_bit-1) := 0;
    signal s_tx_bit_counter:        integer range 0 to (data_width-1) := 0;
    signal s_data_byte_tx:          std_logic_vector(data_width-1 downto 0) := (others => '0');
    
    -- Signals for transmitting image matrix
    signal tx_num_counter_reg:      integer := 0;

begin

proc_Tx: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            Tx_UART_State <= Idle;
            tx_num_counter_reg <= 0;
        else
            case (Tx_UART_State) is
                -- Idle state for Tx
                -- Waits for the start bit to be high after FPGA fully receives data from the Raspberry Pi
                when Idle =>
                    o_tx_active <= '0';
                    o_tx_serial_data <= '1';
                    o_tx_done <= '0';
                    s_baud_counter <= 0;
                    s_tx_bit_counter <= 0;
                    
                    if (i_tx_dv = '1') then
                        Tx_UART_State <= Tx_Start_Bit;
                        s_data_byte_tx <= i_tx_data_byte;
                    else
                        Tx_UART_State <= Idle;
                    end if;
                
                -- State that sends out the start bit = 0
                when Tx_Start_Bit =>
                    o_tx_active <= '1';
                    o_tx_serial_data <= '0';
                    
                    if (s_baud_counter < g_clk_cycles_bit-1) then
                        s_baud_counter <= s_baud_counter + 1;
                        Tx_UART_State <= Tx_Start_Bit;
                    else
                        s_baud_counter <= 0;
                        Tx_UART_State <= Tx_Serial_Data;
                    end if;
                
                -- Begin the data transmittion to the Raspberry Pi's RX pin    
                when Tx_Serial_Data =>
                    o_tx_serial_data <= s_data_byte_tx(s_tx_bit_counter); -- Create the byte for Tx
                    
                    if (s_baud_counter < g_clk_cycles_bit-1) then
                        s_baud_counter <= s_baud_counter + 1;
                        Tx_UART_State <= Tx_Serial_Data;
                    else
                        s_baud_counter <= 0;
                        if (s_tx_bit_counter < (data_width-1)) then
                            s_tx_bit_counter <= s_tx_bit_counter + 1;
                            Tx_UART_State <= Tx_Serial_Data;
                        else
                            s_tx_bit_counter <= 0;
                            Tx_UART_State <= Tx_Stop_Bit;
                        end if;
                    end if;
                    
                -- After data transmission, set the stop bit to '1'
                when Tx_Stop_Bit =>
                    o_tx_serial_data <= '1';
                    
                    if (s_baud_counter < g_clk_cycles_bit-1) then
                        s_baud_counter <= s_baud_counter + 1;
                        Tx_UART_State <= Tx_Stop_Bit;
                    else
                        o_tx_done <= '1';
                        s_baud_counter <= 0;
                        Tx_UART_State <= Tx_Done;
                    end if;
                    
                when Tx_Done =>
                    o_tx_active <= '0';
                    o_tx_done <= '1';
                    Tx_UART_State <= Idle;
    
                when others =>
                    Tx_UART_State <= Idle;
            end case;
        end if;
    end if;
end process proc_Tx;

tx_num_counter <= tx_num_counter_reg;

end Behavioral;