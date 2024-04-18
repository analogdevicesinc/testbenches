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

source ../../scripts/adi_env.tcl

global m_dma_cfg
global s_dma_cfg
global vdma_cfg
global src_axis_vip_cfg
global dst_axis_vip_cfg

set has_xil_vdma 0

ad_ip_instance clk_vip src_clk_vip [list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ {100000000} \
]
ad_ip_instance clk_vip dst_clk_vip [list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ {200000000} \
]

adi_sim_add_define "SRC_CLK=src_clk_vip"
adi_sim_add_define "DST_CLK=dst_clk_vip"

# create data source and consumer
ad_ip_instance axi4stream_vip src_axis_vip $src_axis_vip_cfg
ad_ip_instance axi4stream_vip dst_axis_vip $dst_axis_vip_cfg

adi_sim_add_define "SRC_AXIS=src_axis_vip"
adi_sim_add_define "DST_AXIS=dst_axis_vip"

## connect clocks
ad_connect dst_clk_vip/clk_out dst_axis_vip/aclk
ad_connect src_clk_vip/clk_out src_axis_vip/aclk

## connect resets
ad_connect $sys_dma_resetn src_axis_vip/aresetn
ad_connect $sys_dma_resetn dst_axis_vip/aresetn

# create external syncs
if {[dict exists $m_dma_cfg USE_EXT_SYNC]} {
  if {[dict get $m_dma_cfg USE_EXT_SYNC] == 1} {
    ad_ip_instance io_vip src_sync_io_vip
    adi_sim_add_define "SRC_SYNC_IO=src_sync_io_vip"

    ## connect clocks
    ad_connect src_clk_vip/clk_out src_sync_io_vip/clk
  }
}
if {[dict exists $s_dma_cfg USE_EXT_SYNC]} {
  if {[dict get $s_dma_cfg USE_EXT_SYNC] == 1} {
    ad_ip_instance io_vip dst_sync_io_vip
    adi_sim_add_define "DST_SYNC_IO=dst_sync_io_vip"

    ## connect clocks
    ad_connect dst_clk_vip/clk_out dst_sync_io_vip/clk
  }
}

# create DMAs
ad_ip_instance axi_dmac dut_tx_dma $m_dma_cfg
ad_ip_instance axi_dmac dut_rx_dma $s_dma_cfg

adi_sim_add_define "DUT_TX_DMA=dut_tx_dma"
adi_sim_add_define "DUT_RX_DMA=dut_rx_dma"
ad_connect sys_dma_clk dut_rx_dma/m_src_axi_aclk
ad_connect sys_dma_clk dut_tx_dma/m_dest_axi_aclk

## connect clocks
ad_connect dst_clk_vip/clk_out dut_rx_dma/m_axis_aclk
ad_connect src_clk_vip/clk_out dut_tx_dma/s_axis_aclk

## connect resets
ad_connect $sys_dma_resetn dut_rx_dma/m_src_axi_aresetn
ad_connect $sys_dma_resetn dut_tx_dma/m_dest_axi_aresetn

## connect data source and consumer
ad_connect dut_rx_dma/m_axis dst_axis_vip/S_AXIS
ad_connect src_axis_vip/M_AXIS dut_tx_dma/s_axis

## connect external syncs
if {[dict exists $m_dma_cfg USE_EXT_SYNC]} {
  if {[dict get $m_dma_cfg USE_EXT_SYNC] == 1} {
    ad_connect src_sync_io_vip/out dut_tx_dma/src_ext_sync
  }
}
if {[dict exists $s_dma_cfg USE_EXT_SYNC]} {
  if {[dict get $s_dma_cfg USE_EXT_SYNC] == 1} {
    ad_connect dst_sync_io_vip/out dut_rx_dma/dest_ext_sync
  }
}

## connect framelock
ad_connect dut_tx_dma/m_framelock dut_rx_dma/s_framelock

## connect cpu

ad_cpu_interconnect 0x7C420000 dut_rx_dma
ad_cpu_interconnect 0x7C430000 dut_tx_dma

ad_mem_hp0_interconnect $sys_dma_clk dut_rx_dma/m_src_axi
ad_mem_hp0_interconnect $sys_dma_clk dut_tx_dma/m_dest_axi

ad_cpu_interrupt ps-13 mb-12 dut_rx_dma/irq
ad_cpu_interrupt ps-12 mb-13 dut_tx_dma/irq

set RX_DMA 0x7C420000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dut_rx_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set TX_DMA 0x7C430000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dut_tx_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"

set_property offset 0x0 [get_bd_addr_segs {dut_tx_dma/m_dest_axi/SEG_ddr_axi_vip_Reg}]
set_property offset 0x0 [get_bd_addr_segs {dut_rx_dma/m_src_axi/SEG_ddr_axi_vip_Reg}]

if {$has_xil_vdma == 1} {

  adi_sim_add_define "HAS_XIL_VDMA="

  # Create VDMA
  ad_ip_instance axi_vdma vdma $vdma_cfg

  # Create data source and destination for VDMA
  ad_ip_instance axi4stream_vip ref_src_axis_vip $src_axis_vip_cfg
  ad_ip_instance axi4stream_vip ref_dst_axis_vip $dst_axis_vip_cfg

  adi_sim_add_define "REF_SRC_AXIS=ref_src_axis_vip"
  adi_sim_add_define "REF_DST_AXIS=ref_dst_axis_vip"

  #  ref src AXIS - VDMA - ddr interconnect
  ad_connect ref_src_axis_vip/M_AXIS vdma/S_AXIS_S2MM
  ad_mem_hp0_interconnect $sys_dma_clk vdma/M_AXI_S2MM

  ## ddr interconnect - VDMA - ref dest AXIS
  ad_mem_hp0_interconnect $sys_dma_clk vdma/M_AXI_MM2S
  ad_connect vdma/M_AXIS_MM2S ref_dst_axis_vip/S_AXIS

  set VDMA 0x44A20000
  ad_cpu_interconnect $VDMA vdma
  adi_sim_add_define "VDMA_BA=[format "%d" ${VDMA}]"

  # connect external syncs to VDMA
  if {[dict exists $vdma_cfg c_use_s2mm_fsync]} {
    if {[dict get $vdma_cfg c_use_s2mm_fsync] == 1} {
      ad_connect src_sync_io_vip/out vdma/s2mm_fsync
    }
  }
  if {[dict exists $vdma_cfg c_use_mm2s_fsync]} {
    if {[dict get $vdma_cfg c_use_mm2s_fsync] == 1} {
      ad_connect dst_sync_io_vip/out vdma/mm2s_fsync
    }
  }

  ad_connect $sys_dma_resetn ref_src_axis_vip/aresetn
  ad_connect $sys_dma_resetn ref_dst_axis_vip/aresetn
  ad_connect sys_cpu_clk vdma/m_axis_mm2s_aclk
  ad_connect sys_cpu_clk vdma/s_axis_s2mm_aclk
  ad_connect sys_cpu_clk ref_src_axis_vip/aclk
  ad_connect sys_cpu_clk ref_dst_axis_vip/aclk
}
