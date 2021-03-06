set_property SRC_FILE_INFO {cfile:/home/aaronnanas/vivado_projects/ece524_final_proj/uart_controller/uart_controller.srcs/constrs_1/new/zybo_z720_constraints.xdc rfile:../../../uart_controller.srcs/constrs_1/new/zybo_z720_constraints.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:8 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { i_clk }]; #IO_L12P_T1_MRCC_35 Sch=sysclk
set_property src_info {type:XDC file:1 line:147 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { i_data_in_rx }]; #IO_L4P_T0_34 Sch=je[1]
set_property src_info {type:XDC file:1 line:148 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { o_tx_serial_data }]; #IO_L18N_T2_34 Sch=je[2]
set_property src_info {type:XDC file:1 line:149 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { o_tx_active }]; #IO_25_35 Sch=je[3]
set_property src_info {type:XDC file:1 line:150 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { o_tx_done }]; #IO_L19P_T3_35 Sch=je[4]
