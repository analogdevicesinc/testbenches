# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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

# Device clk
ad_ip_instance clk_vip device_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 62500000 \
]
adi_sim_add_define "DEVICE_CLK=device_clk_vip"

set device_clk device_clk_vip/clk_out

#  ------------------
#
# Blocks under test
#
#  ------------------

global rx_dma_cfg
global tx_dma_cfg

ad_ip_instance axi_dmac dut_rx_dma $rx_dma_cfg
ad_ip_instance axi_dmac dut_tx_dma $tx_dma_cfg

ad_connect  $device_clk dut_rx_dma/s_axis_aclk
ad_connect  $device_clk dut_tx_dma/m_axis_aclk

# connect resets
ad_connect  $sys_cpu_resetn dut_rx_dma/m_dest_axi_aresetn
ad_connect  $sys_cpu_resetn dut_tx_dma/m_src_axi_aresetn

ad_connect  $sys_cpu_resetn dut_rx_dma/m_sg_axi_aresetn
ad_connect  $sys_cpu_resetn dut_tx_dma/m_sg_axi_aresetn

# create loopback
ad_connect  dut_tx_dma/m_axis dut_rx_dma/s_axis

ad_cpu_interconnect 0x7c420000 dut_rx_dma
ad_cpu_interconnect 0x7c430000 dut_tx_dma

ad_mem_hp0_interconnect $sys_cpu_clk dut_rx_dma/m_dest_axi
ad_mem_hp0_interconnect $sys_cpu_clk dut_tx_dma/m_src_axi

ad_mem_hp0_interconnect $sys_cpu_clk dut_rx_dma/m_sg_axi
ad_mem_hp0_interconnect $sys_cpu_clk dut_tx_dma/m_sg_axi

ad_cpu_interrupt ps-13 mb-12 dut_rx_dma/irq
ad_cpu_interrupt ps-12 mb-13 dut_tx_dma/irq

set RX_DMA 0x7C420000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dut_rx_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set TX_DMA 0x7C430000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dut_tx_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"
