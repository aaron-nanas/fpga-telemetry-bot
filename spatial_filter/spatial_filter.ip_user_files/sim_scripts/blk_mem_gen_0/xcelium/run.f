-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../spatial_filter.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_sim_netlist.vhdl" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

