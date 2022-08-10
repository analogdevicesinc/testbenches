# ***************************************************************************
# ***************************************************************************
# Copyright 2018 (c) Analog Devices, Inc. All rights reserved.
#
# In this HDL repository, there are many different and unique modules, consisting
# of various HDL (Verilog or VHDL) components. The individual modules are
# developed independently, and may be accompanied by separate and unique license
# terms.
#
# The user should read each of these license terms, and understand the
# freedoms and responsibilities that he or she has by using this source/core.
#
# This core is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.
#
# Redistribution and use of source or resulting binaries, with or without modification
# of this file, are permitted under one of the following two license terms:
#
#   1. The GNU General Public License version 2 as published by the
#      Free Software Foundation, which can be found in the top level directory
#      of this repository (LICENSE_GPL2), and also online at:
#      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
#
# OR
#
#   2. An ADI specific BSD license, which can be found in the top level directory
#      of this repository (LICENSE_ADIBSD), and also on-line at:
#      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
#      This will allow to generate bit files and not release the source code,
#      as long as it attaches to an ADI device.
#
# ***************************************************************************
# ***************************************************************************

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl

global ad_project_params

set JESD_F $ad_project_params(JESD_F)
# For F=3,6,12 use dual clock
if {$JESD_F % 3 == 0} {
  set LL_OUT_BYTES [expr max($JESD_F,12)]
} else {
  set LL_OUT_BYTES 8
}

set DMA_SAMPLE_WIDTH $ad_project_params(JESD_NP)
if {$DMA_SAMPLE_WIDTH == 12} {
  set DMA_SAMPLE_WIDTH 16
}

set ENCODER_SEL 2; # 1 - 8B10B ; 2 - 64B66B
set NUM_OF_LINKS 1

adi_sim_add_define LL_OUT_BYTES=$LL_OUT_BYTES
set NUM_OF_CONVERTERS $ad_project_params(JESD_M)
set NUM_OF_LANES $ad_project_params(JESD_L)
set SAMPLES_PER_FRAME $ad_project_params(JESD_S)
set SAMPLE_WIDTH $ad_project_params(JESD_NP)

set DAC_DATA_WIDTH [expr $NUM_OF_LANES * $LL_OUT_BYTES * 8]
set SAMPLES_PER_CHANNEL [expr $DAC_DATA_WIDTH / $NUM_OF_CONVERTERS / $SAMPLE_WIDTH]

set MAX_CONVERTERS 16
set MAX_LANES 8

# DRP clk for 204C phy
ad_ip_instance clk_vip drp_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 50000000 \
]
adi_sim_add_define "DRP_CLK=drp_clk_vip"
create_bd_port -dir O drp_clk_out
ad_connect  drp_clk_vip/clk_out drp_clk_out

# Ref clk
ad_ip_instance clk_vip ref_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "REF_CLK=ref_clk_vip"
create_bd_port -dir O ref_clk_out
ad_connect ref_clk_out ref_clk_vip/clk_out

# Device clk
ad_ip_instance clk_vip device_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "DEVICE_CLK=device_clk_vip"
create_bd_port -dir O device_clk_out
ad_connect device_clk_out device_clk_vip/clk_out

# SYSREF clk
ad_ip_instance clk_vip sysref_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 5000000 \
]
adi_sim_add_define "SYSREF_CLK=sysref_clk_vip"
create_bd_port -dir O sysref_clk_out
ad_connect sysref_clk_out sysref_clk_vip/clk_out

#
#  Block design under test
#

create_bd_port -dir I -type clk ref_clk
create_bd_port -dir I -type clk drp_clk
create_bd_port -dir I -type clk device_clk
create_bd_port -dir I -type clk sysref

set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports device_clk]

# TX JESD204 PHY layer peripheral

for {set i 0} {$i < $MAX_LANES} {incr i} {
create_bd_port -dir I rx_data_${i}_n
create_bd_port -dir I rx_data_${i}_p
create_bd_port -dir O tx_data_${i}_n
create_bd_port -dir O tx_data_${i}_p
}

# reset generator
ad_ip_instance proc_sys_reset device_clk_rstgen
ad_connect  device_clk device_clk_rstgen/slowest_sync_clk
ad_connect  $sys_cpu_resetn device_clk_rstgen/ext_reset_in

# Common PHYs
# Use two instances since they are located on different SLRS
set lane_rate $ad_project_params(LANE_RATE)
set ref_clk_rate $ad_project_params(REF_CLK_RATE)

# RX & TX JESD204 PHY layer peripheral
ad_ip_instance jesd204_phy jesd204_phy [list \
  C_LANES $MAX_LANES \
  GT_Line_Rate $lane_rate \
  GT_REFCLK_FREQ $ref_clk_rate \
  DRPCLK_FREQ {50} \
  C_PLL_SELECTION $ad_project_params(PLL_SEL) \
  RX_GT_Line_Rate $lane_rate \
  RX_GT_REFCLK_FREQ $ref_clk_rate \
  RX_PLL_SELECTION $ad_project_params(PLL_SEL) \
  GT_Location {X0Y8} \
  Tx_JesdVersion {1} \
  Rx_JesdVersion {1} \
  Tx_use_64b {1} \
  Rx_use_64b {1} \
  Min_Line_Rate $lane_rate \
  Max_Line_Rate $lane_rate \
  Axi_Lite {true} \
]

# TX JESD204 link layer peripheral
adi_axi_jesd204_tx_create dac_jesd204_link $NUM_OF_LANES $NUM_OF_LINKS $ENCODER_SEL
ad_ip_parameter dac_jesd204_link/tx CONFIG.TPL_DATA_PATH_WIDTH $LL_OUT_BYTES

# TX JESD204 transport layer peripheral
adi_tpl_jesd204_tx_create dac_jesd204_transport $NUM_OF_LANES \
                                                $NUM_OF_CONVERTERS \
                                                $SAMPLES_PER_FRAME \
                                                $SAMPLE_WIDTH \
                                                $LL_OUT_BYTES \
                                                $DMA_SAMPLE_WIDTH

# RX JESD204 link layer peripheral
adi_axi_jesd204_rx_create adc_jesd204_link $NUM_OF_LANES $NUM_OF_LINKS $ENCODER_SEL
ad_ip_parameter adc_jesd204_link/rx CONFIG.TPL_DATA_PATH_WIDTH $LL_OUT_BYTES

# RX JESD204 transport layer peripheral
adi_tpl_jesd204_rx_create adc_jesd204_transport $NUM_OF_LANES \
                                                $NUM_OF_CONVERTERS \
                                                $SAMPLES_PER_FRAME \
                                                $SAMPLE_WIDTH \
                                                $LL_OUT_BYTES \
                                                $DMA_SAMPLE_WIDTH

# loopback serial lanes to PHY

ad_connect  jesd204_phy/txn_out  jesd204_phy/rxn_in
ad_connect  jesd204_phy/txp_out  jesd204_phy/rxp_in

# Tx connect PHY to Link Layer
for {set j 0}  {$j < $NUM_OF_LANES} {incr j} {
  ad_connect  dac_jesd204_link/tx_phy$j  jesd204_phy/gt${j}_tx
  ad_connect  adc_jesd204_link/rx_phy$j  jesd204_phy/gt${j}_rx
}

ad_connect  sysref  dac_jesd204_link/sysref
ad_connect  sysref  adc_jesd204_link/sysref

# connect link layer to transport layer
ad_connect  dac_jesd204_link/tx_data dac_jesd204_transport/link

ad_connect  adc_jesd204_link/rx_sof adc_jesd204_transport/link_sof
ad_connect  adc_jesd204_link/rx_data_tdata adc_jesd204_transport/link_data
ad_connect  adc_jesd204_link/rx_data_tvalid adc_jesd204_transport/link_valid

# reference clocks & resets

ad_connect  ref_clk jesd204_phy/cpll_refclk
ad_connect  ref_clk jesd204_phy/qpll0_refclk
ad_connect  ref_clk jesd204_phy/qpll1_refclk

ad_connect  drp_clk jesd204_phy/drpclk

ad_connect  jesd204_phy/rxoutclk jesd204_phy/rx_core_clk
ad_connect  jesd204_phy/txoutclk jesd204_phy/tx_core_clk

ad_connect  jesd204_phy/txoutclk dac_jesd204_link/link_clk
ad_connect  jesd204_phy/rxoutclk adc_jesd204_link/link_clk

ad_connect  device_clk dac_jesd204_link/device_clk
ad_connect  device_clk adc_jesd204_link/device_clk

ad_connect  device_clk dac_jesd204_transport/link_clk
ad_connect  device_clk adc_jesd204_transport/link_clk

# resets
ad_connect  device_clk_rstgen/peripheral_reset jesd204_phy/tx_sys_reset
ad_connect  device_clk_rstgen/peripheral_reset jesd204_phy/rx_sys_reset

ad_connect  dac_jesd204_link/tx_axi/device_reset jesd204_phy/tx_reset_gt
ad_connect  adc_jesd204_link/rx_axi/device_reset jesd204_phy/rx_reset_gt

ad_cpu_interconnect 0x44a60000 jesd204_phy
ad_cpu_interconnect 0x44a90000 adc_jesd204_link
ad_cpu_interconnect 0x44b90000 dac_jesd204_link
ad_cpu_interconnect 0x44a10000 adc_jesd204_transport
ad_cpu_interconnect 0x44b10000 dac_jesd204_transport

for {set i 0} {$i < $NUM_OF_CONVERTERS} {incr i} {
  create_bd_port -dir I -from [expr $SAMPLES_PER_CHANNEL*$DMA_SAMPLE_WIDTH-1] -to 0 dac_data_$i
  ad_connect dac_data_$i dac_jesd204_transport/dac_data_$i
}

# Create dummy input channels
for {set i $NUM_OF_CONVERTERS} {$i < $MAX_CONVERTERS} {incr i} {
  create_bd_port -dir I -from [expr $SAMPLES_PER_CHANNEL*$DMA_SAMPLE_WIDTH-1] -to 0 dac_data_$i
}

make_bd_pins_external  [get_bd_pins /dac_jesd204_transport/dac_dunf]
make_bd_pins_external  [get_bd_pins /adc_jesd204_transport/adc_dovf]
