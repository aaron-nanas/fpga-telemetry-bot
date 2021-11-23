-- Author: Aaron Nanas
-- File: uart_rx.vhd
-- The purpose of this is to receive 8 bits of serial data,
-- which will be coming from the TX pin of the ESP32
--
-- For this UART Rx, the config is:
-- One start bit
-- One stop bit
-- No parity bit
-- Receives incoming 8 bits of serial data
--
-- The number of clocks needed for a given baud rate can be calculated as follows:
-- (Clock Frequency / Baud Rate)
-- Example:
--      (125 MHz / 115200) = 1085

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
 
entity uart_rx is
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
end uart_rx;

architecture Behavioral of uart_rx is
    type t_state_type is (
        Idle,
        Rx_Start_Bit,
        Rx_Data,
        Rx_Stop_Bit,
        Rx_Done,
        Rx_Store_in_BRAM,
        Rx_BRAM_Full
    );
    
    signal Rx_UART_State:           t_state_type := Idle;
    signal s_baud_counter:          integer range 0 to (g_clk_cycles_bit-1) := 0;
    signal s_rx_bit_counter:        integer range 0 to (data_width-1) := 0;
    signal s_data_out_byte_rx:      std_logic_vector(data_width-1 downto 0) := (others => '0');
    signal s_data_in_rx:            std_logic := '0';
    signal s_data_in_reg:           std_logic := '0';
    constant c_baud_count_limit:    integer := (g_clk_cycles_bit-1)/2;
    
    signal rx_num_counter_reg:      integer := 0;
   
begin

proc_incoming_data: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        s_data_in_reg <= i_data_in_rx;
        s_data_in_rx <= s_data_in_reg;
    end if;  
end process proc_incoming_data;

proc_Rx: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            rx_num_counter_reg <= 0;
            Rx_UART_State <= Idle;
            o_led <= "0000";
        else
            case (Rx_UART_State) is
                -- Wait for start bit to trigger the FSM
                when Idle =>
                    o_led <= "0000";
                    s_baud_counter <= 0;
                    s_rx_bit_counter <= 0;
                    o_rx_dv <= '0';
                    
                    if (s_data_in_rx = '0') then
                        Rx_UART_State <= Rx_Start_Bit;
                    else
                        Rx_UART_State <= Idle;
                    end if;
                
                -- Indicates the start of incoming byte
                when Rx_Start_Bit =>
                    if (s_baud_counter = c_baud_count_limit) then
                        if (s_data_in_rx = '0') then
                            s_baud_counter <= 0; -- Reset the counter when there is an incoming data stream
                            Rx_UART_State <= Rx_Data;
                        else
                            Rx_UART_State <= Idle;
                        end if;
                    else
                        s_baud_counter <= s_baud_counter + 1;
                        Rx_UART_State <= Rx_Start_Bit; -- Remain in current state if counter has not reached baud count limit yet
                    end if;
                
                -- Handle incoming serial data and store as a byte
                when Rx_Data =>
                    if (s_baud_counter < g_clk_cycles_bit-1) then
                        s_baud_counter <= s_baud_counter + 1;
                        Rx_UART_State <= Rx_Data;
                    else
                        s_baud_counter <= 0;
                        s_data_out_byte_rx(s_rx_bit_counter) <= s_data_in_rx;
                        
                        if (s_rx_bit_counter < (data_width-1)) then
                            s_rx_bit_counter <= s_rx_bit_counter + 1;
                            Rx_UART_State <= Rx_Data;
                        else
                            s_rx_bit_counter <= 0;
                            Rx_UART_State <= Rx_Stop_Bit;
                        end if;
                    end if;
                
                -- Indicates the end of incoming byte
                when Rx_Stop_Bit =>
                    if (s_baud_counter < g_clk_cycles_bit-1) then
                        s_baud_counter <= s_baud_counter + 1;
                        Rx_UART_State <= Rx_Stop_Bit;    
                    else
                        s_baud_counter <= 0;
                        o_rx_dv <= '1'; -- Indicates that data has been fully received
                        Rx_UART_State <= Rx_Done;
                    end if;
                
                -- Indicates when a byte has been fully received
                when Rx_Done =>
                    o_rx_dv <= '0';
                    -- Write the image matrix and read what is being written
                    -- Initially, set these signals high when initializing the BRAM
                    -- with the image matrix
                    if (write_enable = '1' and read_enable = '1') then
                        Rx_UART_State <= Rx_Store_in_BRAM;
                        
                    -- When read_enable is 1, do not store incoming data to BRAM (i.e. write_enable = '0')
                    -- This assumes that the image matrix has already been stored
                    -- read_enable should be set 1 after writing the image matrix
                    -- During this, the address will increment using the tx_num_counter,
                    -- and the Rx side will provide the o_rx_dv pulse to the Tx
                    elsif (write_enable = '0' and read_enable = '1') then
                        Rx_UART_State <= Idle;
                    else
                        Rx_UART_State <= Idle;
                    end if;
                    
                when Rx_Store_in_BRAM =>

                    if (rx_num_counter_reg < num_elements-1) then
                        Rx_UART_State <= Idle;
                        rx_num_counter_reg <= rx_num_counter_reg + 1;
                    else
                        if (write_enable = '0') then
                            Rx_UART_State <= Idle;
                            rx_num_counter_reg <= 0;
                        else
                            Rx_UART_State <= Rx_BRAM_Full;
                            rx_num_counter_reg <= rx_num_counter_reg;
                        end if;
                    end if;

                when Rx_BRAM_Full =>
                    o_led <= "1010";
                    if (write_enable = '0') then
                        Rx_UART_State <= Idle;
                    else
                        Rx_UART_State <= Rx_BRAM_Full;
                    end if;
                
                when others =>
                    Rx_UART_State <= Idle;
            end case;
        end if;
    end if;
end process proc_Rx;

o_data_out_byte_rx <= s_data_out_byte_rx;
rx_num_counter <= rx_num_counter_reg;

end Behavioral;