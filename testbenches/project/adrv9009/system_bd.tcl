# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2018-2024 Analog Devices, Inc. All rights reserved.
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

source $ad_hdl_dir/projects/common/xilinx/adcfifo_bd.tcl
source $ad_hdl_dir/projects/common/xilinx/dacfifo_bd.tcl

set LINK_MODE  $ad_project_params(LINK_MODE)

set JESD_8B10B 1
set JESD_64B66B 2

if {$LINK_MODE == $JESD_8B10B} {
  set DATAPATH_WIDTH 4
  set NP12_DATAPATH_WIDTH 6
} else {
  set DATAPATH_WIDTH 8
  set NP12_DATAPATH_WIDTH 12
}

set dac_fifo_address_width $ad_project_params(DAC_FIFO_ADDRESS_WIDTH)
set ENCODER_SEL 1
set LANE_RATE $ad_project_params(LANE_RATE)
set MAX_NUM_OF_CONVERTERS 4

set TX_NUM_OF_LANES $ad_project_params(TX_JESD_L)
set TX_NUM_OF_CONVERTERS $ad_project_params(TX_JESD_M)
set TX_SAMPLES_PER_FRAME $ad_project_params(TX_JESD_S)
set TX_SAMPLE_WIDTH $ad_project_params(TX_JESD_NP)
set TX_JESD_F $ad_project_params(TX_JESD_F)

set RX_NUM_OF_LANES $ad_project_params(RX_JESD_L)
set RX_NUM_OF_CONVERTERS $ad_project_params(RX_JESD_M)
set RX_SAMPLES_PER_FRAME $ad_project_params(RX_JESD_S)
set RX_SAMPLE_WIDTH $ad_project_params(RX_JESD_NP)
set RX_JESD_F $ad_project_params(RX_JESD_F)

set RX_OS_NUM_OF_LANES $ad_project_params(RX_OS_JESD_L)
set RX_OS_NUM_OF_CONVERTERS $ad_project_params(RX_OS_JESD_M)
set RX_OS_SAMPLES_PER_FRAME $ad_project_params(RX_OS_JESD_S)
set RX_OS_SAMPLE_WIDTH $ad_project_params(RX_OS_JESD_NP)
set RX_OS_JESD_F $ad_project_params(RX_OS_JESD_F)

# For F=3,6,12 use dual clock
if {$RX_JESD_F % 3 == 0} {
  set LL_OUT_BYTES [expr max($RX_JESD_F,$NP12_DATAPATH_WIDTH)]
} else {
  set LL_OUT_BYTES [expr max($RX_JESD_F,$DATAPATH_WIDTH)]
}

# For F=3,6,12 use dual clock
if {$RX_OS_JESD_F % 3 == 0} {
  set LL_OUT_BYTES1 [expr max($RX_OS_JESD_F,$NP12_DATAPATH_WIDTH)]
} else {
  set LL_OUT_BYTES1 [expr max($RX_OS_JESD_F,$DATAPATH_WIDTH)]
}

adi_sim_add_define LL_OUT_BYTES=$LL_OUT_BYTES
adi_sim_add_define LL_OUT_BYTES1=$LL_OUT_BYTES1

set RX_DMA_SAMPLE_WIDTH $ad_project_params(RX_JESD_NP)
if {$RX_DMA_SAMPLE_WIDTH == 12} {
  set RX_DMA_SAMPLE_WIDTH 16
}

set RX_OS_DMA_SAMPLE_WIDTH $ad_project_params(RX_OS_JESD_NP)
if {$RX_OS_DMA_SAMPLE_WIDTH == 12} {
  set RX_OS_DMA_SAMPLE_WIDTH 16
}

set TX_EX_DAC_DATA_WIDTH [expr $RX_NUM_OF_LANES * $LL_OUT_BYTES * 8]
set TX_EX_SAMPLES_PER_CHANNEL [expr $TX_EX_DAC_DATA_WIDTH / $RX_NUM_OF_CONVERTERS / $RX_SAMPLE_WIDTH]

set TX_OS_EX_DAC_DATA_WIDTH [expr $RX_OS_NUM_OF_LANES * $LL_OUT_BYTES1 * 8]
set TX_OS_EX_SAMPLES_PER_CHANNEL [expr $TX_OS_EX_DAC_DATA_WIDTH / $RX_OS_NUM_OF_CONVERTERS / $RX_OS_SAMPLE_WIDTH]

set TX_MAX_LANES 4
set RX_MAX_LANES 2

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

# Tx Link clk
ad_ip_instance clk_vip tx_link_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "TX_LINK_CLK=tx_link_clk_vip"
create_bd_port -dir O tx_link_clk_out
ad_connect tx_link_clk_out tx_link_clk_vip/clk_out

# Tx Observation Device clk
ad_ip_instance clk_vip tx_os_device_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "TX_OS_DEVICE_CLK=tx_os_device_clk_vip"
create_bd_port -dir O tx_os_device_clk_out
ad_connect tx_os_device_clk_out tx_os_device_clk_vip/clk_out

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
create_bd_port -dir I -type clk tx_device_clk
create_bd_port -dir I -type clk tx_link_clk
create_bd_port -dir I -type clk tx_os_device_clk
create_bd_port -dir I -type clk sysref

set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports rx_device_clk]
set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports tx_device_clk]
set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports tx_link_clk]
set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports tx_os_device_clk]

for {set i 0} {$i < $TX_MAX_LANES} {incr i} {
create_bd_port -dir I rx_data1_${i}_n
create_bd_port -dir I rx_data1_${i}_p
}

for {set i 0} {$i < $RX_MAX_LANES} {incr i} {
create_bd_port -dir O tx_data1_${i}_n
create_bd_port -dir O tx_data1_${i}_p
create_bd_port -dir O tx_os_data1_${i}_n
create_bd_port -dir O tx_os_data1_${i}_p
}

# Rx reset generator
ad_ip_instance proc_sys_reset rx_device_clk_rstgen
ad_connect  rx_device_clk rx_device_clk_rstgen/slowest_sync_clk
ad_connect  $sys_cpu_resetn rx_device_clk_rstgen/ext_reset_in

# Tx reset generator
ad_ip_instance proc_sys_reset tx_device_clk_rstgen
ad_connect  tx_device_clk tx_device_clk_rstgen/slowest_sync_clk
ad_connect  $sys_cpu_resetn tx_device_clk_rstgen/ext_reset_in

# Tx Observation reset generator
ad_ip_instance proc_sys_reset tx_os_device_clk_rstgen
ad_connect  tx_os_device_clk tx_os_device_clk_rstgen/slowest_sync_clk
ad_connect  $sys_cpu_resetn tx_os_device_clk_rstgen/ext_reset_in

source $ad_hdl_dir/projects/adrv9009/common/adrv9009_bd.tcl

source $ad_hdl_dir/testbenches/library/drivers/jesd/jesd_exerciser.tcl

create_jesd_exerciser rx_jesd_exerciser 0 $ENCODER_SEL $LANE_RATE $TX_NUM_OF_CONVERTERS $TX_NUM_OF_LANES $TX_SAMPLES_PER_FRAME $TX_SAMPLE_WIDTH
create_bd_cell -type container -reference rx_jesd_exerciser i_rx_jesd_exerciser

create_jesd_exerciser tx_jesd_exerciser 1 $ENCODER_SEL $LANE_RATE $RX_NUM_OF_CONVERTERS $RX_NUM_OF_LANES $RX_SAMPLES_PER_FRAME $RX_SAMPLE_WIDTH
create_bd_cell -type container -reference tx_jesd_exerciser i_tx_jesd_exerciser

create_jesd_exerciser tx_os_jesd_exerciser 1 $ENCODER_SEL $LANE_RATE $RX_OS_NUM_OF_CONVERTERS $RX_OS_NUM_OF_LANES $RX_OS_SAMPLES_PER_FRAME $RX_OS_SAMPLE_WIDTH
create_bd_cell -type container -reference tx_os_jesd_exerciser i_tx_os_jesd_exerciser

# Rx exerciser
for {set i 0} {$i < $TX_NUM_OF_LANES} {incr i} {
  set j [expr {$TX_NUM_OF_LANES == 2} ? $i*2 : $i]
  ad_connect rx_data1_${j}_n i_rx_jesd_exerciser/rx_data_${i}_n
  ad_connect rx_data1_${j}_p i_rx_jesd_exerciser/rx_data_${i}_p
}
ad_connect sysref i_rx_jesd_exerciser/rx_sysref_0

ad_connect $sys_cpu_clk i_rx_jesd_exerciser/sys_cpu_clk
ad_connect $sys_cpu_resetn i_rx_jesd_exerciser/sys_cpu_resetn

ad_connect rx_device_clk i_rx_jesd_exerciser/device_clk
ad_connect rx_device_clk i_rx_jesd_exerciser/link_clk
ad_connect ref_clk_ex i_rx_jesd_exerciser/ref_clk

set_property -dict [list CONFIG.NUM_MI {18}] [get_bd_cells axi_axi_interconnect]
ad_connect i_rx_jesd_exerciser/S00_AXI_0 axi_axi_interconnect/M17_AXI
ad_connect sys_cpu_clk axi_axi_interconnect/M17_ACLK
ad_connect sys_cpu_resetn axi_axi_interconnect/M17_ARESETN

create_bd_port -dir O ex_rx_sync
ad_connect ex_rx_sync i_rx_jesd_exerciser/rx_sync_0

# Tx exerciser
for {set i 0} {$i < $RX_NUM_OF_LANES} {incr i} {
  ad_connect tx_data1_${i}_n i_tx_jesd_exerciser/tx_data_${i}_n
  ad_connect tx_data1_${i}_p i_tx_jesd_exerciser/tx_data_${i}_p
}
ad_connect sysref i_tx_jesd_exerciser/tx_sysref_0

ad_connect $sys_cpu_clk i_tx_jesd_exerciser/sys_cpu_clk
ad_connect $sys_cpu_resetn i_tx_jesd_exerciser/sys_cpu_resetn

ad_connect tx_device_clk i_tx_jesd_exerciser/device_clk
ad_connect tx_link_clk i_tx_jesd_exerciser/link_clk
ad_connect ref_clk_ex i_tx_jesd_exerciser/ref_clk

set_property -dict [list CONFIG.NUM_MI {19}] [get_bd_cells axi_axi_interconnect]
ad_connect i_tx_jesd_exerciser/S00_AXI_0 axi_axi_interconnect/M18_AXI
ad_connect sys_cpu_clk axi_axi_interconnect/M18_ACLK
ad_connect sys_cpu_resetn axi_axi_interconnect/M18_ARESETN

create_bd_port -dir I ex_tx_sync
ad_connect ex_tx_sync i_tx_jesd_exerciser/tx_sync_0

for {set i 0} {$i < $MAX_NUM_OF_CONVERTERS} {incr i} {
  create_bd_port -dir I -from [expr $TX_EX_SAMPLES_PER_CHANNEL*$RX_DMA_SAMPLE_WIDTH-1] -to 0 dac_data_$i
  create_bd_port -dir I -from [expr $TX_OS_EX_SAMPLES_PER_CHANNEL*$RX_OS_DMA_SAMPLE_WIDTH-1] -to 0 dac_os_data_$i
}

for {set i 0} {$i < $RX_NUM_OF_CONVERTERS} {incr i} {
  ad_connect dac_data_$i i_tx_jesd_exerciser/dac_data_${i}_0
}

# Tx Observation exerciser
for {set i 0} {$i < $RX_OS_NUM_OF_LANES} {incr i} {
  ad_connect tx_os_data1_${i}_n i_tx_os_jesd_exerciser/tx_data_${i}_n
  ad_connect tx_os_data1_${i}_p i_tx_os_jesd_exerciser/tx_data_${i}_p
}
ad_connect sysref i_tx_os_jesd_exerciser/tx_sysref_0

ad_connect $sys_cpu_clk i_tx_os_jesd_exerciser/sys_cpu_clk
ad_connect $sys_cpu_resetn i_tx_os_jesd_exerciser/sys_cpu_resetn

ad_connect tx_os_device_clk i_tx_os_jesd_exerciser/device_clk
ad_connect tx_os_device_clk i_tx_os_jesd_exerciser/link_clk
ad_connect ref_clk_ex i_tx_os_jesd_exerciser/ref_clk

set_property -dict [list CONFIG.NUM_MI {20}] [get_bd_cells axi_axi_interconnect]
ad_connect i_tx_os_jesd_exerciser/S00_AXI_0 axi_axi_interconnect/M19_AXI
ad_connect sys_cpu_clk axi_axi_interconnect/M19_ACLK
ad_connect sys_cpu_resetn axi_axi_interconnect/M19_ARESETN

create_bd_port -dir I ex_tx_os_sync
ad_connect ex_tx_os_sync i_tx_os_jesd_exerciser/tx_sync_0

for {set i 0} {$i < $RX_OS_NUM_OF_CONVERTERS} {incr i} {
  ad_connect dac_os_data_$i i_tx_os_jesd_exerciser/dac_data_${i}_0
}

assign_bd_address

set AXI_JESD_RX_OS 0x44AB0000
set_property offset $AXI_JESD_RX_OS [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_rx_os_jesd}]
adi_sim_add_define "AXI_JESD_RX_OS_BA=[format "%d" ${AXI_JESD_RX_OS}]"

set AXI_JESD_RX 0x44AA0000
set_property offset $AXI_JESD_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_rx_jesd}]
adi_sim_add_define "AXI_JESD_RX_BA=[format "%d" ${AXI_JESD_RX}]"

set AXI_JESD_TX 0x44A90000
set_property offset $AXI_JESD_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_tx_jesd}]
adi_sim_add_define "AXI_JESD_TX_BA=[format "%d" ${AXI_JESD_TX}]"


set TX_DMA 0x7C420000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_tx_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"

set RX_DMA 0x7C400000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_rx_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set RX_OS_DMA 0x7C440000
set_property offset $RX_OS_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_rx_os_dma}]
adi_sim_add_define "RX_OS_DMA_BA=[format "%d" ${RX_OS_DMA}]"


set ADC_TPL 0x44A00000
set_property offset $ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_rx_adrv9009_tpl_core}]
adi_sim_add_define "ADC_TPL_BA=[format "%d" ${ADC_TPL}]"

set ADC_OS_TPL 0x44A08000
set_property offset $ADC_OS_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_rx_os_adrv9009_tpl_core}]
adi_sim_add_define "ADC_OS_TPL_BA=[format "%d" ${ADC_OS_TPL}]"

set DAC_TPL 0x44A04000
set_property offset $DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_tx_adrv9009_tpl_core}]
adi_sim_add_define "DAC_TPL_BA=[format "%d" ${DAC_TPL}]"


set EX_ADC_TPL 0x44A30000
set_property offset $EX_ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_adc_tpl_core_axi_lite}]
adi_sim_add_define "EX_ADC_TPL_BA=[format "%d" ${EX_ADC_TPL}]"

set EX_DAC_TPL 0x44AC0000
set_property offset $EX_DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_dac_tpl_core_axi_lite}]
adi_sim_add_define "EX_DAC_TPL_BA=[format "%d" ${EX_DAC_TPL}]"

set EX_DAC_OS_TPL 0x44AF0000
set_property offset $EX_DAC_OS_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_dac_tpl_core_axi_lite_1}]
adi_sim_add_define "EX_DAC_OS_TPL_BA=[format "%d" ${EX_DAC_OS_TPL}]"


set DUT_AXI_XCVR_RX_OS 0x44A50000
set_property offset $DUT_AXI_XCVR_RX_OS [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_rx_os_xcvr}]
adi_sim_add_define "DUT_AXI_XCVR_RX_OS_BA=[format "%d" ${DUT_AXI_XCVR_RX_OS}]"

set DUT_AXI_XCVR_RX 0x44A60000
set_property offset $DUT_AXI_XCVR_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_rx_xcvr}]
adi_sim_add_define "DUT_AXI_XCVR_RX_BA=[format "%d" ${DUT_AXI_XCVR_RX}]"

set DUT_AXI_XCVR_TX 0x44A80000
set_property offset $DUT_AXI_XCVR_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_tx_xcvr}]
adi_sim_add_define "DUT_AXI_XCVR_TX_BA=[format "%d" ${DUT_AXI_XCVR_TX}]"


set EX_AXI_XCVR_RX 0x44A20000
set_property offset $EX_AXI_XCVR_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_axi_xcvr_axi_lite}]
adi_sim_add_define "EX_AXI_XCVR_RX_BA=[format "%d" ${EX_AXI_XCVR_RX}]"

set EX_AXI_JESD_RX 0x44A10000
set_property offset $EX_AXI_JESD_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_rx_axi_axi_lite}]
adi_sim_add_define "EX_AXI_JESD_RX_BA=[format "%d" ${EX_AXI_JESD_RX}]"


set EX_AXI_XCVR_TX 0x44A70000
set_property offset $EX_AXI_XCVR_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_axi_xcvr_axi_lite_1}]
adi_sim_add_define "EX_AXI_XCVR_TX_BA=[format "%d" ${EX_AXI_XCVR_TX}]"

set EX_AXI_JESD_TX 0x44A40000
set_property offset $EX_AXI_JESD_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_tx_axi_axi_lite}]
adi_sim_add_define "EX_AXI_JESD_TX_BA=[format "%d" ${EX_AXI_JESD_TX}]"


set EX_AXI_XCVR_TX_OS 0x44AE0000
set_property offset $EX_AXI_XCVR_TX_OS [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_axi_xcvr_axi_lite_2}]
adi_sim_add_define "EX_AXI_XCVR_TX_OS_BA=[format "%d" ${EX_AXI_XCVR_TX_OS}]"

set EX_AXI_JESD_TX_OS 0x44AD0000
set_property offset $EX_AXI_JESD_TX_OS [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_tx_axi_axi_lite_1}]
adi_sim_add_define "EX_AXI_JESD_TX_OS_BA=[format "%d" ${EX_AXI_JESD_TX_OS}]"


set AXI_CLKGEN_TX 0x43C00000
set_property offset $AXI_CLKGEN_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_tx_clkgen}]
adi_sim_add_define "AXI_CLKGEN_TX_BA=[format "%d" ${AXI_CLKGEN_TX}]"

set AXI_CLKGEN_RX 0x43C10000
set_property offset $AXI_CLKGEN_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_rx_clkgen}]
adi_sim_add_define "AXI_CLKGEN_RX_BA=[format "%d" ${AXI_CLKGEN_RX}]"

set AXI_CLKGEN_RX_OS 0x43C20000
set_property offset $AXI_CLKGEN_RX_OS [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adrv9009_rx_os_clkgen}]
adi_sim_add_define "AXI_CLKGEN_RX_OS_BA=[format "%d" ${AXI_CLKGEN_RX_OS}]"
