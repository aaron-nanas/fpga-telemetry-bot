#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2020.2 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Thu Nov 25 19:29:56 PST 2021
# SW Build 3064766 on Wed Nov 18 09:12:47 MST 2020
#
# Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# elaborate design
echo "xelab -wto 99ac95a6232d420bb37fa4c836ca1a5e --incr --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot tb_top_level_filter_fsm_behav xil_defaultlib.tb_top_level_filter_fsm -log elaborate.log"
xelab -wto 99ac95a6232d420bb37fa4c836ca1a5e --incr --debug typical --relax --mt 8 -L xil_defaultlib -L secureip --snapshot tb_top_level_filter_fsm_behav xil_defaultlib.tb_top_level_filter_fsm -log elaborate.log

