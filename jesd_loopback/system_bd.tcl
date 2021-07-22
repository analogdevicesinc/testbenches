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

source ../../library/scripts/adi_env.tcl
source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl

global ad_project_params

set LINK_MODE  $ad_project_params(LINK_MODE)

set JESD_8B10B 1
set JESD_64B66B 2

if {$LINK_MODE == $JESD_8B10B} {
  set DATAPATH_WIDTH 4
  set NP12_DATAPATH_WIDTH 6
} else {
  set DATAPATH_WIDTH 8
  set NP12_DATAPATH_WIDTH 12
}

set JESD_F $ad_project_params(JESD_F)
# For F=3,6,12 use dual clock
if {$JESD_F % 3 == 0} {
  set LL_OUT_BYTES [expr max($JESD_F,$NP12_DATAPATH_WIDTH)]
} else {
  set LL_OUT_BYTES [expr max($JESD_F,$DATAPATH_WIDTH)]
}

set DMA_SAMPLE_WIDTH $ad_project_params(JESD_NP)
if {$DMA_SAMPLE_WIDTH == 12} {
  set DMA_SAMPLE_WIDTH 16
}

adi_sim_add_define LL_OUT_BYTES=$LL_OUT_BYTES
set NUM_OF_CONVERTERS $ad_project_params(JESD_M)
set NUM_OF_LANES $ad_project_params(JESD_L)
set SAMPLES_PER_FRAME $ad_project_params(JESD_S)
set SAMPLE_WIDTH $ad_project_params(JESD_NP)

set DAC_DATA_WIDTH [expr $NUM_OF_LANES * $LL_OUT_BYTES * 8]
set SAMPLES_PER_CHANNEL [expr $DAC_DATA_WIDTH / $NUM_OF_CONVERTERS / $SAMPLE_WIDTH]

set MAX_CONVERTERS 32
set MAX_LANES 8

set NUM_LINKS 1

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

create_bd_port -dir I ref_clk
create_bd_port -dir I device_clk

# TX JESD204 PHY layer peripheral
ad_ip_instance axi_adxcvr dac_jesd204_xcvr [list \
  LINK_MODE $LINK_MODE \
  NUM_OF_LANES $NUM_OF_LANES \
  QPLL_ENABLE 1 \
  TX_OR_RX_N 1 \
  OUT_CLK_SEL 3 \
  SYS_CLK_SEL 0
]

# TX JESD204 link layer peripheral
adi_axi_jesd204_tx_create dac_jesd204_link $NUM_OF_LANES $NUM_LINKS $LINK_MODE
ad_ip_parameter dac_jesd204_link/tx CONFIG.TPL_DATA_PATH_WIDTH $LL_OUT_BYTES

# TX JESD204 transport layer peripheral
adi_tpl_jesd204_tx_create dac_jesd204_transport $NUM_OF_LANES \
                                                $NUM_OF_CONVERTERS \
                                                $SAMPLES_PER_FRAME \
                                                $SAMPLE_WIDTH \
                                                $LL_OUT_BYTES \
                                                $DMA_SAMPLE_WIDTH

# RX JESD204 PHY layer peripheral
ad_ip_instance axi_adxcvr adc_jesd204_xcvr [list \
  LINK_MODE $LINK_MODE \
  NUM_OF_LANES $NUM_OF_LANES \
  QPLL_ENABLE 0 \
  TX_OR_RX_N 0 \
  OUT_CLK_SEL 3 \
  SYS_CLK_SEL 0
]

# RX JESD204 link layer peripheral
adi_axi_jesd204_rx_create adc_jesd204_link $NUM_OF_LANES $NUM_LINKS $LINK_MODE
ad_ip_parameter adc_jesd204_link/rx CONFIG.TPL_DATA_PATH_WIDTH $LL_OUT_BYTES

# RX JESD204 transport layer peripheral
adi_tpl_jesd204_rx_create adc_jesd204_transport $NUM_OF_LANES \
                                                $NUM_OF_CONVERTERS \
                                                $SAMPLES_PER_FRAME \
                                                $SAMPLE_WIDTH \
                                                $LL_OUT_BYTES \
                                                $DMA_SAMPLE_WIDTH

ad_ip_instance util_adxcvr util_jesd204_xcvr [list \
  LINK_MODE $LINK_MODE \
  RX_NUM_OF_LANES $NUM_OF_LANES \
  TX_NUM_OF_LANES $NUM_OF_LANES \
  CPLL_FBDIV 4 \
  RX_CLK25_DIV 5 \
  TX_CLK25_DIV 5 \
  RX_OUT_DIV 1 \
  TX_OUT_DIV 1 \
]

ad_xcvrcon util_jesd204_xcvr dac_jesd204_xcvr dac_jesd204_link {} {} device_clk
ad_xcvrcon util_jesd204_xcvr adc_jesd204_xcvr adc_jesd204_link {} {} device_clk

# connect link layer to transport layer
ad_connect dac_jesd204_link/tx_data dac_jesd204_transport/link

ad_connect adc_jesd204_link/rx_sof adc_jesd204_transport/link_sof
ad_connect adc_jesd204_link/rx_data_tdata adc_jesd204_transport/link_data
ad_connect adc_jesd204_link/rx_data_tvalid adc_jesd204_transport/link_valid

# reference clocks & resets

ad_xcvrpll ref_clk util_jesd204_xcvr/qpll_ref_clk_*
ad_xcvrpll ref_clk util_jesd204_xcvr/cpll_ref_clk_*
ad_xcvrpll dac_jesd204_xcvr/up_pll_rst util_jesd204_xcvr/up_qpll_rst_*
ad_xcvrpll adc_jesd204_xcvr/up_pll_rst util_jesd204_xcvr/up_cpll_rst_*

ad_connect  $sys_cpu_resetn util_jesd204_xcvr/up_rstn
ad_connect  $sys_cpu_clk util_jesd204_xcvr/up_clk

ad_connect device_clk dac_jesd204_transport/link_clk
ad_connect device_clk adc_jesd204_transport/link_clk

# Create dummy outputs for unused Tx lanes
for {set i $NUM_OF_LANES} {$i < $MAX_LANES} {incr i} {
  create_bd_port -dir O tx_data_${i}_n
  create_bd_port -dir O tx_data_${i}_p
}
# Create dummy outputs for unused Rx lanes
for {set i $NUM_OF_LANES} {$i < $MAX_LANES} {incr i} {
  create_bd_port -dir I rx_data_${i}_n
  create_bd_port -dir I rx_data_${i}_p
}

ad_cpu_interconnect 0x44a60000 adc_jesd204_xcvr
ad_cpu_interconnect 0x44b60000 dac_jesd204_xcvr
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

