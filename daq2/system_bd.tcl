# ***************************************************************************
# ***************************************************************************
# Copyright 2018 (c) Analog Devices, Inc. All rights reserved.
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

source ../../library/scripts/adi_env.tcl
source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl
source $ad_hdl_dir/projects/common/xilinx/data_offload_bd.tcl

global ad_project_params

set RX_JESD_F $ad_project_params(RX_JESD_F)

set RX_NUM_OF_LANES $ad_project_params(RX_JESD_L)           ; # L
set RX_NUM_OF_CONVERTERS $ad_project_params(RX_JESD_M)      ; # M
set RX_SAMPLES_PER_FRAME $ad_project_params(RX_JESD_S)      ; # S
set RX_SAMPLE_WIDTH 16                                      ; # N/NP

set DATAPATH_WIDTH 4

set LL_OUT_BYTES [expr max($RX_JESD_F,$DATAPATH_WIDTH)]

#set RX_SAMPLES_PER_CHANNEL [expr $RX_NUM_OF_LANES * 32 / ($RX_NUM_OF_CONVERTERS * $RX_SAMPLE_WIDTH)]
set RX_SAMPLES_PER_CHANNEL [expr ($RX_NUM_OF_LANES*$LL_OUT_BYTES*8) / $RX_NUM_OF_CONVERTERS / $RX_SAMPLE_WIDTH]

set adc_data_width [expr $RX_SAMPLE_WIDTH * $RX_NUM_OF_CONVERTERS * $RX_SAMPLES_PER_CHANNEL]
set TX_NUM_OF_LANES $ad_project_params(TX_JESD_L)           ; # L
set TX_NUM_OF_CONVERTERS $ad_project_params(TX_JESD_M)      ; # M
set TX_SAMPLES_PER_FRAME $ad_project_params(TX_JESD_S)      ; # S
set TX_SAMPLE_WIDTH 16                                      ; # N/NP
set TX_SAMPLES_PER_CHANNEL [expr $TX_NUM_OF_LANES * 32 / ($TX_NUM_OF_CONVERTERS * $TX_SAMPLE_WIDTH)]

set dac_data_width [expr $TX_SAMPLE_WIDTH * $TX_NUM_OF_CONVERTERS * $TX_SAMPLES_PER_CHANNEL]

adi_sim_add_define LL_OUT_BYTES=$LL_OUT_BYTES

set TX_EX_DAC_DATA_WIDTH [expr $RX_NUM_OF_LANES * $LL_OUT_BYTES * 8]
set TX_EX_SAMPLES_PER_CHANNEL [expr $TX_EX_DAC_DATA_WIDTH / $RX_NUM_OF_CONVERTERS / $RX_SAMPLE_WIDTH]

set RX_DMA_SAMPLE_WIDTH 16

set MAX_TX_NUM_OF_LANES 4
set MAX_RX_NUM_OF_LANES 4

set ENCODER_SEL 1
set LANE_RATE $ad_project_params(LANE_RATE)

## Offload attributes
set adc_offload_type 1                              ; ## PL_DDR
set adc_offload_size [expr 1 * 1024 * 1024 * 1024]  ; ## 1 Gbyte

set dac_offload_type 0                              ; ## BRAM
set dac_offload_size [expr 1 * 1024 * 1024]         ; ## 1 MByte

set plddr_offload_axi_data_width 512
set plddr_offload_axi_addr_width 30

# Ref clk
ad_ip_instance clk_vip ref_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "REF_CLK=ref_clk_vip"
create_bd_port -dir O ref_clk_out
ad_connect ref_clk_out ref_clk_vip/clk_out

# Rx device clk
ad_ip_instance clk_vip rx_device_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "RX_DEVICE_CLK=rx_device_clk_vip"
create_bd_port -dir O rx_device_clk_out
ad_connect rx_device_clk_out rx_device_clk_vip/clk_out

# Tx device clk
ad_ip_instance clk_vip tx_device_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "TX_DEVICE_CLK=tx_device_clk_vip"
create_bd_port -dir O tx_device_clk_out
ad_connect tx_device_clk_out tx_device_clk_vip/clk_out

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

create_bd_port -dir I ref_clk
create_bd_port -dir I rx_device_clk
create_bd_port -dir I tx_device_clk
create_bd_port -dir I sysref

#create_bd_port -dir O rx_sync

set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports rx_device_clk]
set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports tx_device_clk]

# dac peripherals

ad_ip_instance axi_adxcvr axi_ad9144_xcvr [list \
  NUM_OF_LANES $TX_NUM_OF_LANES \
  QPLL_ENABLE 1 \
  TX_OR_RX_N 1 \
]

adi_axi_jesd204_tx_create axi_ad9144_jesd $TX_NUM_OF_LANES

adi_tpl_jesd204_tx_create axi_ad9144_tpl $TX_NUM_OF_LANES \
                                         $TX_NUM_OF_CONVERTERS \
                                         $TX_SAMPLES_PER_FRAME \
                                         $TX_SAMPLE_WIDTH \

ad_ip_instance util_upack2 axi_ad9144_upack [list \
  NUM_OF_CHANNELS $TX_NUM_OF_CONVERTERS \
  SAMPLES_PER_CHANNEL $TX_SAMPLES_PER_CHANNEL \
  SAMPLE_DATA_WIDTH $TX_SAMPLE_WIDTH \
]

ad_ip_instance axi_dmac axi_ad9144_dma [list \
  DMA_TYPE_SRC 0 \
  DMA_TYPE_DEST 1 \
  ID 1 \
  AXI_SLICE_SRC 0 \
  AXI_SLICE_DEST 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  CYCLIC 0 \
  DMA_DATA_WIDTH_SRC 128 \
  DMA_DATA_WIDTH_DEST $dac_data_width \
]

ad_data_offload_create axi_ad9144_offload \
                       1 \
                       $dac_offload_type \
                       $dac_offload_size \
                       $dac_data_width \
                       $dac_data_width \
                       $plddr_offload_axi_data_width \
                       $plddr_offload_axi_addr_width

# synchronization interface
ad_connect axi_ad9144_offload/init_req axi_ad9144_dma/m_axis_xfer_req
ad_connect axi_ad9144_offload/sync_ext GND

# adc peripherals

ad_ip_instance axi_adxcvr axi_ad9680_xcvr [list \
  NUM_OF_LANES $RX_NUM_OF_LANES \
  QPLL_ENABLE 0 \
  TX_OR_RX_N 0 \
]

adi_axi_jesd204_rx_create axi_ad9680_jesd $RX_NUM_OF_LANES

adi_tpl_jesd204_rx_create axi_ad9680_tpl $RX_NUM_OF_LANES \
                                         $RX_NUM_OF_CONVERTERS \
                                         $RX_SAMPLES_PER_FRAME \
                                         $RX_SAMPLE_WIDTH \

ad_ip_instance util_cpack2 axi_ad9680_cpack [list \
  NUM_OF_CHANNELS $RX_NUM_OF_CONVERTERS \
  SAMPLES_PER_CHANNEL $RX_SAMPLES_PER_CHANNEL \
  SAMPLE_DATA_WIDTH $RX_SAMPLE_WIDTH \
]

ad_ip_instance axi_dmac axi_ad9680_dma [list \
  DMA_TYPE_SRC 1 \
  DMA_TYPE_DEST 0 \
  ID 0 \
  AXI_SLICE_SRC 0 \
  AXI_SLICE_DEST 0 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  CYCLIC 0 \
  DMA_DATA_WIDTH_SRC $adc_data_width \
  DMA_DATA_WIDTH_DEST 64 \
]

ad_data_offload_create axi_ad9680_offload \
                       0 \
                       $adc_offload_type \
                       $adc_offload_size \
                       $adc_data_width \
                       $adc_data_width \
                       $plddr_offload_axi_data_width \
                       $plddr_offload_axi_addr_width

# synchronization interface
ad_connect axi_ad9680_offload/init_req axi_ad9680_dma/s_axis_xfer_req
ad_connect axi_ad9680_offload/sync_ext GND

# shared transceiver core

ad_ip_instance util_adxcvr util_daq2_xcvr [list \
  RX_NUM_OF_LANES $MAX_RX_NUM_OF_LANES \
  TX_NUM_OF_LANES $MAX_TX_NUM_OF_LANES \
  QPLL_REFCLK_DIV 1 \
  QPLL_FBDIV_RATIO 1 \
  QPLL_FBDIV 0x30 \
  RX_OUT_DIV 1 \
  TX_OUT_DIV 1 \
  RX_DFE_LPM_CFG 0x0104 \
  RX_CDR_CFG 0x0B000023FF10400020 \
]

ad_connect  $sys_cpu_resetn util_daq2_xcvr/up_rstn
ad_connect  $sys_cpu_clk util_daq2_xcvr/up_clk

# reference clocks & resets

create_bd_port -dir I tx_ref_clk_0
create_bd_port -dir I rx_ref_clk_0

ad_xcvrpll  tx_ref_clk_0 util_daq2_xcvr/qpll_ref_clk_*
ad_xcvrpll  rx_ref_clk_0 util_daq2_xcvr/cpll_ref_clk_*
ad_xcvrpll  axi_ad9144_xcvr/up_pll_rst util_daq2_xcvr/up_qpll_rst_*
ad_xcvrpll  axi_ad9680_xcvr/up_pll_rst util_daq2_xcvr/up_cpll_rst_*

# connections (dac)

ad_xcvrcon  util_daq2_xcvr axi_ad9144_xcvr axi_ad9144_jesd {0 2 3 1} {} {} $MAX_TX_NUM_OF_LANES
ad_connect  util_daq2_xcvr/tx_out_clk_0 axi_ad9144_tpl/link_clk
ad_connect  axi_ad9144_jesd/tx_data axi_ad9144_tpl/link
ad_connect  util_daq2_xcvr/tx_out_clk_0 axi_ad9144_upack/clk
ad_connect  axi_ad9144_jesd_rstgen/peripheral_reset axi_ad9144_upack/reset
ad_connect  axi_ad9144_tpl/dac_dunf axi_ad9144_upack/fifo_rd_underflow

ad_connect  axi_ad9144_tpl/dac_valid_0 axi_ad9144_upack/fifo_rd_en
for {set i 0} {$i < $TX_NUM_OF_CONVERTERS} {incr i} {
  ad_connect  axi_ad9144_tpl/dac_enable_$i axi_ad9144_upack/enable_$i
  ad_connect  axi_ad9144_tpl/dac_data_$i axi_ad9144_upack/fifo_rd_data_$i
}

ad_connect  $sys_cpu_clk axi_ad9144_offload/s_axi_aclk
ad_connect  util_daq2_xcvr/tx_out_clk_0 axi_ad9144_offload/m_axis_aclk
ad_connect  $sys_cpu_clk axi_ad9144_offload/s_axis_aclk
ad_connect  $sys_cpu_clk axi_ad9144_dma/m_axis_aclk

ad_connect  $sys_cpu_resetn axi_ad9144_offload/s_axi_aresetn
ad_connect  axi_ad9144_jesd_rstgen/peripheral_aresetn axi_ad9144_offload/m_axis_aresetn
ad_connect  $sys_cpu_resetn axi_ad9144_offload/s_axis_aresetn
ad_connect  $sys_cpu_resetn axi_ad9144_dma/m_src_axi_aresetn

ad_connect axi_ad9144_upack/s_axis axi_ad9144_offload/m_axis
ad_connect axi_ad9144_offload/s_axis axi_ad9144_dma/m_axis

# connections (adc)

ad_xcvrcon  util_daq2_xcvr axi_ad9680_xcvr axi_ad9680_jesd {} {} {} $MAX_RX_NUM_OF_LANES
ad_connect  util_daq2_xcvr/rx_out_clk_0 axi_ad9680_tpl/link_clk
ad_connect  axi_ad9680_jesd/rx_sof axi_ad9680_tpl/link_sof
ad_connect  axi_ad9680_jesd/rx_data_tdata axi_ad9680_tpl/link_data
ad_connect  axi_ad9680_jesd/rx_data_tvalid axi_ad9680_tpl/link_valid

ad_connect  util_daq2_xcvr/rx_out_clk_0 axi_ad9680_cpack/clk
ad_connect  axi_ad9680_jesd_rstgen/peripheral_reset axi_ad9680_cpack/reset

ad_connect  axi_ad9680_tpl/adc_valid_0 axi_ad9680_cpack/fifo_wr_en
for {set i 0} {$i < $RX_NUM_OF_CONVERTERS} {incr i} {
  ad_connect  axi_ad9680_tpl/adc_enable_$i axi_ad9680_cpack/enable_$i
  ad_connect  axi_ad9680_tpl/adc_data_$i axi_ad9680_cpack/fifo_wr_data_$i
}
ad_connect  axi_ad9680_tpl/adc_dovf axi_ad9680_cpack/fifo_wr_overflow

ad_connect  $sys_cpu_clk axi_ad9680_offload/s_axi_aclk
ad_connect  util_daq2_xcvr/rx_out_clk_0 axi_ad9680_offload/s_axis_aclk
ad_connect  $sys_cpu_clk axi_ad9680_offload/m_axis_aclk
ad_connect  $sys_cpu_clk axi_ad9680_dma/s_axis_aclk

ad_connect  $sys_cpu_resetn axi_ad9680_offload/s_axi_aresetn
ad_connect  axi_ad9680_jesd_rstgen/peripheral_aresetn axi_ad9680_offload/s_axis_aresetn
ad_connect  $sys_cpu_resetn axi_ad9680_dma/m_dest_axi_aresetn
ad_connect  $sys_cpu_resetn axi_ad9680_offload/m_axis_aresetn

ad_connect  axi_ad9680_cpack/packed_fifo_wr_en axi_ad9680_offload/i_data_offload/s_axis_valid
ad_connect  axi_ad9680_cpack/packed_fifo_wr_data axi_ad9680_offload/i_data_offload/s_axis_data

ad_connect axi_ad9680_offload/m_axis axi_ad9680_dma/s_axis

# interconnect (cpu)

ad_cpu_interconnect 0x44A60000 axi_ad9144_xcvr
ad_cpu_interconnect 0x44A04000 axi_ad9144_tpl
ad_cpu_interconnect 0x44A90000 axi_ad9144_jesd
ad_cpu_interconnect 0x7c420000 axi_ad9144_dma
ad_cpu_interconnect 0x7c440000 axi_ad9144_offload
ad_cpu_interconnect 0x44A50000 axi_ad9680_xcvr
ad_cpu_interconnect 0x44A10000 axi_ad9680_tpl
ad_cpu_interconnect 0x44AA0000 axi_ad9680_jesd
ad_cpu_interconnect 0x7c400000 axi_ad9680_dma
ad_cpu_interconnect 0x7c460000 axi_ad9680_offload

# gt uses hp3, and 100MHz clock for both DRP and AXI4

ad_mem_hp3_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP3
ad_mem_hp3_interconnect $sys_cpu_clk axi_ad9680_xcvr/m_axi

# interconnect (mem/dac)

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_cpu_clk axi_ad9144_dma/m_src_axi
ad_mem_hp2_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP2
ad_mem_hp2_interconnect $sys_cpu_clk axi_ad9680_dma/m_dest_axi

# connect exerciser in order to inject data in the tx line of the daq2 design

for {set i 0} {$i < $MAX_TX_NUM_OF_LANES} {incr i} {
create_bd_port -dir I rx_data1_${i}_n
create_bd_port -dir I rx_data1_${i}_p
}

for {set i 0} {$i < $MAX_RX_NUM_OF_LANES} {incr i} {
create_bd_port -dir O tx_data1_${i}_n
create_bd_port -dir O tx_data1_${i}_p
}

source ../common/test_harness/jesd_exerciser.tcl

create_jesd_exerciser rx_jesd_exerciser 0 $ENCODER_SEL $LANE_RATE $TX_NUM_OF_CONVERTERS $TX_NUM_OF_LANES $TX_SAMPLES_PER_FRAME $TX_SAMPLE_WIDTH
create_bd_cell -type container -reference rx_jesd_exerciser i_rx_jesd_exerciser

create_jesd_exerciser tx_jesd_exerciser 1 $ENCODER_SEL $LANE_RATE $RX_NUM_OF_CONVERTERS $RX_NUM_OF_LANES $RX_SAMPLES_PER_FRAME $RX_SAMPLE_WIDTH
create_bd_cell -type container -reference tx_jesd_exerciser i_tx_jesd_exerciser

# Rx exerciser
for {set i 0} {$i < $TX_NUM_OF_LANES} {incr i} {
  ad_connect rx_data1_${i}_n i_rx_jesd_exerciser/rx_data_${i}_n
  ad_connect rx_data1_${i}_p i_rx_jesd_exerciser/rx_data_${i}_p
}
ad_connect sysref i_rx_jesd_exerciser/rx_sysref_0

ad_connect $sys_cpu_clk i_rx_jesd_exerciser/sys_cpu_clk
ad_connect $sys_cpu_resetn i_rx_jesd_exerciser/sys_cpu_resetn

ad_connect rx_device_clk i_rx_jesd_exerciser/device_clk

ad_connect ref_clk i_rx_jesd_exerciser/ref_clk

set_property -dict [list CONFIG.NUM_MI {17}] [get_bd_cells axi_cpu_interconnect]
ad_connect i_rx_jesd_exerciser/S00_AXI_0 axi_cpu_interconnect/M16_AXI

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

ad_connect ref_clk i_tx_jesd_exerciser/ref_clk

set_property -dict [list CONFIG.NUM_MI {18}] [get_bd_cells axi_cpu_interconnect]
ad_connect i_tx_jesd_exerciser/S00_AXI_0 axi_cpu_interconnect/M17_AXI

create_bd_port -dir I ex_tx_sync
ad_connect ex_tx_sync i_tx_jesd_exerciser/tx_sync_0

for {set i 0} {$i < $RX_NUM_OF_CONVERTERS} {incr i} {
  create_bd_port -dir I -from [expr $TX_EX_SAMPLES_PER_CHANNEL*$RX_DMA_SAMPLE_WIDTH-1] -to 0 dac_data_$i
  ad_connect dac_data_$i i_tx_jesd_exerciser/dac_data_${i}_0
}

assign_bd_address

################################################################################
## DDR3 MIG for Data Offload IP
################################################################################

if {$adc_offload_type} {
  set offload_name axi_ad9680_offload
}

if {$dac_offload_type} {
  set offload_name axi_ad9144_offload
}

if {$adc_offload_type || $dac_offload_type} {

    ad_ip_instance proc_sys_reset axi_rstgen
    ad_ip_instance mig_7series axi_ddr_cntrl
    file copy -force $ad_hdl_dir/projects/common/zc706/zc706_plddr3_mig.prj [get_property IP_DIR \
      [get_ips [get_property CONFIG.Component_Name [get_bd_cells axi_ddr_cntrl]]]]
    ad_ip_parameter axi_ddr_cntrl CONFIG.XML_INPUT_FILE zc706_plddr3_mig.prj

    # PL-DDR data offload interfaces
    create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk
    create_bd_port -dir I -type rst sys_rst
    set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports sys_rst]
    create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 ddr3

    ad_connect axi_ddr_cntrl/ui_clk axi_rstgen/slowest_sync_clk
    ad_connect axi_ddr_cntrl/ui_clk $offload_name/fifo2axi_bridge/axi_clk
    ad_connect axi_ddr_cntrl/S_AXI $offload_name/fifo2axi_bridge/ddr_axi
    ad_connect axi_rstgen/peripheral_aresetn $offload_name/fifo2axi_bridge/axi_resetn
    ad_connect axi_rstgen/peripheral_aresetn axi_ddr_cntrl/aresetn
    ad_connect sys_cpu_resetn axi_rstgen/ext_reset_in

    assign_bd_address [get_bd_addr_segs -of_objects [get_bd_cells axi_ddr_cntrl]]

    ad_connect  sys_rst axi_ddr_cntrl/sys_rst
    ad_connect  sys_clk axi_ddr_cntrl/SYS_CLK
    #ad_connect  axi_ddr_cntrl/SYS_CLK GND
    ad_connect  ddr3    axi_ddr_cntrl/DDR3
    ad_connect  axi_ddr_cntrl/device_temp_i GND
    ad_connect  $offload_name/i_data_offload/ddr_calib_done axi_ddr_cntrl/init_calib_complete

}

