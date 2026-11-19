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
set plddr_offload_axi_data_width $ad_project_params(PLDDR_OFFLOAD_DATA_WIDTH)
set rd_data_registered $ad_project_params(RD_DATA_REGISTERED)
set rd_fifo_address_width $ad_project_params(RD_FIFO_ADDRESS_WIDTH)

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

source $ad_hdl_dir/projects/daq3/common/daq3_bd.tcl

ad_ip_parameter $dac_offload_name/storage_unit CONFIG.RD_DATA_REGISTERED $rd_data_registered
ad_ip_parameter $dac_offload_name/storage_unit CONFIG.RD_FIFO_ADDRESS_WIDTH $rd_fifo_address_width

# Import configuration from daq3/zcu102
ad_ip_parameter util_daq3_xcvr CONFIG.CPLL_CFG0 0x03fe
ad_ip_parameter util_daq3_xcvr CONFIG.CPLL_CFG1 0x0021
ad_ip_parameter util_daq3_xcvr CONFIG.CPLL_CFG2 0x0203

ad_ip_parameter util_daq3_xcvr CONFIG.QPLL_FBDIV 20
ad_ip_parameter util_daq3_xcvr CONFIG.QPLL_REFCLK_DIV 1

ad_ip_parameter axi_ad9152_dma CONFIG.FIFO_SIZE 32
ad_ip_parameter axi_ad9152_dma CONFIG.AXI_SLICE_SRC 1
ad_ip_parameter axi_ad9152_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter axi_ad9152_dma CONFIG.CYCLIC 1
ad_ip_parameter axi_ad9152_dma CONFIG.MAX_BYTES_PER_BURST 256

ad_ip_parameter axi_ad9680_dma CONFIG.DMA_TYPE_SRC 2
ad_ip_parameter axi_ad9680_dma CONFIG.FIFO_SIZE 32
ad_ip_parameter axi_ad9680_dma CONFIG.DMA_DATA_WIDTH_DEST 128
ad_ip_parameter axi_ad9680_dma CONFIG.DMA_DATA_WIDTH_SRC 128
ad_ip_parameter axi_ad9680_dma CONFIG.AXI_SLICE_SRC 1
ad_ip_parameter axi_ad9680_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter axi_ad9680_dma CONFIG.MAX_BYTES_PER_BURST 256

ad_connect sys_dma_clk $dac_offload_name/s_axis_aclk
ad_connect sys_dma_resetn $dac_offload_name/s_axis_aresetn
ad_connect sys_dma_clk axi_ad9152_dma/m_axis_aclk
ad_connect sys_dma_resetn axi_ad9152_dma/m_src_axi_aresetn

ad_connect sys_dma_resetn axi_ad9680_dma/m_dest_axi_aresetn
ad_connect axi_ad9680_dma/fifo_wr_clk util_daq3_xcvr/rx_out_clk_0
ad_connect axi_ad9680_cpack/packed_fifo_wr axi_ad9680_dma/fifo_wr
ad_connect axi_ad9680_cpack/fifo_wr_overflow axi_ad9680_tpl_core/adc_dovf

ad_mem_hp0_interconnect sys_cpu_clk sys_ps7/S_AXI_HP0
ad_mem_hp0_interconnect sys_cpu_clk axi_ad9680_xcvr/m_axi
ad_mem_hp1_interconnect sys_dma_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect sys_dma_clk axi_ad9680_dma/m_dest_axi
ad_mem_hp3_interconnect sys_dma_clk sys_ps7/S_AXI_HP3
ad_mem_hp3_interconnect sys_dma_clk axi_ad9152_dma/m_src_axi

set RX_DMA 0x7C400000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9680_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set RX_XCVR 0x44A50000
set_property offset $RX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9680_xcvr}]
adi_sim_add_define "RX_XCVR_BA=[format "%d" ${RX_XCVR}]"

set TX_DMA 0x7C420000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9152_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"

set TX_XCVR 0x44A60000
set_property offset $TX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9152_xcvr}]
adi_sim_add_define "TX_XCVR_BA=[format "%d" ${TX_XCVR}]"

set AXI_JESD_RX 0x44AA0000
set_property offset $AXI_JESD_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9680_jesd}]
adi_sim_add_define "AXI_JESD_RX_BA=[format "%d" ${AXI_JESD_RX}]"

set ADC_TPL 0x44A10000
set_property offset $ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9680_tpl_core}]
adi_sim_add_define "ADC_TPL_BA=[format "%d" ${ADC_TPL}]"

set DAC_TPL 0x44A04000
set_property offset $DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9152_tpl_core}]
adi_sim_add_define "DAC_TPL_BA=[format "%d" ${DAC_TPL}]"

set AXI_JESD_TX 0x44A90000
set_property offset $AXI_JESD_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9152_jesd}]
adi_sim_add_define "AXI_JESD_TX_BA=[format "%d" ${AXI_JESD_TX}]"

set TX_OFFLOAD 0x7C430000
set_property offset $TX_OFFLOAD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad9152_data_offload}]
adi_sim_add_define "TX_OFFLOAD_BA=[format "%d" ${TX_OFFLOAD}]"
