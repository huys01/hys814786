#----------------------------------------------------------------------
# Title      : Example top level constraints for JESD204
# Project    : jesd204_v7_2_4
#----------------------------------------------------------------------
# File       : jesd204_tx_example_design.xdc
# Author     : Xilinx
#----------------------------------------------------------------------
# Description: Xilinx Constraint file for the example design for
#              JESD204 core
#---------------------------------------------------------------------
# (c) Copyright 2004-2014 Xilinx, Inc. All rights reserved.
#
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
#
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
#
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
#
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
#

#------------------------------------------
# TIMING CONSTRAINTS
#------------------------------------------
# Set Reference to 400MHz by default
create_clock -period 2.500 -name jesd204_tx_refclk [get_ports refclk0p]

# Set Device Clock  400.0 MHz
create_clock -period 2.500 -name jesd204_tx_glblclk [get_ports glblclkp]

# Set DRP Clock to 200.0MHz
create_clock -period 5.000 -name jesd204_tx_drpclk [get_ports drpclk]

# Set AXI-Lite Clock to 100.0MHz by default
create_clock -period 10.000 -name jesd204_tx_axi_aclk [get_ports s_axi_aclk]

# At linerates > 12.5Gb/s the succesful capture of SYSREF poses a system design issue that must be overcome.
# The recomended approach, to ensure the successful capture of SYSREF, is to run the report_datasheet command
# in Vivado to obtain the required setup and hold timing values of SYSREF relative to the clock used to capture 
# it (refclk or core_clk) and adjust the output delay of the clock generator tha is used to generate SYSREF
# to match. See PG066 for  an illustrated example of the setup and hold timings

########################
# Waivers
########################
#
# CDC-11
#
create_waiver -quiet -user JESD204 -type CDC -id CDC-11 -description {It is safe to feed the same reset to both TX and RX channels in the PHY when the clock domains are tied} \
  -from [get_pins -filter {REF_PIN_NAME=~C}   -of [get_cells -hier -filter {name=~*stretch_reg*}] ] \
  -to   [get_pins -filter {REF_PIN_NAME=~PRE} -of [get_cells -hier -filter {name=~*xpm_cdc_async_rst_inst/arststages_ff_reg[0]}] ]
