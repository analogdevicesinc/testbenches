# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

#
#  Block design under test
#

# ---------------------------------------------------------------
# Parallel interface mode: DDR infrastructure is kept for the
# DMA read path. dma_clk_vip stays at default 200 MHz; the DUT's
# async FIFO handles CDC between DMA and pd_clk domains.
# ---------------------------------------------------------------

# Create axi_ad9910 instance.
# MEASURE_CLKS_EN generates the sync_clk/pd_clk monitors behind SYNC_CLK_CNT
# (0x20) and PD_CLK_COUNT (0x40); without it those registers read zero.
ad_ip_instance axi_ad9910 axi_ad9910 [list \
  IODELAY_ENABLE 0 \
  MEASURE_CLKS_EN 1 \
]

# Pass-through clock VIPs for pd_clk and sync_clk
# Allows test program to monitor or override clocks at runtime
ad_ip_instance clk_vip pd_clk_vip [list \
  INTERFACE_MODE {PASS_THROUGH} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "PD_CLK_VIP=pd_clk_vip"

ad_ip_instance clk_vip sync_clk_vip [list \
  INTERFACE_MODE {PASS_THROUGH} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "SYNC_CLK_VIP=sync_clk_vip"

# Route external clock ports through the VIPs to the DUT
create_bd_port -dir I sync_clk_in
ad_connect sync_clk_in sync_clk_vip/clk_in
ad_connect sync_clk_vip/clk_out axi_ad9910/sync_clk

ad_connect sys_cpu_clk axi_ad9910/delay_clk

create_bd_port -dir I pd_clk_in
ad_connect pd_clk_in pd_clk_vip/clk_in
ad_connect pd_clk_vip/clk_out axi_ad9910/pd_clk_in

# Connect AXI interface
ad_cpu_interconnect 0x44A00000 axi_ad9910

# Create external ports for device control
create_bd_port -dir I ext_sync
create_bd_port -dir O ad9910_irq
create_bd_port -dir O trig_out

# Create external ports for DDS ramp control interface
create_bd_port -dir O drctl
create_bd_port -dir O drhold
create_bd_port -dir I drover
create_bd_port -dir I ram_swp_ovr
create_bd_port -dir O -from 2 -to 0 profile

# Create external ports for parallel data interface
create_bd_port -dir O -from 1 -to 0 f_o
create_bd_port -dir O -from 15 -to 0 db_o
create_bd_port -dir O tx_enable

# Connect device control signals
ad_connect axi_ad9910/ext_sync ext_sync
ad_connect axi_ad9910/irq ad9910_irq
ad_connect axi_ad9910/trig_out trig_out

# Connect ramp control signals
ad_connect axi_ad9910/drctl drctl
ad_connect axi_ad9910/drhold drhold
ad_connect axi_ad9910/drover drover
ad_connect axi_ad9910/ram_swp_ovr ram_swp_ovr
ad_connect axi_ad9910/profile profile

# Connect parallel data interface
ad_connect axi_ad9910/f_o f_o
ad_connect axi_ad9910/db_o db_o
ad_connect axi_ad9910/tx_enable tx_enable

# AXI-Stream interface configuration (MODE-dependent)
if {$ad_project_params(MODE) == "PAR_IF"} {

  # AXIS domain runs on the DMA clock (pd_clk via dma_clk_vip)
  ad_connect sys_dma_clk axi_ad9910/s_axis_aclk
  ad_connect sys_dma_resetn axi_ad9910/s_axis_aresetn

  # Instantiate TX DMA (reads DDR via AXI MM, outputs AXI-Stream to DUT)
  ad_ip_instance axi_dmac tx_dma $ad_project_params(tx_dma_cfg)
  adi_sim_add_define "TX_DMA=tx_dma"

  # DMA clocks and resets
  ad_connect sys_dma_clk tx_dma/m_axis_aclk
  ad_connect sys_dma_resetn tx_dma/m_src_axi_aresetn

  # DMA AXI-Stream output → DUT AXI-Stream input
  ad_connect tx_dma/m_axis axi_ad9910/s_axis

  # TLAST is not part of the DUT bus interface; tie to GND
  ad_connect axi_ad9910/s_axis_tlast GND

  # DMA DDR read port → memory interconnect
  ad_mem_hp0_interconnect $sys_dma_clk tx_dma/m_src_axi

  # DMA register access via CPU interconnect
  ad_cpu_interconnect 0x44A30000 tx_dma

  # DMA interrupt
  ad_cpu_interrupt ps-13 mb-12 tx_dma/irq

  # Set DMA base address define
  set BA_TX_DMA 0x44A30000
  set_property offset $BA_TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_tx_dma}]
  adi_sim_add_define "TX_DMA_BA=[format "%d" ${BA_TX_DMA}]"

} else {

  # DRG mode — AXIS on CPU clock, no DMA needed
  ad_connect sys_cpu_clk axi_ad9910/s_axis_aclk
  ad_connect sys_cpu_resetn axi_ad9910/s_axis_aresetn

  # Tie AXI-Stream inputs to ground
  create_bd_port -dir O s_axis_tready
  ad_connect axi_ad9910/s_axis_tready s_axis_tready

  ad_connect axi_ad9910/s_axis_tvalid GND
  ad_connect axi_ad9910/s_axis_tlast GND
  ad_connect axi_ad9910/s_axis_tdata GND

}

# Set base address define
set BA_AD9910 0x44A00000
adi_sim_add_define "AXI_AD9910_BA=[format "%d" ${BA_AD9910}]"
