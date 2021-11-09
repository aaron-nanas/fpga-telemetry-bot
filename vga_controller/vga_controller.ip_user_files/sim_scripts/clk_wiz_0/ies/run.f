-makelib ies_lib/xpm -sv \
  "/opt/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "/opt/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../vga_controller.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_sim_netlist.vhdl" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

