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

source ../../scripts/adi_env.tcl

source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl

global ad_project_params

source $ad_hdl_dir/projects/common/xilinx/adcfifo_bd.tcl
source $ad_hdl_dir/projects/common/xilinx/dacfifo_bd.tcl

## ADC FIFO depth in samples per converter
set adc_fifo_samples_per_converter [expr 4*1024]
## DAC FIFO depth in samples per converter
set dac_fifo_samples_per_converter [expr 4*1024]

# DRP clk for 204C phy
ad_ip_instance clk_vip drp_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 50000000 \
]
adi_sim_add_define "DRP_CLK=drp_clk_vip"

# Ref clk
ad_ip_instance clk_vip ref_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "REF_CLK=ref_clk_vip"
create_bd_port -dir O ref_clk_out
ad_connect ref_clk_out ref_clk_vip/clk_out

# Device clk
ad_ip_instance clk_vip device_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "DEVICE_CLK=device_clk_vip"
create_bd_port -dir O device_clk_out
ad_connect device_clk_out device_clk_vip/clk_out

# SYSREF clk
ad_ip_instance clk_vip sysref_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 5000000 \
]
adi_sim_add_define "SYSREF_CLK=sysref_clk_vip"
create_bd_port -dir O sysref_clk_out
ad_connect sysref_clk_out sysref_clk_vip/clk_out

###

# TX parameters
set TX_NUM_OF_LINKS $ad_project_params(TX_NUM_LINKS)

# TX JESD parameter per link
set TX_JESD_M     $ad_project_params(TX_JESD_M)
set TX_JESD_L     $ad_project_params(TX_JESD_L)
set TX_JESD_S     $ad_project_params(TX_JESD_S)
set TX_JESD_NP    $ad_project_params(TX_JESD_NP)

set NUM_OF_LANES      [expr $TX_JESD_L * $TX_NUM_OF_LINKS]
set NUM_OF_CONVERTERS [expr $TX_JESD_M * $TX_NUM_OF_LINKS]
set SAMPLES_PER_FRAME $TX_JESD_S
set SAMPLE_WIDTH      $TX_JESD_NP
set DMA_SAMPLE_WIDTH  $TX_JESD_NP
if {$DMA_SAMPLE_WIDTH == 12} {
  set DMA_SAMPLE_WIDTH 16
}
set DATAPATH_WIDTH [adi_jesd204_calc_tpl_width 4 $TX_JESD_L $TX_JESD_M $TX_JESD_S $TX_JESD_NP]

set SAMPLES_PER_CHANNEL [expr $NUM_OF_LANES * 8*$DATAPATH_WIDTH / ($NUM_OF_CONVERTERS * $SAMPLE_WIDTH)]

set DAC_DMA_DATA_WIDTH   [expr $DMA_SAMPLE_WIDTH*$NUM_OF_CONVERTERS*$SAMPLES_PER_CHANNEL]

set dac_fifo_name ad9083_dac_fifo
set dac_data_width [expr $SAMPLE_WIDTH*$NUM_OF_CONVERTERS*$SAMPLES_PER_CHANNEL]
set dac_dma_data_width [expr $DMA_SAMPLE_WIDTH*$NUM_OF_CONVERTERS*$SAMPLES_PER_CHANNEL]
set dac_fifo_address_width [expr int(ceil(log(($dac_fifo_samples_per_converter*$NUM_OF_CONVERTERS) / ($dac_data_width/$SAMPLE_WIDTH))/log(2)))]

create_bd_port -dir I vip_ref_clk
create_bd_port -dir I vip_device_clk

ad_ip_instance axi_dmac axi_ad9083_tx_dma [list \
  DMA_TYPE_SRC 0 \
  DMA_TYPE_DEST 1 \
  ID 0 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  CYCLIC 1 \
  DMA_DATA_WIDTH_SRC 512 \
  DMA_DATA_WIDTH_DEST $DAC_DMA_DATA_WIDTH \
  MAX_BYTES_PER_BURST 4096 \
]

ad_connect $sys_dma_clk axi_ad9083_tx_dma/m_axis_aclk

ad_mem_hp1_interconnect $sys_dma_clk axi_ad9083_tx_dma/m_src_axi

ad_ip_instance util_upack2 util_mxfe_upack [list \
  NUM_OF_CHANNELS $NUM_OF_CONVERTERS \
  SAMPLES_PER_CHANNEL $SAMPLES_PER_CHANNEL \
  SAMPLE_DATA_WIDTH $SAMPLE_WIDTH \
]

ad_dacfifo_create $dac_fifo_name $dac_data_width $dac_data_width $dac_fifo_address_width

ad_connect  vip_device_clk util_mxfe_upack/clk

ad_connect  vip_device_clk ad9083_dac_fifo/dac_clk
ad_connect  $sys_dma_clk ad9083_dac_fifo/dma_clk

ad_connect  util_mxfe_upack/s_axis_valid VCC
ad_connect  util_mxfe_upack/s_axis_ready ad9083_dac_fifo/dac_valid
ad_connect  util_mxfe_upack/s_axis_data ad9083_dac_fifo/dac_data

# DMA to DAC FIFO
ad_connect  ad9083_dac_fifo/dma_valid axi_ad9083_tx_dma/m_axis_valid
ad_connect  axi_ad9083_tx_dma/m_axis_data ad9083_dac_fifo/dma_data
ad_connect  ad9083_dac_fifo/dma_ready axi_ad9083_tx_dma/m_axis_ready
ad_connect  ad9083_dac_fifo/dma_xfer_req axi_ad9083_tx_dma/m_axis_xfer_req
ad_connect  ad9083_dac_fifo/dma_xfer_last axi_ad9083_tx_dma/m_axis_last

# TX JESD204 PHY layer peripheral
ad_ip_instance axi_adxcvr dac_jesd204_xcvr [list \
  NUM_OF_LANES $NUM_OF_LANES \
  QPLL_ENABLE 1 \
  TX_OR_RX_N 1 \
  OUT_CLK_SEL 3 \
  SYS_CLK_SEL 3 \
]

# TX JESD204 link layer peripheral
adi_axi_jesd204_tx_create dac_jesd204_link $NUM_OF_LANES
ad_ip_parameter dac_jesd204_link/tx CONFIG.TPL_DATA_PATH_WIDTH 8

# TX JESD204 transport layer peripheral
adi_tpl_jesd204_tx_create dac_jesd204_transport $NUM_OF_LANES \
                                                $NUM_OF_CONVERTERS \
                                                $SAMPLES_PER_FRAME \
                                                $SAMPLE_WIDTH

ad_ip_instance util_adxcvr util_jesd204_xcvr [list \
  RX_NUM_OF_LANES 0 \
  TX_NUM_OF_LANES $NUM_OF_LANES \
  QPLL_FBDIV 40 \
  QPLL_REFCLK_DIV 2 \
  RX_OUT_DIV 1 \
  RX_CLK25_DIV 10 \
  POR_CFG 0x0 \
  QPLL_CFG0 0x391c \
  QPLL_CFG1 0x0000 \
  QPLL_CFG1_G3 0x0020 \
  QPLL_CFG2 0x0f80 \
  QPLL_CFG2_G3 0x0f80 \
  QPLL_CFG3 0x0120 \
  QPLL_CFG4 0x0002 \
  QPLL_CP 0x1f \
  QPLL_CP_G3 0x1f \
  QPLL_LPF 0x2ff \
  CH_HSPMUX 0x2424 \
  PREIQ_FREQ_BST 0 \
  RXPI_CFG0 0x0002 \
  RXPI_CFG1 0x0 \
  RXCDR_CFG0 0x3 \
  RXCDR_CFG2_GEN2 0x164 \
  RXCDR_CFG2_GEN4 0x0 \
  RXCDR_CFG3 0x2a \
  RXCDR_CFG3_GEN2 0x24 \
  RXCDR_CFG3_GEN3 0x0 \
  RXCDR_CFG3_GEN4 0x0 \
  ]

ad_connect  dac_jesd204_transport/dac_valid_0 util_mxfe_upack/fifo_rd_en
for {set i 0} {$i < $NUM_OF_CONVERTERS} {incr i} {
  ad_connect  util_mxfe_upack/fifo_rd_data_$i dac_jesd204_transport/dac_data_$i
  ad_connect  dac_jesd204_transport/dac_enable_$i  util_mxfe_upack/enable_$i
}

ad_connect  ad9083_dac_fifo/dac_dunf dac_jesd204_transport/dac_dunf

ad_xcvrcon util_jesd204_xcvr dac_jesd204_xcvr dac_jesd204_link {} {} vip_device_clk
ad_connect dac_jesd204_link/tx_data dac_jesd204_transport/link
ad_xcvrpll dac_jesd204_xcvr/up_pll_rst util_jesd204_xcvr/up_qpll_rst_*
ad_xcvrpll dac_jesd204_xcvr/up_pll_rst util_jesd204_xcvr/up_cpll_rst_*
ad_connect  $sys_cpu_resetn util_jesd204_xcvr/up_rstn

ad_disconnect $sys_mem_resetn axi_mem_interconnect/aresetn
ad_connect    $sys_dma_resetn axi_mem_interconnect/aresetn

ad_connect  sys_dma_rstgen/peripheral_reset ad9083_dac_fifo/dma_rst
ad_connect  sys_dma_rstgen/peripheral_aresetn axi_ad9083_tx_dma/m_src_axi_aresetn
ad_connect  vip_device_clk_rstgen/peripheral_reset util_mxfe_upack/reset
ad_connect  vip_device_clk_rstgen/peripheral_reset ad9083_dac_fifo/dac_rst

ad_connect device_clk dac_jesd204_transport/link_clk

ad_xcvrpll vip_ref_clk util_jesd204_xcvr/qpll_ref_clk_*
ad_xcvrpll vip_ref_clk util_jesd204_xcvr/cpll_ref_clk_*

ad_connect $sys_cpu_clk util_jesd204_xcvr/up_clk
ad_connect vip_device_clk dac_jesd204_transport/link_clk

make_bd_pins_external  [get_bd_pins /dac_jesd204_transport/dac_dunf]

ad_cpu_interconnect 0x44b60000 dac_jesd204_xcvr
ad_cpu_interconnect 0x44b90000 dac_jesd204_link
ad_cpu_interconnect 0x44b10000 dac_jesd204_transport
ad_cpu_interconnect 0x7c430000 axi_ad9083_tx_dma

#
#  Block design under test
#
#
source $ad_hdl_dir/projects/ad9083_evb/common/ad9083_evb_bd.tcl

set RX_DMA 0x7C400000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9083_rx_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set RX_XCVR 0x44A60000
set_property offset $RX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9083_rx_xcvr}]
adi_sim_add_define "RX_XCVR_BA=[format "%d" ${RX_XCVR}]"

set AXI_JESD_RX 0x44AA0000
set_property offset $AXI_JESD_RX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9083_rx_jesd}]
adi_sim_add_define "AXI_JESD_RX_BA=[format "%d" ${AXI_JESD_RX}]"

set ADC_TPL 0x44A00000
set_property offset $ADC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_rx_ad9083_tpl_core}]
adi_sim_add_define "ADC_TPL_BA=[format "%d" ${ADC_TPL}]"

set TX_DMA 0x7C430000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9083_tx_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"

set TX_XCVR 0x44B60000
set_property offset $TX_XCVR [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dac_jesd204_xcvr}]
adi_sim_add_define "TX_XCVR_BA=[format "%d" ${TX_XCVR}]"

set AXI_JESD_TX 0x44B90000
set_property offset $AXI_JESD_TX [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dac_jesd204_link}]
adi_sim_add_define "AXI_JESD_TX_BA=[format "%d" ${AXI_JESD_TX}]"

set DAC_TPL 0x44B10000
set_property offset $DAC_TPL [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dac_jesd204_transport}]
adi_sim_add_define "DAC_TPL_BA=[format "%d" ${DAC_TPL}]"
