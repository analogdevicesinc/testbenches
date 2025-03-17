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
#      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
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

set TX_LANE_RATE $ad_project_params(TX_LANE_RATE)
set TX_NUM_OF_LANES $ad_project_params(TX_JESD_L)
set TX_NUM_OF_CONVERTERS $ad_project_params(TX_JESD_M)
set TX_SAMPLES_PER_FRAME $ad_project_params(TX_JESD_S)
set TX_SAMPLE_WIDTH $ad_project_params(TX_JESD_NP)

set RX_LANE_RATE $ad_project_params(RX_LANE_RATE)
set RX_NUM_OF_LANES $ad_project_params(RX_JESD_L)
set RX_NUM_OF_CONVERTERS $ad_project_params(RX_JESD_M)
set RX_SAMPLES_PER_FRAME $ad_project_params(RX_JESD_S)
set RX_SAMPLE_WIDTH $ad_project_params(RX_JESD_NP)

# Ref clk
ad_ip_instance clk_vip ref_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "REF_CLK=ref_clk_vip"
create_bd_port -dir O ref_clk_out
ad_connect ref_clk_out ref_clk_vip/clk_out

# Rx Device clk
ad_ip_instance clk_vip rx_device_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "RX_DEVICE_CLK=rx_device_clk_vip"
create_bd_port -dir O rx_device_clk_out
ad_connect rx_device_clk_out rx_device_clk_vip/clk_out

# Tx Device clk
ad_ip_instance clk_vip tx_device_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "TX_DEVICE_CLK=tx_device_clk_vip"
create_bd_port -dir O tx_device_clk_out
ad_connect tx_device_clk_out tx_device_clk_vip/clk_out

#
#  Block design under test
#

create_bd_port -dir I -type clk ex_ref_clk
create_bd_port -dir I -type clk ex_rx_device_clk
create_bd_port -dir I -type clk ex_tx_device_clk
create_bd_port -dir I -type clk ex_sysref

create_bd_port -dir O ex_rx_sync
create_bd_port -dir I ex_tx_sync

for {set i 0} {$i < $TX_NUM_OF_LANES} {incr i} {
  create_bd_port -dir I ex_rx_data_${i}_n
  create_bd_port -dir I ex_rx_data_${i}_p
}

for {set i 0} {$i < $RX_NUM_OF_LANES} {incr i} {
  create_bd_port -dir O ex_tx_data_${i}_n
  create_bd_port -dir O ex_tx_data_${i}_p
}

create_bd_port -dir I -from 255 -to 0 dac_data_0

source $ad_hdl_dir/projects/fmcomms11/common/fmcomms11_bd.tcl

source $ad_tb_dir/library/drivers/jesd/jesd_exerciser.tcl

create_jesd_exerciser rx_jesd_exerciser 0 1 $TX_LANE_RATE $TX_NUM_OF_CONVERTERS $TX_NUM_OF_LANES $TX_SAMPLES_PER_FRAME $TX_SAMPLE_WIDTH
create_bd_cell -type container -reference rx_jesd_exerciser i_rx_jesd_exerciser

create_jesd_exerciser tx_jesd_exerciser 1 1 $RX_LANE_RATE $RX_NUM_OF_CONVERTERS $RX_NUM_OF_LANES $RX_SAMPLES_PER_FRAME $RX_SAMPLE_WIDTH
create_bd_cell -type container -reference tx_jesd_exerciser i_tx_jesd_exerciser

# Rx exerciser
for {set i 0} {$i < $TX_NUM_OF_LANES} {incr i} {
  ad_connect ex_rx_data_${i}_n i_rx_jesd_exerciser/rx_data_${i}_n
  ad_connect ex_rx_data_${i}_p i_rx_jesd_exerciser/rx_data_${i}_p
}

ad_connect $sys_cpu_clk i_rx_jesd_exerciser/sys_cpu_clk
ad_connect $sys_cpu_resetn i_rx_jesd_exerciser/sys_cpu_resetn

ad_connect ex_rx_device_clk i_rx_jesd_exerciser/device_clk
ad_connect ex_rx_device_clk i_rx_jesd_exerciser/link_clk
ad_connect ex_ref_clk i_rx_jesd_exerciser/ref_clk
ad_connect ex_sysref i_rx_jesd_exerciser/rx_sysref_0
ad_connect ex_rx_sync i_rx_jesd_exerciser/rx_sync_0

set_property -dict [list CONFIG.NUM_MI {13}] [get_bd_cells axi_axi_interconnect]
ad_connect i_rx_jesd_exerciser/S00_AXI_0 axi_axi_interconnect/M12_AXI
ad_connect $sys_cpu_clk axi_axi_interconnect/M12_ACLK
ad_connect $sys_cpu_resetn axi_axi_interconnect/M12_ARESETN

# Tx exerciser
for {set i 0} {$i < $RX_NUM_OF_LANES} {incr i} {
  ad_connect ex_tx_data_${i}_n i_tx_jesd_exerciser/tx_data_${i}_n
  ad_connect ex_tx_data_${i}_p i_tx_jesd_exerciser/tx_data_${i}_p
}

ad_connect $sys_cpu_clk i_tx_jesd_exerciser/sys_cpu_clk
ad_connect $sys_cpu_resetn i_tx_jesd_exerciser/sys_cpu_resetn

ad_connect ex_tx_device_clk i_tx_jesd_exerciser/device_clk
ad_connect ex_tx_device_clk i_tx_jesd_exerciser/link_clk
ad_connect ex_ref_clk i_tx_jesd_exerciser/ref_clk
ad_connect ex_sysref i_tx_jesd_exerciser/tx_sysref_0
ad_connect ex_tx_sync i_tx_jesd_exerciser/tx_sync_0
ad_connect dac_data_0 i_tx_jesd_exerciser/dac_data_0_0

set_property -dict [list CONFIG.NUM_MI {14}] [get_bd_cells axi_axi_interconnect]
ad_connect i_tx_jesd_exerciser/S00_AXI_0 axi_axi_interconnect/M13_AXI
ad_connect $sys_cpu_clk axi_axi_interconnect/M13_ACLK
ad_connect $sys_cpu_resetn axi_axi_interconnect/M13_ARESETN

assign_bd_address

set DUT_TX_XCVR 0x44A60000
set_property offset $DUT_TX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9162_xcvr}]
adi_sim_add_define "DUT_TX_XCVR_BA=[format "%d" ${DUT_TX_XCVR}]"

set DUT_DAC_TPL 0x44A00000
set_property offset $DUT_DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9162_core}]
adi_sim_add_define "DUT_DAC_TPL_BA=[format "%d" ${DUT_DAC_TPL}]"

set DUT_TX_AXI_JESD 0x44A90000
set_property offset $DUT_TX_AXI_JESD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9162_jesd}]
adi_sim_add_define "DUT_TX_AXI_JESD_BA=[format "%d" ${DUT_TX_AXI_JESD}]"

set TX_DMA 0x7C420000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9162_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"

set TX_OFFLOAD 0x7C430000
set_property offset $TX_OFFLOAD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad9162_data_offload}]
adi_sim_add_define "TX_OFFLOAD_BA=[format "%d" ${TX_OFFLOAD}]"

set EX_RX_XCVR 0x54A60000
set_property offset $EX_RX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_axi_xcvr_axi_lite}]
adi_sim_add_define "EX_RX_XCVR_BA=[format "%d" ${EX_RX_XCVR}]"

set EX_ADC_TPL 0x54A00000
set_property offset $EX_ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_adc_tpl_core_axi_lite}]
adi_sim_add_define "EX_ADC_TPL_BA=[format "%d" ${EX_ADC_TPL}]"

set EX_RX_AXI_JESD 0x54A90000
set_property offset $EX_RX_AXI_JESD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_rx_axi_axi_lite}]
adi_sim_add_define "EX_RX_AXI_JESD_BA=[format "%d" ${EX_RX_AXI_JESD}]"


set DUT_RX_XCVR 0x44A50000
set_property offset $DUT_RX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9625_xcvr}]
adi_sim_add_define "DUT_RX_XCVR_BA=[format "%d" ${DUT_RX_XCVR}]"

set DUT_ADC_TPL 0x44A10000
set_property offset $DUT_ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9625_core}]
adi_sim_add_define "DUT_ADC_TPL_BA=[format "%d" ${DUT_ADC_TPL}]"

set DUT_RX_AXI_JESD 0x44AA0000
set_property offset $DUT_RX_AXI_JESD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9625_jesd}]
adi_sim_add_define "DUT_RX_AXI_JESD_BA=[format "%d" ${DUT_RX_AXI_JESD}]"

set RX_DMA 0x7C400000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9625_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set RX_OFFLOAD 0x7C410000
set_property offset $RX_OFFLOAD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad9625_data_offload}]
adi_sim_add_define "RX_OFFLOAD_BA=[format "%d" ${RX_OFFLOAD}]"

set EX_TX_XCVR 0x54A50000
set_property offset $EX_TX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_axi_xcvr_axi_lite_1}]
adi_sim_add_define "EX_TX_XCVR_BA=[format "%d" ${EX_TX_XCVR}]"

set EX_DAC_TPL 0x54A10000
set_property offset $EX_DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_dac_tpl_core_axi_lite}]
adi_sim_add_define "EX_DAC_TPL_BA=[format "%d" ${EX_DAC_TPL}]"

set EX_TX_AXI_JESD 0x54AA0000
set_property offset $EX_TX_AXI_JESD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_tx_axi_axi_lite}]
adi_sim_add_define "EX_TX_AXI_JESD_BA=[format "%d" ${EX_TX_AXI_JESD}]"
