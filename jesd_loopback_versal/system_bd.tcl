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

global ad_project_params

set JESD_F $ad_project_params(JESD_F)
# For F=3,6,12 use dual clock
if {$JESD_F % 3 == 0} {
  set LL_OUT_BYTES [expr max($JESD_F,12)]
} else {
  set LL_OUT_BYTES 8
}

set DMA_SAMPLE_WIDTH $ad_project_params(JESD_NP)
if {$DMA_SAMPLE_WIDTH == 12} {
  set DMA_SAMPLE_WIDTH 16
}

set ENCODER_SEL 2; # 1 - 8B10B ; 2 - 64B66B
set NUM_OF_LINKS 1

adi_sim_add_define LL_OUT_BYTES=$LL_OUT_BYTES
set NUM_OF_CONVERTERS $ad_project_params(JESD_M)
set NUM_OF_LANES $ad_project_params(JESD_L)
set SAMPLES_PER_FRAME $ad_project_params(JESD_S)
set SAMPLE_WIDTH $ad_project_params(JESD_NP)

set DAC_DATA_WIDTH [expr $NUM_OF_LANES * $LL_OUT_BYTES * 8]
set SAMPLES_PER_CHANNEL [expr $DAC_DATA_WIDTH / $NUM_OF_CONVERTERS / $SAMPLE_WIDTH]

set MAX_CONVERTERS 16
set MAX_LANES 4

# DRP clk for 204C phy
ad_ip_instance clk_vip drp_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 50000000 \
]
adi_sim_add_define "DRP_CLK=drp_clk_vip"
create_bd_port -dir O drp_clk_out
ad_connect  drp_clk_vip/clk_out drp_clk_out

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

#
#  Block design under test
#

create_bd_port -dir I -type clk ref_clk
create_bd_port -dir I -type clk drp_clk
create_bd_port -dir I -type clk device_clk
create_bd_port -dir I -type clk sysref

set_property CONFIG.FREQ_HZ 250000000 [get_bd_ports device_clk]

# TX JESD204 PHY layer peripheral

for {set i 0} {$i < $MAX_LANES} {incr i} {
create_bd_port -dir I rx_data_${i}_n
create_bd_port -dir I rx_data_${i}_p
create_bd_port -dir O tx_data_${i}_n
create_bd_port -dir O tx_data_${i}_p
}

# reset generator
ad_ip_instance proc_sys_reset device_clk_rstgen
ad_connect  device_clk device_clk_rstgen/slowest_sync_clk
ad_connect  $sys_cpu_resetn device_clk_rstgen/ext_reset_in

# Common PHYs
# Use two instances since they are located on different SLRS
set lane_rate $ad_project_params(LANE_RATE)
set ref_clk_rate $ad_project_params(REF_CLK_RATE)

# RX & TX JESD204 PHY layer peripheral
#ad_ip_instance jesd204_phy jesd204_phy [list \
#  C_LANES $MAX_LANES \
#  GT_Line_Rate $lane_rate \
#  GT_REFCLK_FREQ $ref_clk_rate \
#  DRPCLK_FREQ {50} \
#  C_PLL_SELECTION $ad_project_params(PLL_SEL) \
#  RX_GT_Line_Rate $lane_rate \
#  RX_GT_REFCLK_FREQ $ref_clk_rate \
#  RX_PLL_SELECTION $ad_project_params(PLL_SEL) \
#  GT_Location {X0Y8} \
#  Tx_JesdVersion {1} \
#  Rx_JesdVersion {1} \
#  Tx_use_64b {1} \
#  Rx_use_64b {1} \
#  Min_Line_Rate $lane_rate \
#  Max_Line_Rate $lane_rate \
#  Axi_Lite {true} \
#]

ad_ip_instance gt_quad_base jesd204_phy [list \
  PROT0_LR0_SETTINGS.VALUE_SRC USER \
  PROT0_PRESET.VALUE_SRC USER \
  REG_CONF_INTF {AXI_LITE} \
  PROT0_PRESET {GTY-JESD204_64B66B} \
  PROT0_LR0_SETTINGS { \
    PRESET GTY-JESD204_64B66B \
    INTERNAL_PRESET JESD204_64B66B \
    GT_TYPE GTY \
    GT_DIRECTION DUPLEX \
    TX_LINE_RATE 24.75 \
    TX_PLL_TYPE LCPLL \
    TX_REFCLK_FREQUENCY 200 \
    TX_ACTUAL_REFCLK_FREQUENCY 200.000000000000 \
    TX_FRACN_ENABLED true \
    TX_FRACN_NUMERATOR 0 \
    TX_REFCLK_SOURCE R0 \
    TX_DATA_ENCODING 64B66B_ASYNC \
    TX_USER_DATA_WIDTH 64 \
    TX_INT_DATA_WIDTH 64 \
    TX_BUFFER_MODE 1 \
    TX_BUFFER_BYPASS_MODE Fast_Sync \
    TX_PIPM_ENABLE false \
    TX_OUTCLK_SOURCE TXPROGDIVCLK \
    TXPROGDIV_FREQ_ENABLE true \
    TXPROGDIV_FREQ_SOURCE LCPLL \
    TXPROGDIV_FREQ_VAL 375.000 \
    TX_DIFF_SWING_EMPH_MODE CUSTOM \
    TX_64B66B_SCRAMBLER false \
    TX_64B66B_ENCODER false \
    TX_64B66B_CRC false \
    TX_RATE_GROUP A \
    RX_LINE_RATE 24.75 \
    RX_PLL_TYPE LCPLL \
    RX_REFCLK_FREQUENCY 200 \
    RX_ACTUAL_REFCLK_FREQUENCY 200.000000000000 \
    RX_FRACN_ENABLED true \
    RX_FRACN_NUMERATOR 0 \
    RX_REFCLK_SOURCE R0 \
    RX_DATA_DECODING 64B66B_ASYNC \
    RX_USER_DATA_WIDTH 64 \
    RX_INT_DATA_WIDTH 64 \
    RX_BUFFER_MODE 1 \
    RX_OUTCLK_SOURCE RXPROGDIVCLK \
    RXPROGDIV_FREQ_ENABLE true \
    RXPROGDIV_FREQ_SOURCE LCPLL \
    RXPROGDIV_FREQ_VAL 375.000 \
    INS_LOSS_NYQ 12 \
    RX_EQ_MODE DFE \
    RX_COUPLING AC \
    RX_TERMINATION PROGRAMMABLE \
    RX_RATE_GROUP A \
    RX_TERMINATION_PROG_VALUE 800 \
    RX_PPM_OFFSET 0 \
    RX_64B66B_DESCRAMBLER false \
    RX_64B66B_DECODER false \
    RX_64B66B_CRC false \
    OOB_ENABLE false \
    RX_COMMA_ALIGN_WORD 1 \
    RX_COMMA_SHOW_REALIGN_ENABLE true \
    PCIE_ENABLE false \
    RX_COMMA_P_ENABLE false \
    RX_COMMA_M_ENABLE false \
    RX_COMMA_DOUBLE_ENABLE false \
    RX_COMMA_P_VAL 0101111100 \
    RX_COMMA_M_VAL 1010000011 \
    RX_COMMA_MASK 0000000000 \
    RX_SLIDE_MODE OFF \
    RX_SSC_PPM 0 \
    RX_CB_NUM_SEQ 0 \
    RX_CB_LEN_SEQ 1 \
    RX_CB_MAX_SKEW 1 \
    RX_CB_MAX_LEVEL 1 \
    RX_CB_MASK_0_0 false \
    RX_CB_VAL_0_0 00000000 \
    RX_CB_K_0_0 false \
    RX_CB_DISP_0_0 false \
    RX_CB_MASK_0_1 false \
    RX_CB_VAL_0_1 00000000 \
    RX_CB_K_0_1 false \
    RX_CB_DISP_0_1 false \
    RX_CB_MASK_0_2 false \
    RX_CB_VAL_0_2 00000000 \
    RX_CB_K_0_2 false \
    RX_CB_DISP_0_2 false \
    RX_CB_MASK_0_3 false \
    RX_CB_VAL_0_3 00000000 \
    RX_CB_K_0_3 false \
    RX_CB_DISP_0_3 false \
    RX_CB_MASK_1_0 false \
    RX_CB_VAL_1_0 00000000 \
    RX_CB_K_1_0 false \
    RX_CB_DISP_1_0 false \
    RX_CB_MASK_1_1 false \
    RX_CB_VAL_1_1 00000000 \
    RX_CB_K_1_1 false \
    RX_CB_DISP_1_1 false \
    RX_CB_MASK_1_2 false \
    RX_CB_VAL_1_2 00000000 \
    RX_CB_K_1_2 false \
    RX_CB_DISP_1_2 false \
    RX_CB_MASK_1_3 false \
    RX_CB_VAL_1_3 00000000 \
    RX_CB_K_1_3 false \
    RX_CB_DISP_1_3 false \
    RX_CC_NUM_SEQ 0 \
    RX_CC_LEN_SEQ 1 \
    RX_CC_PERIODICITY 5000 \
    RX_CC_KEEP_IDLE DISABLE \
    RX_CC_PRECEDENCE ENABLE \
    RX_CC_REPEAT_WAIT 0 \
    RX_CC_VAL 00000000000000000000000000000000000000000000000000000000000000000000000000000000 \
    RX_CC_MASK_0_0 false \
    RX_CC_VAL_0_0 00000000 \
    RX_CC_K_0_0 false \
    RX_CC_DISP_0_0 false \
    RX_CC_MASK_0_1 false \
    RX_CC_VAL_0_1 00000000 \
    RX_CC_K_0_1 false \
    RX_CC_DISP_0_1 false \
    RX_CC_MASK_0_2 false \
    RX_CC_VAL_0_2 00000000 \
    RX_CC_K_0_2 false \
    RX_CC_DISP_0_2 false \
    RX_CC_MASK_0_3 false \
    RX_CC_VAL_0_3 00000000 \
    RX_CC_K_0_3 false \
    RX_CC_DISP_0_3 false \
    RX_CC_MASK_1_0 false \
    RX_CC_VAL_1_0 00000000 \
    RX_CC_K_1_0 false \
    RX_CC_DISP_1_0 false \
    RX_CC_MASK_1_1 false \
    RX_CC_VAL_1_1 00000000 \
    RX_CC_K_1_1 false \
    RX_CC_DISP_1_1 false \
    RX_CC_MASK_1_2 false \
    RX_CC_VAL_1_2 00000000 \
    RX_CC_K_1_2 false \
    RX_CC_DISP_1_2 false \
    RX_CC_MASK_1_3 false \
    RX_CC_VAL_1_3 00000000 \
    RX_CC_K_1_3 false \
    RX_CC_DISP_1_3 false \
    PCIE_USERCLK2_FREQ 250 \
    PCIE_USERCLK_FREQ 250 \
    RX_JTOL_FC 10 \
    RX_JTOL_LF_SLOPE -20 \
    RX_BUFFER_BYPASS_MODE Fast_Sync \
    RX_BUFFER_BYPASS_MODE_LANE MULTI \
    RX_BUFFER_RESET_ON_CB_CHANGE ENABLE \
    RX_BUFFER_RESET_ON_COMMAALIGN DISABLE \
    RX_BUFFER_RESET_ON_RATE_CHANGE ENABLE \
    TX_BUFFER_RESET_ON_RATE_CHANGE ENABLE \
    RESET_SEQUENCE_INTERVAL 0 \
    RX_COMMA_PRESET NONE \
    RX_COMMA_VALID_ONLY 0 \
  } \
  PROT_OUTCLK_VALUES {CH0_RXOUTCLK 375 CH0_TXOUTCLK 375 CH1_RXOUTCLK 375 CH1_TXOUTCLK 375 CH2_RXOUTCLK 375 CH2_TXOUTCLK 375 CH3_RXOUTCLK 375 CH3_TXOUTCLK 375} \
  REFCLK_STRING {HSCLK0_LCPLLGTREFCLK0 refclk_PROT0_R0_200_MHz_unique1 HSCLK1_LCPLLGTREFCLK0 refclk_PROT0_R0_200_MHz_unique1} \
]

# can't connect rxout_clk to user_clk tgrough bufg here:( ###%%^&&^%
make_bd_pins_external  [get_bd_pins jesd204_phy/ch0_txoutclk]
make_bd_pins_external  [get_bd_pins jesd204_phy/ch0_rxoutclk]

create_bd_port -dir I rxoutclk_in
create_bd_port -dir I txoutclk_in

set rx_link_clock  rxoutclk_in
set tx_link_clock  txoutclk_in

# AXI_ADXCVR control
ad_ip_instance axi_adxcvr axi_rx_xcvr [ list \
  LINK_MODE $ENCODER_SEL \
  NUM_OF_LANES $NUM_OF_LANES \
  TX_OR_RX_N 0 \
  QPLL_ENABLE 0 \
  ]

ad_ip_instance axi_adxcvr axi_tx_xcvr [ list \
  LINK_MODE $ENCODER_SEL \
  NUM_OF_LANES $NUM_OF_LANES \
  TX_OR_RX_N 1 \
  QPLL_ENABLE 0 \
  ]

# TX JESD204 link layer peripheral
adi_axi_jesd204_tx_create dac_jesd204_link $NUM_OF_LANES $NUM_OF_LINKS $ENCODER_SEL
ad_ip_parameter dac_jesd204_link/tx CONFIG.TPL_DATA_PATH_WIDTH $LL_OUT_BYTES

# TX JESD204 transport layer peripheral
adi_tpl_jesd204_tx_create dac_jesd204_transport $NUM_OF_LANES \
                                                $NUM_OF_CONVERTERS \
                                                $SAMPLES_PER_FRAME \
                                                $SAMPLE_WIDTH \
                                                $LL_OUT_BYTES \
                                                $DMA_SAMPLE_WIDTH

# RX JESD204 link layer peripheral
adi_axi_jesd204_rx_create adc_jesd204_link $NUM_OF_LANES $NUM_OF_LINKS $ENCODER_SEL
ad_ip_parameter adc_jesd204_link/rx CONFIG.TPL_DATA_PATH_WIDTH $LL_OUT_BYTES

# RX JESD204 transport layer peripheral
adi_tpl_jesd204_rx_create adc_jesd204_transport $NUM_OF_LANES \
                                                $NUM_OF_CONVERTERS \
                                                $SAMPLES_PER_FRAME \
                                                $SAMPLE_WIDTH \
                                                $LL_OUT_BYTES \
                                                $DMA_SAMPLE_WIDTH

# loopback serial lanes to PHY externally
make_bd_intf_pins_external  [get_bd_intf_pins jesd204_phy/GT_Serial]

# Connect PHY to Link Layer
for {set j 0}  {$j < $NUM_OF_LANES} {incr j} {
  ad_ip_instance jesd204_versal_gt_adapter_tx tx_adapt_${j}
  ad_connect  dac_jesd204_link/tx_phy${j} tx_adapt_${j}/TX
  ad_connect  tx_adapt_${j}/TX_GT_IP_Interface jesd204_phy/TX${j}_GT_IP_Interface

  ad_ip_instance jesd204_versal_gt_adapter_rx rx_adapt_${j}
  ad_connect  adc_jesd204_link/rx_phy${j} rx_adapt_${j}/RX
  ad_connect  rx_adapt_${j}/RX_GT_IP_Interface jesd204_phy/RX${j}_GT_IP_Interface

  ad_connect axi_tx_xcvr/up_ch_${j} tx_adapt_${j}/up_tx
  ad_connect axi_rx_xcvr/up_ch_${j} rx_adapt_${j}/up_rx

  # connect PLL lock
  ad_connect  jesd204_phy/hsclk[expr $j % 2]_lcplllock  tx_adapt_${j}/hsclk_lcplllocked
  ad_connect  jesd204_phy/hsclk[expr $j % 2]_rplllock  tx_adapt_${j}/hsclk_rplllocked
  ad_connect  jesd204_phy/hsclk[expr $j % 2]_lcplllock  rx_adapt_${j}/hsclk_lcplllocked
  ad_connect  jesd204_phy/hsclk[expr $j % 2]_rplllock  rx_adapt_${j}/hsclk_rplllocked

  # ilo reset 
  ad_connect rx_adapt_${j}/ilo_reset jesd204_phy/ch${j}_iloreset

  # link clock to adapter
  ad_connect $rx_link_clock  rx_adapt_${j}/usr_clk
  ad_connect $tx_link_clock  tx_adapt_${j}/usr_clk

}

ad_connect  sysref  dac_jesd204_link/sysref
ad_connect  sysref  adc_jesd204_link/sysref

# connect link layer to transport layer
ad_connect  dac_jesd204_link/tx_data dac_jesd204_transport/link

ad_connect  adc_jesd204_link/rx_sof adc_jesd204_transport/link_sof
ad_connect  adc_jesd204_link/rx_data_tdata adc_jesd204_transport/link_data
ad_connect  adc_jesd204_link/rx_data_tvalid adc_jesd204_transport/link_valid

# reference clocks & resets

ad_connect  ref_clk /jesd204_phy/GT_REFCLK0

ad_connect $tx_link_clock /jesd204_phy/ch0_txusrclk
ad_connect $tx_link_clock /jesd204_phy/ch1_txusrclk
ad_connect $tx_link_clock /jesd204_phy/ch2_txusrclk
ad_connect $tx_link_clock /jesd204_phy/ch3_txusrclk

ad_connect $rx_link_clock /jesd204_phy/ch0_rxusrclk
ad_connect $rx_link_clock /jesd204_phy/ch1_rxusrclk
ad_connect $rx_link_clock /jesd204_phy/ch2_rxusrclk
ad_connect $rx_link_clock /jesd204_phy/ch3_rxusrclk

ad_connect $tx_link_clock  dac_jesd204_link/link_clk
ad_connect $rx_link_clock  adc_jesd204_link/link_clk

ad_connect  device_clk dac_jesd204_link/device_clk
ad_connect  device_clk adc_jesd204_link/device_clk

ad_connect  device_clk dac_jesd204_transport/link_clk
ad_connect  device_clk adc_jesd204_transport/link_clk

# PLL resets
ad_connect axi_tx_xcvr/up_pll_rst jesd204_phy/hsclk0_lcpllreset
ad_connect axi_tx_xcvr/up_pll_rst jesd204_phy/hsclk1_lcpllreset

ad_connect axi_rx_xcvr/up_pll_rst jesd204_phy/hsclk0_rpllreset
ad_connect axi_rx_xcvr/up_pll_rst jesd204_phy/hsclk1_rpllreset

# TODO : Investigate why this is not connected automatically
ad_connect $sys_cpu_resetn jesd204_phy/s_axi_lite_resetn

ad_cpu_interconnect 0x44a40000 axi_rx_xcvr
ad_cpu_interconnect 0x44a50000 axi_tx_xcvr
ad_cpu_interconnect 0x44a60000 jesd204_phy
ad_cpu_interconnect 0x44a90000 adc_jesd204_link
ad_cpu_interconnect 0x44b90000 dac_jesd204_link
ad_cpu_interconnect 0x44a10000 adc_jesd204_transport
ad_cpu_interconnect 0x44b10000 dac_jesd204_transport

for {set i 0} {$i < $NUM_OF_CONVERTERS} {incr i} {
  create_bd_port -dir I -from [expr $SAMPLES_PER_CHANNEL*$DMA_SAMPLE_WIDTH-1] -to 0 dac_data_$i
  ad_connect dac_data_$i dac_jesd204_transport/dac_data_$i
}

# Create dummy input channels
for {set i $NUM_OF_CONVERTERS} {$i < $MAX_CONVERTERS} {incr i} {
  create_bd_port -dir I -from [expr $SAMPLES_PER_CHANNEL*$DMA_SAMPLE_WIDTH-1] -to 0 dac_data_$i
}

make_bd_pins_external  [get_bd_pins /dac_jesd204_transport/dac_dunf]
make_bd_pins_external  [get_bd_pins /adc_jesd204_transport/adc_dovf]
