library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity tb_vga_controller is
    generic (
        pixel_data_width:   integer := 4
    );
end tb_vga_controller;

architecture Behavioral of tb_vga_controller is

component vga_controller is
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
end component vga_controller;

signal i_clk:               std_logic;
signal i_sw:                std_logic_vector(pixel_data_width-1 downto 0);
signal o_led:               std_logic_vector(pixel_data_width-1 downto 0);
signal o_h_sync:            std_logic;
signal o_v_sync:            std_logic;
signal o_red_pixel:         std_logic_vector(pixel_data_width-1 downto 0);
signal o_blue_pixel:        std_logic_vector(pixel_data_width-1 downto 0);
signal o_green_pixel:       std_logic_vector(pixel_data_width-1 downto 0);

constant clk_per:           time := 10 ns;

begin

UUT_vga_controller: vga_controller
    generic map (
        pixel_data_width    =>  pixel_data_width
    )
    
    port map (
        i_clk               =>  i_clk,
        i_sw                =>  i_sw,
        o_led               =>  o_led,
        o_h_sync            =>  o_h_sync,
        o_v_sync            =>  o_v_sync,
        o_red_pixel         =>  o_red_pixel,
        o_blue_pixel        =>  o_blue_pixel,
        o_green_pixel       =>  o_green_pixel
    );

clk_proc: process
begin
    i_clk <= '0';
    wait for clk_per/2;
    
    i_clk <= '1';
    wait for clk_per/2;

end process clk_proc;

test_vga_controller_proc: process
begin
    i_sw <= (others => '0');
    wait for clk_per;
    
    i_sw <= "0001";
    wait for clk_per;
    
    wait;

end process test_vga_controller_proc;

end Behavioral;
