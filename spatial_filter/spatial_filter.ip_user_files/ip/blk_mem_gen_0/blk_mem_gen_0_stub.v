// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Fri Nov 19 15:01:53 2021
// Host        : DESKTOP-LR85IAF running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/Labs/ECE524/spatial_filter/spatial_filter.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_stub.v
// Design      : blk_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k70tfbv676-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_3,Vivado 2019.1" *)
module blk_mem_gen_0(clka, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[17:0],dina[7:0],douta[7:0]" */;
  input clka;
  input [0:0]wea;
  input [17:0]addra;
  input [7:0]dina;
  output [7:0]douta;
endmodule
