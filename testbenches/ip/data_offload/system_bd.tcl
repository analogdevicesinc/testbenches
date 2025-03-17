# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2022 Analog Devices, Inc. All rights reserved.
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

source "$ad_hdl_dir/projects/common/xilinx/data_offload_bd.tcl"

## DUT configuration

set adc_data_path_width $ad_project_params(ADC_DATA_PATH_WIDTH)
set dac_data_path_width $ad_project_params(DAC_DATA_PATH_WIDTH)

set adc_path_type $ad_project_params(ADC_PATH_TYPE)
set adc_offload_mem_type $ad_project_params(ADC_OFFLOAD_MEM_TYPE)
set adc_offload_size $ad_project_params(ADC_OFFLOAD_SIZE)
set adc_offload_src_dwidth $ad_project_params(ADC_OFFLOAD_SRC_DWIDTH)
set adc_offload_dst_dwidth $ad_project_params(ADC_OFFLOAD_DST_DWIDTH)

set dac_path_type $ad_project_params(DAC_PATH_TYPE)
set dac_offload_mem_type $ad_project_params(DAC_OFFLOAD_MEM_TYPE)
set dac_offload_size $ad_project_params(DAC_OFFLOAD_SIZE)
set dac_offload_src_dwidth $ad_project_params(DAC_OFFLOAD_SRC_DWIDTH)
set dac_offload_dst_dwidth $ad_project_params(DAC_OFFLOAD_DST_DWIDTH)

set plddr_offload_data_width $ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH)

ad_ip_instance xlconstant GND [list \
  CONST_VAL 0 \
]
ad_connect gnd GND/dout

ad_ip_instance axi_dmac i_rx_dmac [list \
  DMA_TYPE_SRC 1 \
  DMA_TYPE_DEST 0 \
  ID 0 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  MAX_BYTES_PER_BURST 4096 \
  CYCLIC 0 \
  DMA_DATA_WIDTH_SRC $adc_offload_dst_dwidth \
  DMA_DATA_WIDTH_DEST 64 \
]

ad_ip_instance axi_dmac i_tx_dmac [list \
  DMA_TYPE_SRC 0 \
  DMA_TYPE_DEST 1 \
  ID 0 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  MAX_BYTES_PER_BURST 4096 \
  CYCLIC 1 \
  DMA_DATA_WIDTH_SRC 64 \
  DMA_DATA_WIDTH_DEST $dac_offload_src_dwidth \
]

ad_data_offload_create RX_DUT \
                        0 \
                        $adc_offload_mem_type \
                        $adc_offload_size \
                        $adc_offload_src_dwidth \
                        $adc_offload_dst_dwidth \
                        $plddr_offload_data_width

ad_data_offload_create TX_DUT \
                        1 \
                        $dac_offload_mem_type \
                        $dac_offload_size \
                        $dac_offload_src_dwidth \
                        $dac_offload_dst_dwidth \
                        $plddr_offload_data_width

set RX_DMAC_BA 0x50040000
ad_cpu_interconnect $RX_DMAC_BA i_rx_dmac
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMAC_BA}]"

set TX_DMAC_BA 0x50050000
ad_cpu_interconnect $TX_DMAC_BA i_tx_dmac
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMAC_BA}]"

set RX_DO_BA 0x50060000
ad_cpu_interconnect $RX_DO_BA RX_DUT
adi_sim_add_define "RX_DOFF_BA=[format "%d" ${RX_DO_BA}]"

set TX_DO_BA 0x50070000
ad_cpu_interconnect $TX_DO_BA TX_DUT
adi_sim_add_define "TX_DOFF_BA=[format "%d" ${TX_DO_BA}]"

ad_ip_instance axi4stream_vip adc_src_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY {1} \
  HAS_TLAST {0} \
  TDATA_NUM_BYTES $adc_data_path_width \
]
adi_sim_add_define "ADC_SRC_AXIS=adc_src_axis"

ad_connect adc_src_axis/m_axis RX_DUT/s_axis
ad_connect RX_DUT/m_axis i_rx_dmac/s_axis

ad_connect sys_dma_clk adc_src_axis/aclk
ad_connect sys_dma_resetn adc_src_axis/aresetn

ad_connect sys_dma_clk RX_DUT/s_axis_aclk
ad_connect sys_dma_resetn RX_DUT/s_axis_aresetn
ad_connect sys_cpu_clk RX_DUT/m_axis_aclk
ad_connect sys_cpu_resetn RX_DUT/m_axis_aresetn

ad_connect sys_cpu_clk i_rx_dmac/s_axis_aclk
ad_connect sys_mem_clk i_rx_dmac/m_dest_axi_aclk
ad_connect sys_mem_resetn i_rx_dmac/m_dest_axi_aresetn

ad_connect i_rx_dmac/s_axis_xfer_req RX_DUT/init_req
ad_connect gnd RX_DUT/sync_ext

ad_mem_hp0_interconnect sys_mem_clk i_rx_dmac/m_dest_axi

ad_ip_instance axi4stream_vip dac_dst_axis [list \
  INTERFACE_MODE {SLAVE} \
  TDATA_NUM_BYTES $dac_data_path_width \
  HAS_TLAST {1} \
  HAS_TKEEP {0} \
]
adi_sim_add_define "DAC_DST_AXIS=dac_dst_axis"

ad_connect sys_dma_clk dac_dst_axis/aclk
ad_connect sys_dma_resetn dac_dst_axis/aresetn

ad_connect sys_dma_clk TX_DUT/m_axis_aclk
ad_connect sys_dma_resetn TX_DUT/m_axis_aresetn
ad_connect sys_cpu_clk TX_DUT/s_axis_aclk
ad_connect sys_cpu_resetn TX_DUT/s_axis_aresetn

ad_connect sys_cpu_clk i_tx_dmac/m_axis_aclk
ad_connect sys_mem_clk i_tx_dmac/m_src_axi_aclk
ad_connect sys_mem_resetn i_tx_dmac/m_src_axi_aresetn

ad_connect TX_DUT/m_axis dac_dst_axis/s_axis
ad_connect TX_DUT/s_axis i_tx_dmac/m_axis

ad_connect i_tx_dmac/m_axis_xfer_req TX_DUT/init_req
ad_connect gnd TX_DUT/sync_ext

ad_mem_hp0_interconnect sys_mem_clk i_tx_dmac/m_src_axi

if {$adc_offload_mem_type} {
  set plddr_iname "RX_DUT"
} elseif {$dac_offload_mem_type} {
  set plddr_iname "TX_DUT"
} else {
  set plddr_iname "NONE"
}

if {![string equal $plddr_iname "NONE"]} {
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 $plddr_iname/m_axi

  create_bd_pin -dir I -type clk $plddr_iname/m_axi_aclk
  create_bd_pin -dir I -type rst $plddr_iname/m_axi_aresetn

  ad_connect $plddr_iname/m_axi_aclk $plddr_iname/storage_unit/m_axi_aclk
  ad_connect $plddr_iname/m_axi_aresetn $plddr_iname/storage_unit/m_axi_aresetn

  ad_connect $plddr_iname/m_axi_aclk sys_mem_clk
  ad_connect $plddr_iname/m_axi_aresetn sys_mem_resetn

  ad_connect $plddr_iname/m_axi $plddr_iname/storage_unit/MAXI_0

  ad_mem_hp0_interconnect sys_mem_clk $plddr_iname/m_axi
}
