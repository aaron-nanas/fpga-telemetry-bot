--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
--Date        : Tue Dec  7 01:04:36 2021
--Host        : Aaron-Linux running 64-bit Ubuntu 20.04.3 LTS
--Command     : generate_target telemetry_bot_wrapper.bd
--Design      : telemetry_bot_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity telemetry_bot_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    i_data_in_rx : in STD_LOGIC;
    i_reset : in STD_LOGIC;
    o_PWM_1 : out STD_LOGIC;
    o_PWM_2 : out STD_LOGIC;
    o_PWM_3 : out STD_LOGIC;
    o_PWM_4 : out STD_LOGIC;
    o_PWM_5 : out STD_LOGIC;
    o_PWM_6 : out STD_LOGIC;
    o_PWM_7 : out STD_LOGIC;
    o_PWM_8 : out STD_LOGIC;
    o_led : out STD_LOGIC_VECTOR ( 3 downto 0 );
    o_ssd : out STD_LOGIC_VECTOR ( 6 downto 0 );
    o_ssd_cat : out STD_LOGIC;
    o_tx_serial_data : out STD_LOGIC;
    read_enable_input_bram : in STD_LOGIC;
    read_enable_output_bram : in STD_LOGIC;
    rx_instruction_active : in STD_LOGIC;
    sensor_enable : out STD_LOGIC;
    sensor_pulse : in STD_LOGIC;
    servo_PWM : out STD_LOGIC;
    write_enable_input_bram : in STD_LOGIC;
    write_enable_output_bram : in STD_LOGIC
  );
end telemetry_bot_wrapper;

architecture STRUCTURE of telemetry_bot_wrapper is
  component telemetry_bot is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    sensor_pulse : in STD_LOGIC;
    i_reset : in STD_LOGIC;
    i_data_in_rx : in STD_LOGIC;
    write_enable_input_bram : in STD_LOGIC;
    read_enable_input_bram : in STD_LOGIC;
    write_enable_output_bram : in STD_LOGIC;
    read_enable_output_bram : in STD_LOGIC;
    rx_instruction_active : in STD_LOGIC;
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
  end component telemetry_bot;
begin
telemetry_bot_i: component telemetry_bot
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      i_data_in_rx => i_data_in_rx,
      i_reset => i_reset,
      o_PWM_1 => o_PWM_1,
      o_PWM_2 => o_PWM_2,
      o_PWM_3 => o_PWM_3,
      o_PWM_4 => o_PWM_4,
      o_PWM_5 => o_PWM_5,
      o_PWM_6 => o_PWM_6,
      o_PWM_7 => o_PWM_7,
      o_PWM_8 => o_PWM_8,
      o_led(3 downto 0) => o_led(3 downto 0),
      o_ssd(6 downto 0) => o_ssd(6 downto 0),
      o_ssd_cat => o_ssd_cat,
      o_tx_serial_data => o_tx_serial_data,
      read_enable_input_bram => read_enable_input_bram,
      read_enable_output_bram => read_enable_output_bram,
      rx_instruction_active => rx_instruction_active,
      sensor_enable => sensor_enable,
      sensor_pulse => sensor_pulse,
      servo_PWM => servo_PWM,
      write_enable_input_bram => write_enable_input_bram,
      write_enable_output_bram => write_enable_output_bram
    );
end STRUCTURE;
