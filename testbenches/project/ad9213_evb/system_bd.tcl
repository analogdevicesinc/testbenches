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

source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl

set DATAPATH_WIDTH 4

set adc_offload_type $ad_project_params(ADC_OFFLOAD_TYPE)
set adc_offload_size $ad_project_params(ADC_OFFLOAD_SIZE)

set LANE_RATE $ad_project_params(LANE_RATE)

set RX_NUM_OF_LANES $ad_project_params(RX_JESD_L)
set RX_NUM_OF_CONVERTERS $ad_project_params(RX_JESD_M)
set RX_SAMPLES_PER_FRAME $ad_project_params(RX_JESD_S)
set RX_SAMPLE_WIDTH $ad_project_params(RX_JESD_NP)
set RX_JESD_F $ad_project_params(RX_JESD_F)

set LL_OUT_BYTES [expr max($RX_JESD_F,$DATAPATH_WIDTH)]
set TX_EX_DAC_DATA_WIDTH [expr $RX_NUM_OF_LANES * $LL_OUT_BYTES * 8]
set TX_EX_SAMPLES_PER_CHANNEL [expr $TX_EX_DAC_DATA_WIDTH / $RX_NUM_OF_CONVERTERS / $RX_SAMPLE_WIDTH]

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
create_bd_port -dir I -type clk tx_device_clk
create_bd_port -dir I -type clk sysref

set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports tx_device_clk]

for {set i 0} {$i < $RX_NUM_OF_LANES} {incr i} {
  create_bd_port -dir O tx_data1_${i}_n
  create_bd_port -dir O tx_data1_${i}_p
}

source $ad_hdl_dir/projects/ad9213_evb/common/ad9213_evb_bd.tcl

source $ad_hdl_dir/testbenches/library/drivers/jesd/jesd_exerciser.tcl

create_jesd_exerciser tx_jesd_exerciser 1 1 $LANE_RATE $RX_NUM_OF_CONVERTERS $RX_NUM_OF_LANES $RX_SAMPLES_PER_FRAME $RX_SAMPLE_WIDTH
create_bd_cell -type container -reference tx_jesd_exerciser i_tx_jesd_exerciser

# Tx 0 exerciser
for {set i 0} {$i < $RX_NUM_OF_LANES} {incr i} {
  ad_connect tx_data1_${i}_n i_tx_jesd_exerciser/tx_data_${i}_n
  ad_connect tx_data1_${i}_p i_tx_jesd_exerciser/tx_data_${i}_p
}
ad_connect sysref i_tx_jesd_exerciser/tx_sysref_0

ad_connect $sys_cpu_clk i_tx_jesd_exerciser/sys_cpu_clk
ad_connect $sys_cpu_resetn i_tx_jesd_exerciser/sys_cpu_resetn

ad_connect tx_device_clk i_tx_jesd_exerciser/device_clk
ad_connect tx_device_clk i_tx_jesd_exerciser/link_clk
ad_connect ref_clk_ex i_tx_jesd_exerciser/ref_clk

set_property -dict [list CONFIG.NUM_MI {9}] [get_bd_cells axi_axi_interconnect]
ad_connect i_tx_jesd_exerciser/S00_AXI_0 axi_axi_interconnect/M08_AXI
ad_connect sys_cpu_clk axi_axi_interconnect/M08_ACLK
ad_connect sys_cpu_resetn axi_axi_interconnect/M08_ARESETN

create_bd_port -dir I ex_tx_sync
ad_connect ex_tx_sync i_tx_jesd_exerciser/tx_sync_0

for {set i 0} {$i < $RX_NUM_OF_CONVERTERS} {incr i} {
  create_bd_port -dir I -from [expr $TX_EX_SAMPLES_PER_CHANNEL*$RX_SAMPLE_WIDTH-1] -to 0 dac_data_$i
}

for {set i 0} {$i < $RX_NUM_OF_CONVERTERS} {incr i} {
  ad_connect dac_data_$i i_tx_jesd_exerciser/dac_data_${i}_0
}

assign_bd_address

set AXI_JESD_RX 0x44A90000
set_property offset $AXI_JESD_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9213_jesd}]
adi_sim_add_define "AXI_JESD_RX_BA=[format "%d" ${AXI_JESD_RX}]"

set ADC_TPL 0x44A10000
set_property offset $ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_rx_ad9213_tpl_core}]
adi_sim_add_define "ADC_TPL_BA=[format "%d" ${ADC_TPL}]"

set EX_DAC_TPL 0x44A30000
set_property offset $EX_DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_dac_tpl_core_axi_lite}]
adi_sim_add_define "EX_DAC_TPL_BA=[format "%d" ${EX_DAC_TPL}]"

set DUT_AXI_XCVR_RX 0x44A60000
set_property offset $DUT_AXI_XCVR_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9213_xcvr}]
adi_sim_add_define "DUT_AXI_XCVR_RX_BA=[format "%d" ${DUT_AXI_XCVR_RX}]"

set EX_AXI_XCVR_TX 0x44A20000
set_property offset $EX_AXI_XCVR_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_axi_xcvr_axi_lite}]
adi_sim_add_define "EX_AXI_XCVR_TX_BA=[format "%d" ${EX_AXI_XCVR_TX}]"

set EX_AXI_JESD_TX 0x44A00000
set_property offset $EX_AXI_JESD_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_tx_axi_axi_lite}]
adi_sim_add_define "EX_AXI_JESD_TX_BA=[format "%d" ${EX_AXI_JESD_TX}]"

set RX_DMA 0x7C420000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9213_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set RX_OFFLOAD 0x7C430000
set_property offset $RX_OFFLOAD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad9213_data_offload}]
adi_sim_add_define "RX_OFFLOAD_BA=[format "%d" ${RX_OFFLOAD}]"
