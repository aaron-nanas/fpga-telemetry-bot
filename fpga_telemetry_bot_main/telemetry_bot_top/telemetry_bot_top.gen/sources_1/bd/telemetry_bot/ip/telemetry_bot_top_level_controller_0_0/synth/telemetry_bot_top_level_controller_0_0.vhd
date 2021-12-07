-- (c) Copyright 1995-2021 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:module_ref:top_level_controller:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY telemetry_bot_top_level_controller_0_0 IS
  PORT (
    i_clk : IN STD_LOGIC;
    i_reset : IN STD_LOGIC;
    i_data_in_rx : IN STD_LOGIC;
    write_enable_input_bram : IN STD_LOGIC;
    read_enable_input_bram : IN STD_LOGIC;
    write_enable_output_bram : IN STD_LOGIC;
    read_enable_output_bram : IN STD_LOGIC;
    rx_instruction_active : IN STD_LOGIC;
    sensor_pulse : IN STD_LOGIC;
    sensor_enable : OUT STD_LOGIC;
    o_tx_serial_data : OUT STD_LOGIC;
    o_PWM_1 : OUT STD_LOGIC;
    o_PWM_2 : OUT STD_LOGIC;
    o_PWM_3 : OUT STD_LOGIC;
    o_PWM_4 : OUT STD_LOGIC;
    o_PWM_5 : OUT STD_LOGIC;
    o_PWM_6 : OUT STD_LOGIC;
    o_PWM_7 : OUT STD_LOGIC;
    o_PWM_8 : OUT STD_LOGIC;
    servo_PWM : OUT STD_LOGIC;
    o_ssd : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    o_ssd_cat : OUT STD_LOGIC;
    o_led : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END telemetry_bot_top_level_controller_0_0;

ARCHITECTURE telemetry_bot_top_level_controller_0_0_arch OF telemetry_bot_top_level_controller_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF telemetry_bot_top_level_controller_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT top_level_controller IS
    GENERIC (
      data_width : INTEGER;
      addr_width : INTEGER;
      filters_width : INTEGER;
      num_elements_input : INTEGER;
      num_elements_output : INTEGER;
      num_instruction_bytes : INTEGER;
      instruction_reg_width : INTEGER;
      num_motors : INTEGER;
      clk_freq : INTEGER;
      g_clk_cycles_bit : INTEGER;
      main_clk_freq : INTEGER;
      servo_refresh_rate : INTEGER;
      servo_max_step_count : INTEGER;
      min_PWM_in_us : INTEGER;
      max_PWM_in_us : INTEGER
    );
    PORT (
      i_clk : IN STD_LOGIC;
      i_reset : IN STD_LOGIC;
      i_data_in_rx : IN STD_LOGIC;
      write_enable_input_bram : IN STD_LOGIC;
      read_enable_input_bram : IN STD_LOGIC;
      write_enable_output_bram : IN STD_LOGIC;
      read_enable_output_bram : IN STD_LOGIC;
      rx_instruction_active : IN STD_LOGIC;
      sensor_pulse : IN STD_LOGIC;
      sensor_enable : OUT STD_LOGIC;
      o_tx_serial_data : OUT STD_LOGIC;
      o_PWM_1 : OUT STD_LOGIC;
      o_PWM_2 : OUT STD_LOGIC;
      o_PWM_3 : OUT STD_LOGIC;
      o_PWM_4 : OUT STD_LOGIC;
      o_PWM_5 : OUT STD_LOGIC;
      o_PWM_6 : OUT STD_LOGIC;
      o_PWM_7 : OUT STD_LOGIC;
      o_PWM_8 : OUT STD_LOGIC;
      servo_PWM : OUT STD_LOGIC;
      o_ssd : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      o_ssd_cat : OUT STD_LOGIC;
      o_led : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
  END COMPONENT top_level_controller;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF telemetry_bot_top_level_controller_0_0_arch: ARCHITECTURE IS "top_level_controller,Vivado 2020.2";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF telemetry_bot_top_level_controller_0_0_arch : ARCHITECTURE IS "telemetry_bot_top_level_controller_0_0,top_level_controller,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF telemetry_bot_top_level_controller_0_0_arch: ARCHITECTURE IS "telemetry_bot_top_level_controller_0_0,top_level_controller,{x_ipProduct=Vivado 2020.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=top_level_controller,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=VHDL,data_width=8,addr_width=18,filters_width=8,num_elements_input=242004,num_elements_output=240000,num_instruction_bytes=3,instruction_reg_width=24,num_motors=4,clk_freq=125,g_clk_cycles_bit=135,main_clk_freq=125000000,servo_refresh_rate=50,servo_max_step_count=10,mi" & 
"n_PWM_in_us=575,max_PWM_in_us=2460}";
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF telemetry_bot_top_level_controller_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER OF i_reset: SIGNAL IS "XIL_INTERFACENAME i_reset, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF i_reset: SIGNAL IS "xilinx.com:signal:reset:1.0 i_reset RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF i_clk: SIGNAL IS "XIL_INTERFACENAME i_clk, ASSOCIATED_RESET i_reset, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN telemetry_bot_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF i_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 i_clk CLK";
BEGIN
  U0 : top_level_controller
    GENERIC MAP (
      data_width => 8,
      addr_width => 18,
      filters_width => 8,
      num_elements_input => 242004,
      num_elements_output => 240000,
      num_instruction_bytes => 3,
      instruction_reg_width => 24,
      num_motors => 4,
      clk_freq => 125,
      g_clk_cycles_bit => 135,
      main_clk_freq => 125000000,
      servo_refresh_rate => 50,
      servo_max_step_count => 10,
      min_PWM_in_us => 575,
      max_PWM_in_us => 2460
    )
    PORT MAP (
      i_clk => i_clk,
      i_reset => i_reset,
      i_data_in_rx => i_data_in_rx,
      write_enable_input_bram => write_enable_input_bram,
      read_enable_input_bram => read_enable_input_bram,
      write_enable_output_bram => write_enable_output_bram,
      read_enable_output_bram => read_enable_output_bram,
      rx_instruction_active => rx_instruction_active,
      sensor_pulse => sensor_pulse,
      sensor_enable => sensor_enable,
      o_tx_serial_data => o_tx_serial_data,
      o_PWM_1 => o_PWM_1,
      o_PWM_2 => o_PWM_2,
      o_PWM_3 => o_PWM_3,
      o_PWM_4 => o_PWM_4,
      o_PWM_5 => o_PWM_5,
      o_PWM_6 => o_PWM_6,
      o_PWM_7 => o_PWM_7,
      o_PWM_8 => o_PWM_8,
      servo_PWM => servo_PWM,
      o_ssd => o_ssd,
      o_ssd_cat => o_ssd_cat,
      o_led => o_led
    );
END telemetry_bot_top_level_controller_0_0_arch;
