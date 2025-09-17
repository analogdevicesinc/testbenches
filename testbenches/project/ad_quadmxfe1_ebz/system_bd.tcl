# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2018-2025 Analog Devices, Inc. All rights reserved.
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
#      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
#      This will allow to generate bit files and not release the source code,
#      as long as it attaches to an ADI device.
#
# ***************************************************************************
# ***************************************************************************

global ad_project_params

## Data Offload
## ADC FIFO depth in samples per converter
set adc_fifo_samples_per_converter [expr $ad_project_params(RX_KS_PER_CHANNEL)*1024]
## DAC FIFO depth in samples per converter
set dac_fifo_samples_per_converter [expr $ad_project_params(TX_KS_PER_CHANNEL)*1024]
set rd_data_registered $ad_project_params(RD_DATA_REGISTERED)
set rd_fifo_address_width $ad_project_params(RD_FIFO_ADDRESS_WIDTH)

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


#
#  Block design under test
#
#
source $ad_hdl_dir/projects/ad_quadmxfe1_ebz/common/ad_quadmxfe1_ebz_bd.tcl

ad_ip_parameter $dac_offload_name/storage_unit CONFIG.RD_DATA_REGISTERED $rd_data_registered
ad_ip_parameter $dac_offload_name/storage_unit CONFIG.RD_FIFO_ADDRESS_WIDTH $rd_fifo_address_width

if {$ad_project_params(JESD_MODE) == "8B10B"} {
} else {
  ad_connect  drp_clk_vip/clk_out jesd204_phy_121_122/drpclk
  ad_connect  drp_clk_vip/clk_out jesd204_phy_125_126/drpclk
}

adi_sim_add_define "JESD_MODE=\"$JESD_MODE\""

set RX_DMA 0x7C420000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_mxfe_rx_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set RX_OFFLOAD 0x7C450000
set_property offset $RX_OFFLOAD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_mxfe_rx_data_offload}]
adi_sim_add_define "RX_OFFLOAD_BA=[format "%d" ${RX_OFFLOAD}]"

set AXI_JESD_RX 0x44A90000
set_property offset $AXI_JESD_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_mxfe_rx_jesd}]
adi_sim_add_define "AXI_JESD_RX_BA=[format "%d" ${AXI_JESD_RX}]"

set ADC_TPL 0x44A10000
set_property offset $ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_rx_mxfe_tpl_core}]
adi_sim_add_define "ADC_TPL_BA=[format "%d" ${ADC_TPL}]"

set TX_DMA 0x7C430000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_mxfe_tx_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"

set TX_OFFLOAD 0x7C460000
set_property offset $TX_OFFLOAD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_mxfe_tx_data_offload}]
adi_sim_add_define "TX_OFFLOAD_BA=[format "%d" ${TX_OFFLOAD}]"

set AXI_JESD_TX 0x44B90000
set_property offset $AXI_JESD_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_mxfe_tx_jesd}]
adi_sim_add_define "AXI_JESD_TX_BA=[format "%d" ${AXI_JESD_TX}]"

set DAC_TPL 0x44B10000
set_property offset $DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_tx_mxfe_tpl_core}]
adi_sim_add_define "DAC_TPL_BA=[format "%d" ${DAC_TPL}]"

set RX_XCVR 0x44A60000
adi_sim_add_define "RX_XCVR_BA=[format "%d" ${RX_XCVR}]"

set TX_XCVR 0x44B60000
adi_sim_add_define "TX_XCVR_BA=[format "%d" ${TX_XCVR}]"

if {$ad_project_params(JESD_MODE) == "8B10B"} {
  set_property offset $RX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_mxfe_rx_xcvr}]
  set_property offset $TX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_mxfe_tx_xcvr}]
}
