-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
-- Date        : Tue Dec  7 01:05:16 2021
-- Host        : Aaron-Linux running 64-bit Ubuntu 20.04.3 LTS
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ telemetry_bot_top_level_controller_0_0_stub.vhdl
-- Design      : telemetry_bot_top_level_controller_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    i_clk : in STD_LOGIC;
    i_reset : in STD_LOGIC;
    i_data_in_rx : in STD_LOGIC;
    write_enable_input_bram : in STD_LOGIC;
    read_enable_input_bram : in STD_LOGIC;
    write_enable_output_bram : in STD_LOGIC;
    read_enable_output_bram : in STD_LOGIC;
    rx_instruction_active : in STD_LOGIC;
    sensor_pulse : in STD_LOGIC;
    sensor_enable : out STD_LOGIC;
    o_tx_serial_data : out STD_LOGIC;
    o_PWM_1 : out STD_LOGIC;
    o_PWM_2 : out STD_LOGIC;
    o_PWM_3 : out STD_LOGIC;
    o_PWM_4 : out STD_LOGIC;
    o_PWM_5 : out STD_LOGIC;
    o_PWM_6 : out STD_LOGIC;
    o_PWM_7 : out STD_LOGIC;
    o_PWM_8 : out STD_LOGIC;
    servo_PWM : out STD_LOGIC;
    o_ssd : out STD_LOGIC_VECTOR ( 6 downto 0 );
    o_ssd_cat : out STD_LOGIC;
    o_led : out STD_LOGIC_VECTOR ( 3 downto 0 )
  );

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "i_clk,i_reset,i_data_in_rx,write_enable_input_bram,read_enable_input_bram,write_enable_output_bram,read_enable_output_bram,rx_instruction_active,sensor_pulse,sensor_enable,o_tx_serial_data,o_PWM_1,o_PWM_2,o_PWM_3,o_PWM_4,o_PWM_5,o_PWM_6,o_PWM_7,o_PWM_8,servo_PWM,o_ssd[6:0],o_ssd_cat,o_led[3:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "top_level_controller,Vivado 2020.2";
begin
end;
