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

source $ad_hdl_dir/projects/common/xilinx/adcfifo_bd.tcl
source $ad_hdl_dir/projects/common/xilinx/dacfifo_bd.tcl

## ADC FIFO depth in samples per converter
set adc_fifo_samples_per_converter [expr 4*1024]
## DAC FIFO depth in samples per converter
set dac_fifo_samples_per_converter [expr 4*1024]

# DRP clk for 204C phy
ad_ip_instance clk_vip drp_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 50000000 \
]
adi_sim_add_define "DRP_CLK=drp_clk_vip"

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

###

set NUM_OF_LANES 4
set NUM_OF_CONVERTERS 16
set SAMPLES_PER_FRAME 1
set SAMPLE_WIDTH 16
#set LL_OUT_BYTES
set DMA_SAMPLE_WIDTH 16
set SAMPLES_PER_CHANNEL 1

create_bd_port -dir I vip_ref_clk
create_bd_port -dir I vip_device_clk

ad_connect vip_device_clk_s vip_device_clk

# TX JESD204 PHY layer peripheral
ad_ip_instance axi_adxcvr dac_jesd204_xcvr [list \
  NUM_OF_LANES $NUM_OF_LANES \
  QPLL_ENABLE 1 \
  TX_OR_RX_N 1 \
  OUT_CLK_SEL 3 \
  SYS_CLK_SEL 3 \
]

# TX JESD204 link layer peripheral
adi_axi_jesd204_tx_create dac_jesd204_link $NUM_OF_LANES
#ad_ip_parameter dac_jesd204_link/tx CONFIG.TPL_DATA_PATH_WIDTH $LL_OUT_BYTES
ad_ip_parameter dac_jesd204_link/tx CONFIG.TPL_DATA_PATH_WIDTH 8

# TX JESD204 transport layer peripheral
adi_tpl_jesd204_tx_create dac_jesd204_transport $NUM_OF_LANES \
                                                $NUM_OF_CONVERTERS \
                                                $SAMPLES_PER_FRAME \
                                                $SAMPLE_WIDTH

ad_ip_instance util_adxcvr util_jesd204_xcvr [list \
  RX_NUM_OF_LANES 0 \
  TX_NUM_OF_LANES $NUM_OF_LANES \
  QPLL_FBDIV 40 \
  QPLL_REFCLK_DIV 2 \
  RX_OUT_DIV 1 \
  RX_CLK25_DIV 10 \
  POR_CFG 0x0 \
  QPLL_CFG0 0x391c \
  QPLL_CFG1 0x0000 \
  QPLL_CFG1_G3 0x0020 \
  QPLL_CFG2 0x0f80 \
  QPLL_CFG2_G3 0x0f80 \
  QPLL_CFG3 0x0120 \
  QPLL_CFG4 0x0002 \
  QPLL_CP 0x1f \
  QPLL_CP_G3 0x1f \
  QPLL_LPF 0x2ff \
  CH_HSPMUX 0x2424 \
  PREIQ_FREQ_BST 0 \
  RXPI_CFG0 0x0002 \
  RXPI_CFG1 0x0 \
  RXCDR_CFG0 0x3 \
  RXCDR_CFG2_GEN2 0x164 \
  RXCDR_CFG2_GEN4 0x0 \
  RXCDR_CFG3 0x2a \
  RXCDR_CFG3_GEN2 0x24 \
  RXCDR_CFG3_GEN3 0x0 \
  RXCDR_CFG3_GEN4 0x0 \
  ]

ad_xcvrcon util_jesd204_xcvr dac_jesd204_xcvr dac_jesd204_link {} {} vip_device_clk
ad_connect dac_jesd204_link/tx_data dac_jesd204_transport/link
ad_xcvrpll dac_jesd204_xcvr/up_pll_rst util_jesd204_xcvr/up_qpll_rst_*
ad_xcvrpll dac_jesd204_xcvr/up_pll_rst util_jesd204_xcvr/up_cpll_rst_*
ad_connect  $sys_cpu_resetn util_jesd204_xcvr/up_rstn

ad_connect device_clk dac_jesd204_transport/link_clk

ad_xcvrpll vip_ref_clk util_jesd204_xcvr/qpll_ref_clk_*
ad_xcvrpll vip_ref_clk util_jesd204_xcvr/cpll_ref_clk_*

ad_connect $sys_cpu_clk util_jesd204_xcvr/up_clk
ad_connect vip_device_clk dac_jesd204_transport/link_clk

for {set i 0} {$i < $NUM_OF_CONVERTERS} {incr i} {
  create_bd_port -dir I -from [expr $SAMPLES_PER_CHANNEL*$DMA_SAMPLE_WIDTH-1] -to 0 dac_data_$i
  ad_connect dac_data_$i dac_jesd204_transport/dac_data_$i
}
make_bd_pins_external  [get_bd_pins /dac_jesd204_transport/dac_dunf]

ad_cpu_interconnect 0x44b60000 dac_jesd204_xcvr
ad_cpu_interconnect 0x44b90000 dac_jesd204_link
ad_cpu_interconnect 0x44b10000 dac_jesd204_transport

#
#  Block design under test
#
#
source $ad_hdl_dir/projects/ad9083_evb/common/ad9083_evb_bd.tcl

if {$ad_project_params(JESD_MODE) == "8B10B"} {
} else {
  ad_connect  drp_clk_vip/clk_out jesd204_phy_121/drpclk
  ad_connect  drp_clk_vip/clk_out jesd204_phy_126/drpclk
}

adi_sim_add_define "JESD_MODE=\"$JESD_MODE\""

