-- Author: Aaron Nanas
-- File: maxsonar_sensor.vhd
-- Purpose:
--      Interfaces the Pmod MAXSONAR: Maxbotix Ultrasonic Range Finder
--      Updates the distance every 2 Hz via the clock divider
--      Includes a decoder for the Pmod Seven-Segment Display
--      Displays this range in hexadecimal form on the Pmod Seven-Segment Display

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity maxsonar_sensor is
    generic (
        clk_freq:                   integer := 125
    );
    port (
        i_clk:                      in std_logic;
        i_reset:                    in std_logic;
        sensor_pulse:               in std_logic;
        sensor_enable:              out std_logic;
        max_close_distance_flag:    out std_logic;
        sensor_distance:            out std_logic_vector(7 downto 0);
        o_ssd:                      out std_logic_vector(6 downto 0);
        o_ssd_cat:                  out std_logic
    );
end maxsonar_sensor;

architecture Behavioral of maxsonar_sensor is

component clock_divider is
    Port(
        i_clk:                      in std_logic; -- Main clock
        i_reset:                    in std_logic; -- Active high reset
        o_clk_2Hz:                  out std_logic -- Slower frequency clock
    );
end component clock_divider;

signal sensor_distance_reg:         std_logic_vector(7 downto 0);
signal sensor_pulse_previous:       std_logic := '0';
signal delay_2Hz:                   std_logic;

-- Signals for Pmod SSD
signal distance_nibble:             std_logic_vector(3 downto 0);
signal sensor_distance_rearranged:  std_logic_vector(7 downto 0);
signal ssd_counter:                 integer := 0;
signal ssd_pulse:                   std_logic := '0';
signal ssd_cat_signal:              std_logic := '0';

begin

clock_divider_instance: clock_divider
    port map(
        i_clk => i_clk,
        i_reset => i_reset,
        o_clk_2Hz => delay_2Hz
    );

read_sensor_proc: process(i_clk)
    variable sub_inch_counter:      integer := 0;
    variable inch_counter:          integer := 0;
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            sub_inch_counter := 0;
        else
            if (delay_2Hz = '1') then
                sensor_pulse_previous <= sensor_pulse;
                if (sensor_pulse = '1') then
                    if (sub_inch_counter < (147 * clk_freq)) then
                        sub_inch_counter := sub_inch_counter + 1;
                    else
                        sub_inch_counter := 0;
                        inch_counter := inch_counter + 1;
                    end if;
                end if;
                
                if (sensor_pulse_previous = '1' and sensor_pulse = '0') then
                    sensor_distance_reg <= std_logic_vector(to_unsigned(inch_counter, sensor_distance_reg'length));
                    sub_inch_counter := 0;
                    inch_counter := 0;
                end if;
            end if;
        end if;
    end if;
end process read_sensor_proc;

binary_to_hex_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        case (distance_nibble) is
            when "0000" =>
                o_ssd <= "1111110";
            when "0001" =>
                o_ssd <= "0110000";
            when "0010" =>
                o_ssd <= "1101101";
            when "0011" =>
                o_ssd <= "1111001";
            when "0100" =>
                o_ssd <= "0110011";          
            when "0101" =>
                o_ssd <= "1011011";
            when "0110" =>
                o_ssd <= "1011111";
            when "0111" =>
                o_ssd <= "1110000";
            when "1000" =>
                o_ssd <= "1111111";
            when "1001" =>
                o_ssd <= "1110011";
            when "1010" =>
                o_ssd <= "1110111";
            when "1011" =>
                o_ssd <= "0011111";
            when "1100" =>
                o_ssd <= "1001110";
            when "1101" =>
                o_ssd <= "0111101";
            when "1110" =>
                o_ssd <= "1001111";
            when "1111" =>
                o_ssd <= "1000111";
        end case;
    end if;
end process binary_to_hex_proc;

ssd_counter_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (ssd_counter = 99999) then
            ssd_counter <= 0;
            ssd_pulse <= '1';
        else
            ssd_counter <= ssd_counter + 1;
            ssd_pulse <= '0';
        end if;
    end if;
end process;

ssd_pulse_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        o_ssd_cat <= ssd_cat_signal;
        if (ssd_pulse = '1') then
            ssd_cat_signal <= not(ssd_cat_signal);
        end if;
    end if;
end process;

close_distance_proc: process(i_clk)
begin
    if (rising_edge(i_clk)) then
        if (i_reset = '1') then
            max_close_distance_flag <= '0';
        else
            if (to_integer(unsigned(sensor_distance_reg)) < 9) then
                max_close_distance_flag <= '1';
            else
                max_close_distance_flag <= '0';
            end if;
        end if;
    end if;
end process close_distance_proc;

sensor_distance <= sensor_distance_reg;
sensor_distance_rearranged <= sensor_distance_reg(3 downto 0) & sensor_distance_reg(7 downto 4);
distance_nibble <= sensor_distance_rearranged(3 downto 0) when (ssd_cat_signal = '1') else sensor_distance_rearranged(7 downto 4);

end Behavioral;