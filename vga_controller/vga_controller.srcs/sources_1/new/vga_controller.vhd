-- Author: Aaron Nanas
-- File: vga_controller.vhd
-- Modified From: https://github.com/Digilent/Zybo-Z7-20-Pmod-VGA
-- Purpose: Serves as the VGA controller that interfaces with the Pmod VGA.
-- This will output the original image to the monitor, and when the signal
-- to apply a filter is sent, it will display the filtered image.
-- A VGA-HDMI converter cable was used to connect the Pmod to a monitor.
-- 
-- For VGA timings, refer to the table from the link:
-- http://martin.hinner.info/vga/timing.html
-- The table lists timing values for multiple resolutions
-- at a given refresh rate
--
-- The Clock Wizard IP is used to generate the necessary
-- Pixel Clock (as referenced in the table)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity vga_controller is
    generic (
        pixel_data_width:   integer := 4
    );
    Port ( 
       i_clk:               in std_logic;
       i_sw:                in std_logic_vector(pixel_data_width-1 downto 0);
       o_led:               out std_logic_vector(pixel_data_width-1 downto 0);
       o_h_sync:            out std_logic;
       o_v_sync:            out std_logic;
       o_red_pixel:         out std_logic_vector(pixel_data_width-1 downto 0);
       o_blue_pixel:        out std_logic_vector(pixel_data_width-1 downto 0);
       o_green_pixel:       out std_logic_vector(pixel_data_width-1 downto 0));
end vga_controller;

architecture Behavioral of vga_controller is

component clk_wiz_0
    port(
      clk_in1:              in std_logic;
      clk_out1:             out std_logic
     );
end component;

-- Constants for sync generation signals
-- Resolution Format: 1920x1080 @ 60Hz
-- Requires 148.5 MHz Pixel Clock from Clock Manager
-- For other timing values, refer to the link provided above
constant c_screen_width:        natural := 1920;
constant c_screen_height:       natural := 1080;

constant h_front_porch_width:   natural := 88; -- H Front Porch Width (Pixels)
constant h_pulse_width:         natural := 44; -- H Sync Pulse Width (Pixels)
constant h_max:                 natural := 2200; -- H Total Period (Pixels)

constant v_front_porch_width:   natural := 4; -- V Front Porch Width (Lines)
constant v_pulse_width:         natural := 5; -- V Sync Pulse Width (Lines)
constant v_max:                 natural := 1125; -- V Total Period (Lines)

signal pixel_clk:               std_logic;
signal display_active_flag:     std_logic;

signal h_sync_counter:          integer := 0;
signal v_sync_counter:          integer := 0;

signal h_sync_reg:              std_logic := '0';
signal v_sync_reg:              std_logic := '0';

signal h_sync_delay_reg:        std_logic := '0';
signal v_sync_delay_reg:        std_logic := '0';

signal vga_red:                 std_logic_vector(pixel_data_width-1 downto 0);
signal vga_green:               std_logic_vector(pixel_data_width-1 downto 0);
signal vga_blue:                std_logic_vector(pixel_data_width-1 downto 0);

signal vga_red_reg:             std_logic_vector(pixel_data_width-1 downto 0) := (others =>'0');
signal vga_green_reg:           std_logic_vector(pixel_data_width-1 downto 0) := (others =>'0');
signal vga_blue_reg:            std_logic_vector(pixel_data_width-1 downto 0) := (others =>'0');



begin

clk_manager_instance: clk_wiz_0
   port map ( 
        clk_in1 =>  i_clk,
        clk_out1 => pixel_clk
    );

h_sync_counter_proc: process (pixel_clk)
begin
    if (rising_edge(pixel_clk)) then
      if (h_sync_counter = (h_max - 1)) then
        h_sync_counter <= 0;
      else
        h_sync_counter <= h_sync_counter + 1;
      end if;
    end if;
end process h_sync_counter_proc;

v_sync_counter_proc: process (pixel_clk)
begin
    if (rising_edge(pixel_clk)) then
      if ((h_sync_counter = (h_max - 1)) and (v_sync_counter = (v_max - 1))) then
        v_sync_counter <= 0;
      elsif (h_sync_counter = (h_max - 1)) then
        v_sync_counter <= v_sync_counter + 1;
      end if;
    end if;
end process v_sync_counter_proc;
  
h_sync_update_proc: process (pixel_clk)
begin
    if (rising_edge(pixel_clk)) then
      if (h_sync_counter >= (h_front_porch_width + c_screen_width - 1)) and (h_sync_counter < (h_front_porch_width + c_screen_width + h_pulse_width - 1)) then
        h_sync_reg <= '1';
      else
        h_sync_reg <= '0';
      end if;
    end if;
end process h_sync_update_proc;

v_sync_update_proc: process (pixel_clk)
begin
    if (rising_edge(pixel_clk)) then
      if (v_sync_counter >= (v_front_porch_width + c_screen_height - 1)) and (v_sync_counter < (v_front_porch_width + c_screen_height + v_pulse_width - 1)) then
        v_sync_reg <= '1';
      else
        v_sync_reg <= '0';
      end if;
    end if;
end process v_sync_update_proc;

double_register_data_proc: process (pixel_clk)
begin
    if (rising_edge(pixel_clk)) then
      v_sync_delay_reg <= v_sync_reg;
      h_sync_delay_reg <= h_sync_reg;
      vga_red_reg <= vga_red;
      vga_green_reg <= vga_green;
      vga_blue_reg <= vga_blue;
    end if;
end process double_register_data_proc;

-- Process to test RGB patterns on the monitor
-- Uses the Zybo's switches to determine the color output
switch_test_pattern_proc: process(i_sw)
begin
    o_led <= i_sw;
    if (display_active_flag = '1') then
        case (i_sw) is
           when "0001" =>
                vga_red <= (others => '0');
                vga_blue <= (others => '0');
                vga_green <= (others => '1');
           when "0010" =>
                vga_red <= (others => '0');
                vga_blue <= (others => '1');
                vga_green <= (others => '0');
           when "0011" =>
                vga_red <= (others => '0');
                vga_blue <= (others => '1');
                vga_green <= (others => '1');
           when "0100" =>
                vga_red <= (others => '1');
                vga_blue <= (others => '0');
                vga_green <= (others => '0');
           when "0101" =>
                vga_red <= (others => '1');
                vga_blue <= (others => '0');
                vga_green <= (others => '1');
           when "0110" =>
                vga_red <= (others => '1');
                vga_blue <= (others => '1');
                vga_green <= (others => '0');
           when "1000" =>
                vga_red <= (others => '0');
                vga_blue <= "1010";
                vga_green <= (others => '0');
           when "1001" =>
                vga_red <= (others => '0');
                vga_blue <= (others => '0');
                vga_green <= "0101";
           when "1010" =>
                vga_red <= "0011";
                vga_blue <= (others => '0');
                vga_green <= "1010";
           when others =>
                vga_red <= (others => '1');
                vga_blue <= (others => '0');
                vga_green <= (others => '0');
        end case;
    else
        vga_red <= (others => '0');
        vga_blue <= (others => '0');
        vga_green <= (others => '0');
    end if;

end process switch_test_pattern_proc;

o_h_sync <= h_sync_delay_reg;
o_v_sync <= v_sync_delay_reg;
o_red_pixel <= vga_red_reg;
o_green_pixel <= vga_green_reg;
o_blue_pixel <= vga_blue_reg;
display_active_flag <= '1' when ((h_sync_counter < c_screen_width) and (v_sync_counter < c_screen_height)) else '0';

end Behavioral;