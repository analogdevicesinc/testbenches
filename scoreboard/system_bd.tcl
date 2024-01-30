# ***************************************************************************
# ***************************************************************************
# Copyright 2022 (c) Analog Devices, Inc. All rights reserved.
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

global ad_hdl_dir

source ../../scripts/adi_env.tcl

source "$ad_hdl_dir/projects/common/xilinx/data_offload_bd.tcl"

global ad_project_params

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

set ddr_axi_pt_cfg [list \
 INTERFACE_MODE {PASS_THROUGH} \
]

ad_ip_instance xlconstant GND [list \
  CONST_VAL 0 \
]
ad_connect gnd GND/dout

for {set i 0} {$i < 2} {incr i} {
  ad_ip_instance axi_dmac i_rx_dmac_${i} [list \
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

  ad_ip_instance axi_dmac i_tx_dmac_${i} [list \
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
  
  ad_data_offload_create RX_DUT_${i} \
                         0 \
                         $adc_offload_mem_type \
                         $adc_offload_size \
                         $adc_offload_src_dwidth \
                         $adc_offload_dst_dwidth \
                         $plddr_offload_data_width
  
  ad_data_offload_create TX_DUT_${i} \
                         1 \
                         $dac_offload_mem_type \
                         $dac_offload_size \
                         $dac_offload_src_dwidth \
                         $dac_offload_dst_dwidth \
                         $plddr_offload_data_width
  
  set BA 0x50000000
  ad_cpu_interconnect [expr ${BA} + 0x00000 + $i*0x40000] i_rx_dmac_${i}
  ad_cpu_interconnect [expr ${BA} + 0x10000 + $i*0x40000] i_tx_dmac_${i}
  ad_cpu_interconnect [expr ${BA} + 0x20000 + $i*0x40000] RX_DUT_${i}
  ad_cpu_interconnect [expr ${BA} + 0x30000 + $i*0x40000] TX_DUT_${i}
  
  adi_sim_add_define "RX_DMA_BA_${i}=[format "%d" [expr ${BA} + 0x00000 + $i*0x40000]]"
  adi_sim_add_define "TX_DMA_BA_${i}=[format "%d" [expr ${BA} + 0x10000 + $i*0x40000]]"
  adi_sim_add_define "RX_DOFF_BA_${i}=[format "%d" [expr ${BA} + 0x20000 + $i*0x40000]]"
  adi_sim_add_define "TX_DOFF_BA_${i}=[format "%d" [expr ${BA} + 0x30000 + $i*0x40000]]"
  
  ad_ip_instance axi4stream_vip adc_src_axis_${i} [list \
    INTERFACE_MODE {MASTER} \
    HAS_TREADY {1} \
    HAS_TLAST {0} \
    TDATA_NUM_BYTES $adc_data_path_width \
  ]
  adi_sim_add_define "ADC_SRC_AXIS_${i}=adc_src_axis_${i}"
  
  ad_connect adc_src_axis_${i}/m_axis RX_DUT_${i}/s_axis
  ad_connect RX_DUT_${i}/m_axis i_rx_dmac_${i}/s_axis
  
  ad_connect dma_clk_vip/clk_out adc_src_axis_${i}/aclk
  ad_connect sys_dma_resetn adc_src_axis_${i}/aresetn
  
  ad_connect dma_clk_vip/clk_out RX_DUT_${i}/s_axis_aclk
  ad_connect sys_dma_resetn RX_DUT_${i}/s_axis_aresetn
  ad_connect sys_clk_vip/clk_out RX_DUT_${i}/m_axis_aclk
  ad_connect sys_cpu_resetn RX_DUT_${i}/m_axis_aresetn
  
  ad_connect sys_clk_vip/clk_out i_rx_dmac_${i}/s_axis_aclk
  ad_connect sys_mem_clk i_rx_dmac_${i}/m_dest_axi_aclk
  ad_connect sys_mem_resetn i_rx_dmac_${i}/m_dest_axi_aresetn
  
  ad_connect i_rx_dmac_${i}/s_axis_xfer_req RX_DUT_${i}/init_req
  ad_connect gnd RX_DUT_${i}/sync_ext

  ad_ip_instance axi_vip adc_dst_axi_pt_${i} $ddr_axi_pt_cfg
  adi_sim_add_define "ADC_DST_AXI_PT_${i}=adc_dst_axi_pt_${i}"

  ad_connect i_rx_dmac_${i}/m_dest_axi adc_dst_axi_pt_${i}/S_AXI
  
  ad_mem_hp0_interconnect sys_mem_clk adc_dst_axi_pt_${i}/M_AXI
  ad_connect sys_mem_resetn adc_dst_axi_pt_${i}/aresetn
  
  ad_ip_instance axi4stream_vip dac_dst_axis_${i} [list \
    INTERFACE_MODE {SLAVE} \
    TDATA_NUM_BYTES $dac_data_path_width \
    HAS_TLAST {1} \
  ]
  adi_sim_add_define "DAC_DST_AXIS_${i}=dac_dst_axis_${i}"
  
  ad_connect dma_clk_vip/clk_out dac_dst_axis_${i}/aclk
  ad_connect sys_dma_resetn dac_dst_axis_${i}/aresetn
  
  ad_connect dma_clk_vip/clk_out TX_DUT_${i}/m_axis_aclk
  ad_connect sys_dma_resetn TX_DUT_${i}/m_axis_aresetn
  ad_connect sys_clk_vip/clk_out TX_DUT_${i}/s_axis_aclk
  ad_connect sys_cpu_resetn TX_DUT_${i}/s_axis_aresetn
  
  ad_connect sys_clk_vip/clk_out i_tx_dmac_${i}/m_axis_aclk
  ad_connect sys_mem_clk i_tx_dmac_${i}/m_src_axi_aclk
  ad_connect sys_mem_resetn i_tx_dmac_${i}/m_src_axi_aresetn
  
  ad_connect TX_DUT_${i}/m_axis dac_dst_axis_${i}/s_axis
  ad_connect TX_DUT_${i}/s_axis i_tx_dmac_${i}/m_axis
  
  ad_connect i_tx_dmac_${i}/m_axis_xfer_req TX_DUT_${i}/init_req
  ad_connect gnd TX_DUT_${i}/sync_ext

  ad_ip_instance axi_vip dac_src_axi_pt_${i} $ddr_axi_pt_cfg
  adi_sim_add_define "DAC_SRC_AXI_PT_${i}=dac_src_axi_pt_${i}"

  ad_connect i_tx_dmac_${i}/m_src_axi dac_src_axi_pt_${i}/S_AXI
  
  ad_mem_hp0_interconnect sys_mem_clk dac_src_axi_pt_${i}/M_AXI
  ad_connect sys_mem_resetn dac_src_axi_pt_${i}/aresetn
}
