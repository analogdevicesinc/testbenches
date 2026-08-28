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

source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl

set DATAPATH_WIDTH 4
set TX_MAX_LANES 8

set dac_offload_type $ad_project_params(DAC_OFFLOAD_TYPE)
set dac_offload_size $ad_project_params(DAC_OFFLOAD_SIZE)

set LANE_RATE $ad_project_params(LANE_RATE)

set TX_NUM_OF_LANES $ad_project_params(JESD_L)
set TX_NUM_OF_CONVERTERS $ad_project_params(JESD_M)
set TX_SAMPLES_PER_FRAME $ad_project_params(JESD_S)
set TX_SAMPLE_WIDTH $ad_project_params(JESD_NP)
set TX_JESD_F $ad_project_params(JESD_F)

set LL_OUT_BYTES [expr max($TX_JESD_F,$DATAPATH_WIDTH)]

adi_sim_add_define LL_OUT_BYTES=$LL_OUT_BYTES

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

create_bd_port -dir I -type clk ref_clk_ex
create_bd_port -dir I -type clk rx_device_clk
create_bd_port -dir I -type clk sysref

set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports rx_device_clk]

for {set i 0} {$i < $TX_MAX_LANES} {incr i} {
create_bd_port -dir I rx_data1_${i}_n
create_bd_port -dir I rx_data1_${i}_p
}

source $ad_hdl_dir/projects/dac_fmc_ebz/common/dac_fmc_ebz_bd.tcl

source $ad_tb_dir/library/drivers/jesd/jesd_exerciser.tcl

create_jesd_exerciser rx_jesd_exerciser 0 1 $LANE_RATE $TX_NUM_OF_CONVERTERS $TX_NUM_OF_LANES $TX_SAMPLES_PER_FRAME $TX_SAMPLE_WIDTH
create_bd_cell -type container -reference rx_jesd_exerciser i_rx_jesd_exerciser

# Rx exerciser
for {set i 0} {$i < $TX_NUM_OF_LANES} {incr i} {
  ad_connect rx_data1_${i}_n i_rx_jesd_exerciser/rx_data_${i}_n
  ad_connect rx_data1_${i}_p i_rx_jesd_exerciser/rx_data_${i}_p
}
ad_connect sysref i_rx_jesd_exerciser/rx_sysref_0

ad_connect $sys_cpu_clk i_rx_jesd_exerciser/sys_cpu_clk
ad_connect $sys_cpu_resetn i_rx_jesd_exerciser/sys_cpu_resetn

ad_connect rx_device_clk i_rx_jesd_exerciser/device_clk
ad_connect rx_device_clk i_rx_jesd_exerciser/link_clk
ad_connect ref_clk_ex i_rx_jesd_exerciser/ref_clk

set_property -dict [list CONFIG.NUM_MI {8}] [get_bd_cells axi_axi_interconnect]
ad_connect i_rx_jesd_exerciser/S00_AXI_0 axi_axi_interconnect/M07_AXI
ad_connect sys_cpu_clk axi_axi_interconnect/M07_ACLK
ad_connect sys_cpu_resetn axi_axi_interconnect/M07_ARESETN

create_bd_port -dir O ex_rx_sync
ad_connect ex_rx_sync i_rx_jesd_exerciser/rx_sync_0

assign_bd_address

set DUT_AXI_XCVR_TX 0x44A60000
set_property offset $DUT_AXI_XCVR_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dac_jesd204_xcvr}]
adi_sim_add_define "DUT_AXI_XCVR_TX_BA=[format "%d" ${DUT_AXI_XCVR_TX}]"

set DAC_TPL 0x44A04000
set_property offset $DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dac_jesd204_transport}]
adi_sim_add_define "DAC_TPL_BA=[format "%d" ${DAC_TPL}]"

set AXI_JESD_TX 0x44A90000
set_property offset $AXI_JESD_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dac_jesd204_link}]
adi_sim_add_define "AXI_JESD_TX_BA=[format "%d" ${AXI_JESD_TX}]"


set TX_DMA 0x7C420000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dac_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"

set TX_OFFLOAD 0x7C430000
set_property offset $TX_OFFLOAD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dac_data_offload}]
adi_sim_add_define "TX_OFFLOAD_BA=[format "%d" ${TX_OFFLOAD}]"


set EX_AXI_XCVR_RX 0x44A20000
set_property offset $EX_AXI_XCVR_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_axi_xcvr_axi_lite}]
adi_sim_add_define "EX_AXI_XCVR_RX_BA=[format "%d" ${EX_AXI_XCVR_RX}]"

set EX_ADC_TPL 0x44A30000
set_property offset $EX_ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_adc_tpl_core_axi_lite}]
adi_sim_add_define "EX_ADC_TPL_BA=[format "%d" ${EX_ADC_TPL}]"

set EX_AXI_JESD_RX 0x44A10000
set_property offset $EX_AXI_JESD_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_rx_axi_axi_lite}]
adi_sim_add_define "EX_AXI_JESD_RX_BA=[format "%d" ${EX_AXI_JESD_RX}]"
