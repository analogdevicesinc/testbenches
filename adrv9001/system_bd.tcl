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

global ad_project_params

# Device clk
ad_ip_instance clk_vip ssi_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "SSI_CLK=ssi_clk_vip"
create_bd_port -dir O ssi_clk_out
ad_connect ssi_clk_out ssi_clk_vip/clk_out

#
#  Block design under test
#
#
source $ad_hdl_dir/projects/adrv9001/common/adrv9001_bd.tcl

ad_ip_parameter axi_adrv9001 CONFIG.USE_RX_CLK_FOR_TX $ad_project_params(USE_RX_CLK_FOR_TX)
ad_ip_parameter axi_adrv9001 CONFIG.DDS_DISABLE $ad_project_params(DDS_DISABLE)

set RX1_DMA 0x44A30000
set_property offset $RX1_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9001_rx1_dma}]
adi_sim_add_define "RX1_DMA_BA=[format "%d" ${RX1_DMA}]"

set RX2_DMA 0x44A40000
set_property offset $RX2_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9001_rx2_dma}]
adi_sim_add_define "RX2_DMA_BA=[format "%d" ${RX2_DMA}]"

set TX1_DMA 0x44A50000
set_property offset $TX1_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9001_tx1_dma}]
adi_sim_add_define "TX1_DMA_BA=[format "%d" ${TX1_DMA}]"

set TX2_DMA 0x44A60000
set_property offset $TX2_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9001_tx2_dma}]
adi_sim_add_define "TX2_DMA_BA=[format "%d" ${TX2_DMA}]"

set AXI_ADRV9001 0x44A00000
set_property offset $AXI_ADRV9001 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9001}]
adi_sim_add_define "AXI_ADRV9001_BA=[format "%d" ${AXI_ADRV9001}]"
