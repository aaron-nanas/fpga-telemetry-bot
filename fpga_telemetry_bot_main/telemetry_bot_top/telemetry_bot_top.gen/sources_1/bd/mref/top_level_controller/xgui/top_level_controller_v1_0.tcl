# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "addr_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "clk_freq" -parent ${Page_0}
  ipgui::add_param $IPINST -name "data_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "filters_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "g_clk_cycles_bit" -parent ${Page_0}
  ipgui::add_param $IPINST -name "instruction_reg_width" -parent ${Page_0}
  ipgui::add_param $IPINST -name "main_clk_freq" -parent ${Page_0}
  ipgui::add_param $IPINST -name "max_PWM_in_us" -parent ${Page_0}
  ipgui::add_param $IPINST -name "min_PWM_in_us" -parent ${Page_0}
  ipgui::add_param $IPINST -name "num_elements_input" -parent ${Page_0}
  ipgui::add_param $IPINST -name "num_elements_output" -parent ${Page_0}
  ipgui::add_param $IPINST -name "num_instruction_bytes" -parent ${Page_0}
  ipgui::add_param $IPINST -name "num_motors" -parent ${Page_0}
  ipgui::add_param $IPINST -name "servo_max_step_count" -parent ${Page_0}
  ipgui::add_param $IPINST -name "servo_refresh_rate" -parent ${Page_0}


}

proc update_PARAM_VALUE.addr_width { PARAM_VALUE.addr_width } {
	# Procedure called to update addr_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.addr_width { PARAM_VALUE.addr_width } {
	# Procedure called to validate addr_width
	return true
}

proc update_PARAM_VALUE.clk_freq { PARAM_VALUE.clk_freq } {
	# Procedure called to update clk_freq when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.clk_freq { PARAM_VALUE.clk_freq } {
	# Procedure called to validate clk_freq
	return true
}

proc update_PARAM_VALUE.data_width { PARAM_VALUE.data_width } {
	# Procedure called to update data_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.data_width { PARAM_VALUE.data_width } {
	# Procedure called to validate data_width
	return true
}

proc update_PARAM_VALUE.filters_width { PARAM_VALUE.filters_width } {
	# Procedure called to update filters_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.filters_width { PARAM_VALUE.filters_width } {
	# Procedure called to validate filters_width
	return true
}

proc update_PARAM_VALUE.g_clk_cycles_bit { PARAM_VALUE.g_clk_cycles_bit } {
	# Procedure called to update g_clk_cycles_bit when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.g_clk_cycles_bit { PARAM_VALUE.g_clk_cycles_bit } {
	# Procedure called to validate g_clk_cycles_bit
	return true
}

proc update_PARAM_VALUE.instruction_reg_width { PARAM_VALUE.instruction_reg_width } {
	# Procedure called to update instruction_reg_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.instruction_reg_width { PARAM_VALUE.instruction_reg_width } {
	# Procedure called to validate instruction_reg_width
	return true
}

proc update_PARAM_VALUE.main_clk_freq { PARAM_VALUE.main_clk_freq } {
	# Procedure called to update main_clk_freq when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.main_clk_freq { PARAM_VALUE.main_clk_freq } {
	# Procedure called to validate main_clk_freq
	return true
}

proc update_PARAM_VALUE.max_PWM_in_us { PARAM_VALUE.max_PWM_in_us } {
	# Procedure called to update max_PWM_in_us when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.max_PWM_in_us { PARAM_VALUE.max_PWM_in_us } {
	# Procedure called to validate max_PWM_in_us
	return true
}

proc update_PARAM_VALUE.min_PWM_in_us { PARAM_VALUE.min_PWM_in_us } {
	# Procedure called to update min_PWM_in_us when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.min_PWM_in_us { PARAM_VALUE.min_PWM_in_us } {
	# Procedure called to validate min_PWM_in_us
	return true
}

proc update_PARAM_VALUE.num_elements_input { PARAM_VALUE.num_elements_input } {
	# Procedure called to update num_elements_input when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.num_elements_input { PARAM_VALUE.num_elements_input } {
	# Procedure called to validate num_elements_input
	return true
}

proc update_PARAM_VALUE.num_elements_output { PARAM_VALUE.num_elements_output } {
	# Procedure called to update num_elements_output when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.num_elements_output { PARAM_VALUE.num_elements_output } {
	# Procedure called to validate num_elements_output
	return true
}

proc update_PARAM_VALUE.num_instruction_bytes { PARAM_VALUE.num_instruction_bytes } {
	# Procedure called to update num_instruction_bytes when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.num_instruction_bytes { PARAM_VALUE.num_instruction_bytes } {
	# Procedure called to validate num_instruction_bytes
	return true
}

proc update_PARAM_VALUE.num_motors { PARAM_VALUE.num_motors } {
	# Procedure called to update num_motors when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.num_motors { PARAM_VALUE.num_motors } {
	# Procedure called to validate num_motors
	return true
}

proc update_PARAM_VALUE.servo_max_step_count { PARAM_VALUE.servo_max_step_count } {
	# Procedure called to update servo_max_step_count when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.servo_max_step_count { PARAM_VALUE.servo_max_step_count } {
	# Procedure called to validate servo_max_step_count
	return true
}

proc update_PARAM_VALUE.servo_refresh_rate { PARAM_VALUE.servo_refresh_rate } {
	# Procedure called to update servo_refresh_rate when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.servo_refresh_rate { PARAM_VALUE.servo_refresh_rate } {
	# Procedure called to validate servo_refresh_rate
	return true
}


proc update_MODELPARAM_VALUE.data_width { MODELPARAM_VALUE.data_width PARAM_VALUE.data_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.data_width}] ${MODELPARAM_VALUE.data_width}
}

proc update_MODELPARAM_VALUE.addr_width { MODELPARAM_VALUE.addr_width PARAM_VALUE.addr_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.addr_width}] ${MODELPARAM_VALUE.addr_width}
}

proc update_MODELPARAM_VALUE.filters_width { MODELPARAM_VALUE.filters_width PARAM_VALUE.filters_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.filters_width}] ${MODELPARAM_VALUE.filters_width}
}

proc update_MODELPARAM_VALUE.num_elements_input { MODELPARAM_VALUE.num_elements_input PARAM_VALUE.num_elements_input } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.num_elements_input}] ${MODELPARAM_VALUE.num_elements_input}
}

proc update_MODELPARAM_VALUE.num_elements_output { MODELPARAM_VALUE.num_elements_output PARAM_VALUE.num_elements_output } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.num_elements_output}] ${MODELPARAM_VALUE.num_elements_output}
}

proc update_MODELPARAM_VALUE.num_instruction_bytes { MODELPARAM_VALUE.num_instruction_bytes PARAM_VALUE.num_instruction_bytes } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.num_instruction_bytes}] ${MODELPARAM_VALUE.num_instruction_bytes}
}

proc update_MODELPARAM_VALUE.instruction_reg_width { MODELPARAM_VALUE.instruction_reg_width PARAM_VALUE.instruction_reg_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.instruction_reg_width}] ${MODELPARAM_VALUE.instruction_reg_width}
}

proc update_MODELPARAM_VALUE.num_motors { MODELPARAM_VALUE.num_motors PARAM_VALUE.num_motors } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.num_motors}] ${MODELPARAM_VALUE.num_motors}
}

proc update_MODELPARAM_VALUE.clk_freq { MODELPARAM_VALUE.clk_freq PARAM_VALUE.clk_freq } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.clk_freq}] ${MODELPARAM_VALUE.clk_freq}
}

proc update_MODELPARAM_VALUE.g_clk_cycles_bit { MODELPARAM_VALUE.g_clk_cycles_bit PARAM_VALUE.g_clk_cycles_bit } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.g_clk_cycles_bit}] ${MODELPARAM_VALUE.g_clk_cycles_bit}
}

proc update_MODELPARAM_VALUE.main_clk_freq { MODELPARAM_VALUE.main_clk_freq PARAM_VALUE.main_clk_freq } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.main_clk_freq}] ${MODELPARAM_VALUE.main_clk_freq}
}

proc update_MODELPARAM_VALUE.servo_refresh_rate { MODELPARAM_VALUE.servo_refresh_rate PARAM_VALUE.servo_refresh_rate } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.servo_refresh_rate}] ${MODELPARAM_VALUE.servo_refresh_rate}
}

proc update_MODELPARAM_VALUE.servo_max_step_count { MODELPARAM_VALUE.servo_max_step_count PARAM_VALUE.servo_max_step_count } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.servo_max_step_count}] ${MODELPARAM_VALUE.servo_max_step_count}
}

proc update_MODELPARAM_VALUE.min_PWM_in_us { MODELPARAM_VALUE.min_PWM_in_us PARAM_VALUE.min_PWM_in_us } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.min_PWM_in_us}] ${MODELPARAM_VALUE.min_PWM_in_us}
}

proc update_MODELPARAM_VALUE.max_PWM_in_us { MODELPARAM_VALUE.max_PWM_in_us PARAM_VALUE.max_PWM_in_us } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.max_PWM_in_us}] ${MODELPARAM_VALUE.max_PWM_in_us}
}

