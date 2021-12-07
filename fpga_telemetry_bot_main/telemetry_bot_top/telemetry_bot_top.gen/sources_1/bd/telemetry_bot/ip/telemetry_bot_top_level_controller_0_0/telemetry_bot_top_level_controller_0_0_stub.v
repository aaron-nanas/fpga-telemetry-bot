// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Tue Dec  7 01:05:16 2021
// Host        : Aaron-Linux running 64-bit Ubuntu 20.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/aaronnanas/vivado_projects/ece524_final_proj/telemetry_bot_top/telemetry_bot_top.gen/sources_1/bd/telemetry_bot/ip/telemetry_bot_top_level_controller_0_0/telemetry_bot_top_level_controller_0_0_stub.v
// Design      : telemetry_bot_top_level_controller_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "top_level_controller,Vivado 2020.2" *)
module telemetry_bot_top_level_controller_0_0(i_clk, i_reset, i_data_in_rx, 
  write_enable_input_bram, read_enable_input_bram, write_enable_output_bram, 
  read_enable_output_bram, rx_instruction_active, sensor_pulse, sensor_enable, 
  o_tx_serial_data, o_PWM_1, o_PWM_2, o_PWM_3, o_PWM_4, o_PWM_5, o_PWM_6, o_PWM_7, o_PWM_8, 
  servo_PWM, o_ssd, o_ssd_cat, o_led)
/* synthesis syn_black_box black_box_pad_pin="i_clk,i_reset,i_data_in_rx,write_enable_input_bram,read_enable_input_bram,write_enable_output_bram,read_enable_output_bram,rx_instruction_active,sensor_pulse,sensor_enable,o_tx_serial_data,o_PWM_1,o_PWM_2,o_PWM_3,o_PWM_4,o_PWM_5,o_PWM_6,o_PWM_7,o_PWM_8,servo_PWM,o_ssd[6:0],o_ssd_cat,o_led[3:0]" */;
  input i_clk;
  input i_reset;
  input i_data_in_rx;
  input write_enable_input_bram;
  input read_enable_input_bram;
  input write_enable_output_bram;
  input read_enable_output_bram;
  input rx_instruction_active;
  input sensor_pulse;
  output sensor_enable;
  output o_tx_serial_data;
  output o_PWM_1;
  output o_PWM_2;
  output o_PWM_3;
  output o_PWM_4;
  output o_PWM_5;
  output o_PWM_6;
  output o_PWM_7;
  output o_PWM_8;
  output servo_PWM;
  output [6:0]o_ssd;
  output o_ssd_cat;
  output [3:0]o_led;
endmodule
