# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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

global ad_project_params

set dac_offload_type $ad_project_params(DAC_OFFLOAD_TYPE)
set dac_offload_size $ad_project_params(DAC_OFFLOAD_SIZE)
set adc_offload_type $ad_project_params(ADC_OFFLOAD_TYPE)
set adc_offload_size $ad_project_params(ADC_OFFLOAD_SIZE)
set plddr_offload_axi_data_width $ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH)

# Ref clk
ad_ip_instance clk_vip ref_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "REF_CLK=ref_clk_vip"
create_bd_port -dir O ref_clk_out
ad_connect ref_clk_out ref_clk_vip/clk_out

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

source $ad_hdl_dir/projects/fmcomms11/common/fmcomms11_bd.tcl

set RX_DMA 0x7C400000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9625_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set RX_XCVR 0x44A50000
set_property offset $RX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9625_xcvr}]
adi_sim_add_define "RX_XCVR_BA=[format "%d" ${RX_XCVR}]"

set TX_DMA 0x7C420000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9162_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"

set TX_XCVR 0x44A60000
set_property offset $TX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9162_xcvr}]
adi_sim_add_define "TX_XCVR_BA=[format "%d" ${TX_XCVR}]"

set AXI_JESD_RX 0x44AA0000
set_property offset $AXI_JESD_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9625_jesd}]
adi_sim_add_define "AXI_JESD_RX_BA=[format "%d" ${AXI_JESD_RX}]"

set ADC_TPL 0x44A10000
set_property offset $ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9625_core}]
adi_sim_add_define "ADC_TPL_BA=[format "%d" ${ADC_TPL}]"

set DAC_TPL 0x44A00000
set_property offset $DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9162_core}]
adi_sim_add_define "DAC_TPL_BA=[format "%d" ${DAC_TPL}]"

set AXI_JESD_TX 0x44A90000
set_property offset $AXI_JESD_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9162_jesd}]
adi_sim_add_define "AXI_JESD_TX_BA=[format "%d" ${AXI_JESD_TX}]"

set RX_OFFLOAD 0x7C410000
set_property offset $RX_OFFLOAD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad9625_data_offload}]
adi_sim_add_define "RX_OFFLOAD_BA=[format "%d" ${RX_OFFLOAD}]"

set TX_OFFLOAD 0x7C430000
set_property offset $TX_OFFLOAD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad9162_data_offload}]
adi_sim_add_define "TX_OFFLOAD_BA=[format "%d" ${TX_OFFLOAD}]"
