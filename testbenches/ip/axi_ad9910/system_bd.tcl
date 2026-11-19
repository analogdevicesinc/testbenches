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

# Master clock VIPs for sync_clk and pd_clk, standing in for the AD9910's
# SYNC_CLK and PDCLK outputs. Started and stopped by the test program.
ad_ip_instance clk_vip pd_clk_vip [list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "PD_CLK_VIP=pd_clk_vip"

ad_ip_instance clk_vip sync_clk_vip [list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "SYNC_CLK_VIP=sync_clk_vip"

ad_connect sync_clk_vip/clk_out axi_ad9910/sync_clk
ad_connect pd_clk_vip/clk_out axi_ad9910/pd_clk_in

ad_connect sys_cpu_clk axi_ad9910/delay_clk

# Connect AXI interface
set BA_AD9910 0x44A00000
ad_cpu_interconnect $BA_AD9910 axi_ad9910
adi_sim_add_define "AXI_AD9910_BA=[format "%d" ${BA_AD9910}]"

# IO VIPs for the device-side pins. MASTER VIPs (MODE 1) drive the AD9910's
# outputs into the DUT; SLAVE VIPs (MODE 0) sample the DUT's outputs for the
# test program. Each is clocked by the domain its pin belongs to. Every VIP is
# built in both modes, since the DUT has all of the pins in both.
#   VIP                MODE WIDTH clock         DUT pin
foreach {vip mode width clk pin} {
  ext_sync_vip         1    1     pd_clk_vip    ext_sync
  drover_vip           1    1     sync_clk_vip  drover
  ram_swp_ovr_vip      1    1     sync_clk_vip  ram_swp_ovr
  ad9910_irq_vip       0    1     sync_clk_vip  irq
  trig_out_vip         0    1     sync_clk_vip  trig_out
  drctl_vip            0    1     sync_clk_vip  drctl
  drhold_vip           0    1     sync_clk_vip  drhold
  profile_vip          0    3     sync_clk_vip  profile
  f_o_vip              0    2     pd_clk_vip    f_o
  db_o_vip             0    16    pd_clk_vip    db_o
  tx_enable_vip        0    1     pd_clk_vip    tx_enable
} {
  ad_ip_instance io_vip $vip [list \
    MODE $mode \
    WIDTH $width \
  ]
  adi_sim_add_define "[string toupper $vip]=$vip"
  ad_connect $clk/clk_out $vip/clk
  if {$mode == 1} {
    ad_connect $vip/o axi_ad9910/$pin
  } else {
    ad_connect axi_ad9910/$pin $vip/i
  }
}

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

  # DMA DDR read port → memory interconnect
  ad_mem_hp0_interconnect $sys_dma_clk tx_dma/m_src_axi

  # DMA register access via CPU interconnect
  set BA_TX_DMA 0x44A30000
  ad_cpu_interconnect $BA_TX_DMA tx_dma
  adi_sim_add_define "TX_DMA_BA=[format "%d" ${BA_TX_DMA}]"

  # DMA interrupt
  ad_cpu_interrupt ps-13 mb-12 tx_dma/irq

} else {

  # DRG mode — AXIS on CPU clock, no DMA needed
  ad_connect sys_cpu_clk axi_ad9910/s_axis_aclk
  ad_connect sys_cpu_resetn axi_ad9910/s_axis_aresetn

  # Tie AXI-Stream inputs to ground
  ad_connect axi_ad9910/s_axis_tvalid GND
  ad_connect axi_ad9910/s_axis_tlast GND
  ad_connect axi_ad9910/s_axis_tdata GND

}
