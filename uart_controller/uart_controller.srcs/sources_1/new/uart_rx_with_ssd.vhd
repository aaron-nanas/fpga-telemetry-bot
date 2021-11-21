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
 
entity uart_rx_with_ssd is
    generic (
        g_clk_cycles_bit:       integer := 1085
    );
    port (
        i_clk:                  in std_logic;
        i_data_in_rx:           in std_logic;
        o_data_out_byte_rx:     out std_logic_vector(7 downto 0)
    );
end uart_rx_with_ssd;

architecture Behavioral of uart_rx_with_ssd is
    type t_state_type is (
        Idle,
        Rx_Start_Bit,
        Rx_Data,
        Rx_Stop_Bit,
        Rx_Done
    );
    
    signal UART_state:              t_state_type := Idle;
    signal s_baud_counter:          integer range 0 to (g_clk_cycles_bit-1) := 0;
    signal s_bit_counter:           integer range 0 to 7 := 0;
    signal s_data_out_byte_rx:      std_logic_vector(7 downto 0) := (others => '0');
    signal s_data_in_rx:            std_logic := '0';
    signal s_data_in_reg:           std_logic := '0';
    signal s_data_out_pulse:        std_logic := '0';
    constant c_baud_count_limit:    integer := (g_clk_cycles_bit-1)/2;
    signal data_out_integer:        integer := 0;    
   
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
        case (UART_state) is
            -- Wait for start bit to trigger the FSM
            when Idle =>
                s_baud_counter <= 0;
                s_bit_counter <= 0;
                s_data_out_pulse <= '0';
                
                if (s_data_in_rx = '0') then -- Indicates that the start bit has been detected
                    UART_state <= Rx_Start_Bit;
                else
                    UART_state <= Idle;
                end if;
            
            -- Indicates the start of incoming byte
            when Rx_Start_Bit =>
                if (s_baud_counter = c_baud_count_limit) then
                    if (s_data_in_rx = '0') then
                        s_baud_counter <= 0; -- Reset the counter when there is an incoming data stream
                        UART_state <= Rx_Data;
                    else
                        UART_state <= Idle;
                    end if;
                else
                    s_baud_counter <= s_baud_counter + 1;
                    UART_state <= Rx_Start_Bit; -- Remain in current state if counter has not reached baud count limit yet
                end if;
            
            -- Handle incoming serial data and store as a byte
            when Rx_Data =>
                if (s_baud_counter < g_clk_cycles_bit-1) then
                    s_baud_counter <= s_baud_counter + 1;
                    UART_state <= Rx_Data;
                else
                    s_baud_counter <= 0;
                    s_data_out_byte_rx(s_bit_counter) <= s_data_in_rx;
                    
                    if (s_bit_counter < 7) then
                        s_bit_counter <= s_bit_counter + 1;
                        UART_state <= Rx_Data;
                    else
                        s_bit_counter <= 0;
                        UART_state <= Rx_Stop_Bit;
                    end if;
                end if;
            
            -- Indicates the end of incoming byte
            when Rx_Stop_Bit =>
                if (s_baud_counter < g_clk_cycles_bit-1) then
                    s_baud_counter <= s_baud_counter + 1;
                    UART_state <= Rx_Stop_Bit;    
                else
                    s_baud_counter <= 0;
                    UART_state <= Rx_Done;
                end if;
            
            -- Indicates when a byte has been fully received
            when Rx_Done =>
                data_out_integer <= to_integer(unsigned(s_data_out_byte_rx));
                UART_state <= Idle;
                s_data_out_pulse <= '1'; -- Pulse to indicate that a byte has been received
            
            when others =>
                UART_state <= Idle;
        end case;
    end if;
end process proc_Rx;

o_data_out_byte_rx <= s_data_out_byte_rx;
   
end Behavioral;