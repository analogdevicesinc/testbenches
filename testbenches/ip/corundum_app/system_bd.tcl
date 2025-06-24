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

## DUT configuration

set FPGA_ID $ad_project_params(FPGA_ID)
set FW_ID $ad_project_params(FW_ID)
set FW_VER $ad_project_params(FW_VER)
set BOARD_ID $ad_project_params(BOARD_ID)
set BOARD_VER $ad_project_params(BOARD_VER)
set BUILD_DATE $ad_project_params(BUILD_DATE)
set GIT_HASH $ad_project_params(GIT_HASH)
set RELEASE_INFO $ad_project_params(RELEASE_INFO)
set IF_COUNT $ad_project_params(IF_COUNT)
set PORTS_PER_IF $ad_project_params(PORTS_PER_IF)
set SCHED_PER_IF $ad_project_params(SCHED_PER_IF)
set PORT_COUNT $ad_project_params(PORT_COUNT)
set CLK_PERIOD_NS_NUM $ad_project_params(CLK_PERIOD_NS_NUM)
set CLK_PERIOD_NS_DENOM $ad_project_params(CLK_PERIOD_NS_DENOM)
set PTP_CLK_PERIOD_NS_NUM $ad_project_params(PTP_CLK_PERIOD_NS_NUM)
set PTP_CLK_PERIOD_NS_DENOM $ad_project_params(PTP_CLK_PERIOD_NS_DENOM)
set PTP_CLOCK_PIPELINE $ad_project_params(PTP_CLOCK_PIPELINE)
set PTP_CLOCK_CDC_PIPELINE $ad_project_params(PTP_CLOCK_CDC_PIPELINE)
set PTP_SEPARATE_TX_CLOCK $ad_project_params(PTP_SEPARATE_TX_CLOCK)
set PTP_SEPARATE_RX_CLOCK $ad_project_params(PTP_SEPARATE_RX_CLOCK)
set PTP_PORT_CDC_PIPELINE $ad_project_params(PTP_PORT_CDC_PIPELINE)
set PTP_PEROUT_ENABLE $ad_project_params(PTP_PEROUT_ENABLE)
set PTP_PEROUT_COUNT $ad_project_params(PTP_PEROUT_COUNT)
set EVENT_QUEUE_OP_TABLE_SIZE $ad_project_params(EVENT_QUEUE_OP_TABLE_SIZE)
set TX_QUEUE_OP_TABLE_SIZE $ad_project_params(TX_QUEUE_OP_TABLE_SIZE)
set RX_QUEUE_OP_TABLE_SIZE $ad_project_params(RX_QUEUE_OP_TABLE_SIZE)
set CQ_OP_TABLE_SIZE $ad_project_params(CQ_OP_TABLE_SIZE)
set EQN_WIDTH $ad_project_params(EQN_WIDTH)
set TX_QUEUE_INDEX_WIDTH $ad_project_params(TX_QUEUE_INDEX_WIDTH)
set RX_QUEUE_INDEX_WIDTH $ad_project_params(RX_QUEUE_INDEX_WIDTH)
set CQN_WIDTH $ad_project_params(CQN_WIDTH)
set EQ_PIPELINE $ad_project_params(EQ_PIPELINE)
set TX_QUEUE_PIPELINE $ad_project_params(TX_QUEUE_PIPELINE)
set RX_QUEUE_PIPELINE $ad_project_params(RX_QUEUE_PIPELINE)
set CQ_PIPELINE $ad_project_params(CQ_PIPELINE)
set TX_DESC_TABLE_SIZE $ad_project_params(TX_DESC_TABLE_SIZE)
set RX_DESC_TABLE_SIZE $ad_project_params(RX_DESC_TABLE_SIZE)
set RX_INDIR_TBL_ADDR_WIDTH $ad_project_params(RX_INDIR_TBL_ADDR_WIDTH)
set TX_SCHEDULER_OP_TABLE_SIZE $ad_project_params(TX_SCHEDULER_OP_TABLE_SIZE)
set TX_SCHEDULER_PIPELINE $ad_project_params(TX_SCHEDULER_PIPELINE)
set TDMA_INDEX_WIDTH $ad_project_params(TDMA_INDEX_WIDTH)
set PTP_TS_ENABLE $ad_project_params(PTP_TS_ENABLE)
set PTP_TS_FMT_TOD $ad_project_params(PTP_TS_FMT_TOD)
set PTP_TS_WIDTH $ad_project_params(PTP_TS_WIDTH)
set TX_CPL_ENABLE $ad_project_params(TX_CPL_ENABLE)
set TX_CPL_FIFO_DEPTH $ad_project_params(TX_CPL_FIFO_DEPTH)
set TX_TAG_WIDTH $ad_project_params(TX_TAG_WIDTH)
set TX_CHECKSUM_ENABLE $ad_project_params(TX_CHECKSUM_ENABLE)
set RX_HASH_ENABLE $ad_project_params(RX_HASH_ENABLE)
set RX_CHECKSUM_ENABLE $ad_project_params(RX_CHECKSUM_ENABLE)
set PFC_ENABLE $ad_project_params(PFC_ENABLE)
set LFC_ENABLE $ad_project_params(LFC_ENABLE)
set MAC_CTRL_ENABLE $ad_project_params(MAC_CTRL_ENABLE)
set TX_FIFO_DEPTH $ad_project_params(TX_FIFO_DEPTH)
set RX_FIFO_DEPTH $ad_project_params(RX_FIFO_DEPTH)
set MAX_TX_SIZE $ad_project_params(MAX_TX_SIZE)
set MAX_RX_SIZE $ad_project_params(MAX_RX_SIZE)
set TX_RAM_SIZE $ad_project_params(TX_RAM_SIZE)
set RX_RAM_SIZE $ad_project_params(RX_RAM_SIZE)
set DDR_ENABLE $ad_project_params(DDR_ENABLE)
set DDR_CH $ad_project_params(DDR_CH)
set DDR_GROUP_SIZE $ad_project_params(DDR_GROUP_SIZE)
set AXI_DDR_DATA_WIDTH $ad_project_params(AXI_DDR_DATA_WIDTH)
set AXI_DDR_ADDR_WIDTH $ad_project_params(AXI_DDR_ADDR_WIDTH)
set AXI_DDR_STRB_WIDTH $ad_project_params(AXI_DDR_STRB_WIDTH)
set AXI_DDR_ID_WIDTH $ad_project_params(AXI_DDR_ID_WIDTH)
set AXI_DDR_AWUSER_ENABLE $ad_project_params(AXI_DDR_AWUSER_ENABLE)
set AXI_DDR_WUSER_ENABLE $ad_project_params(AXI_DDR_WUSER_ENABLE)
set AXI_DDR_BUSER_ENABLE $ad_project_params(AXI_DDR_BUSER_ENABLE)
set AXI_DDR_ARUSER_ENABLE $ad_project_params(AXI_DDR_ARUSER_ENABLE)
set AXI_DDR_RUSER_ENABLE $ad_project_params(AXI_DDR_RUSER_ENABLE)
set AXI_DDR_MAX_BURST_LEN $ad_project_params(AXI_DDR_MAX_BURST_LEN)
set AXI_DDR_NARROW_BURST $ad_project_params(AXI_DDR_NARROW_BURST)
set AXI_DDR_FIXED_BURST $ad_project_params(AXI_DDR_FIXED_BURST)
set AXI_DDR_WRAP_BURST $ad_project_params(AXI_DDR_WRAP_BURST)
set HBM_ENABLE $ad_project_params(HBM_ENABLE)
set HBM_CH $ad_project_params(HBM_CH)
set HBM_GROUP_SIZE $ad_project_params(HBM_GROUP_SIZE)
set AXI_HBM_DATA_WIDTH $ad_project_params(AXI_HBM_DATA_WIDTH)
set AXI_HBM_ADDR_WIDTH $ad_project_params(AXI_HBM_ADDR_WIDTH)
set AXI_HBM_STRB_WIDTH $ad_project_params(AXI_HBM_STRB_WIDTH)
set AXI_HBM_ID_WIDTH $ad_project_params(AXI_HBM_ID_WIDTH)
set AXI_HBM_AWUSER_ENABLE $ad_project_params(AXI_HBM_AWUSER_ENABLE)
set AXI_HBM_AWUSER_WIDTH $ad_project_params(AXI_HBM_AWUSER_WIDTH)
set AXI_HBM_WUSER_ENABLE $ad_project_params(AXI_HBM_WUSER_ENABLE)
set AXI_HBM_WUSER_WIDTH $ad_project_params(AXI_HBM_WUSER_WIDTH)
set AXI_HBM_BUSER_ENABLE $ad_project_params(AXI_HBM_BUSER_ENABLE)
set AXI_HBM_BUSER_WIDTH $ad_project_params(AXI_HBM_BUSER_WIDTH)
set AXI_HBM_ARUSER_ENABLE $ad_project_params(AXI_HBM_ARUSER_ENABLE)
set AXI_HBM_ARUSER_WIDTH $ad_project_params(AXI_HBM_ARUSER_WIDTH)
set AXI_HBM_RUSER_ENABLE $ad_project_params(AXI_HBM_RUSER_ENABLE)
set AXI_HBM_RUSER_WIDTH $ad_project_params(AXI_HBM_RUSER_WIDTH)
set AXI_HBM_MAX_BURST_LEN $ad_project_params(AXI_HBM_MAX_BURST_LEN)
set AXI_HBM_NARROW_BURST $ad_project_params(AXI_HBM_NARROW_BURST)
set AXI_HBM_FIXED_BURST $ad_project_params(AXI_HBM_FIXED_BURST)
set AXI_HBM_WRAP_BURST $ad_project_params(AXI_HBM_WRAP_BURST)
set APP_ENABLE $ad_project_params(APP_ENABLE)
set APP_ID $ad_project_params(APP_ID)
set APP_CTRL_ENABLE $ad_project_params(APP_CTRL_ENABLE)
set APP_DMA_ENABLE $ad_project_params(APP_DMA_ENABLE)
set APP_AXIS_DIRECT_ENABLE $ad_project_params(APP_AXIS_DIRECT_ENABLE)
set APP_AXIS_SYNC_ENABLE $ad_project_params(APP_AXIS_SYNC_ENABLE)
set APP_AXIS_IF_ENABLE $ad_project_params(APP_AXIS_IF_ENABLE)
set APP_STAT_ENABLE $ad_project_params(APP_STAT_ENABLE)
set APP_GPIO_IN_WIDTH $ad_project_params(APP_GPIO_IN_WIDTH)
set APP_GPIO_OUT_WIDTH $ad_project_params(APP_GPIO_OUT_WIDTH)
set AXI_DATA_WIDTH $ad_project_params(AXI_DATA_WIDTH)
set AXI_ADDR_WIDTH $ad_project_params(AXI_ADDR_WIDTH)
set AXI_STRB_WIDTH $ad_project_params(AXI_STRB_WIDTH)
set AXI_ID_WIDTH $ad_project_params(AXI_ID_WIDTH)
set DMA_IMM_ENABLE $ad_project_params(DMA_IMM_ENABLE)
set DMA_IMM_WIDTH $ad_project_params(DMA_IMM_WIDTH)
set DMA_LEN_WIDTH $ad_project_params(DMA_LEN_WIDTH)
set DMA_TAG_WIDTH $ad_project_params(DMA_TAG_WIDTH)
set RAM_ADDR_WIDTH $ad_project_params(RAM_ADDR_WIDTH)
set RAM_PIPELINE $ad_project_params(RAM_PIPELINE)
set AXI_DMA_MAX_BURST_LEN $ad_project_params(AXI_DMA_MAX_BURST_LEN)
set AXI_DMA_READ_USE_ID $ad_project_params(AXI_DMA_READ_USE_ID)
set AXI_DMA_WRITE_USE_ID $ad_project_params(AXI_DMA_WRITE_USE_ID)
set AXI_DMA_READ_OP_TABLE_SIZE $ad_project_params(AXI_DMA_READ_OP_TABLE_SIZE)
set AXI_DMA_WRITE_OP_TABLE_SIZE $ad_project_params(AXI_DMA_WRITE_OP_TABLE_SIZE)
set IRQ_COUNT $ad_project_params(IRQ_COUNT)
set AXIL_CTRL_DATA_WIDTH $ad_project_params(AXIL_CTRL_DATA_WIDTH)
set AXIL_CTRL_ADDR_WIDTH $ad_project_params(AXIL_CTRL_ADDR_WIDTH)
set AXIL_CTRL_STRB_WIDTH $ad_project_params(AXIL_CTRL_STRB_WIDTH)
set AXIL_IF_CTRL_ADDR_WIDTH $ad_project_params(AXIL_IF_CTRL_ADDR_WIDTH)
set AXIL_CSR_ADDR_WIDTH $ad_project_params(AXIL_CSR_ADDR_WIDTH)
set AXIL_CSR_PASSTHROUGH_ENABLE $ad_project_params(AXIL_CSR_PASSTHROUGH_ENABLE)
set RB_NEXT_PTR $ad_project_params(RB_NEXT_PTR)
set AXIL_APP_CTRL_DATA_WIDTH $ad_project_params(AXIL_APP_CTRL_DATA_WIDTH)
set AXIL_APP_CTRL_ADDR_WIDTH $ad_project_params(AXIL_APP_CTRL_ADDR_WIDTH)
set AXIL_APP_CTRL_STRB_WIDTH $ad_project_params(AXIL_APP_CTRL_STRB_WIDTH)
set AXIS_DATA_WIDTH $ad_project_params(AXIS_DATA_WIDTH)
set AXIS_KEEP_WIDTH $ad_project_params(AXIS_KEEP_WIDTH)
set AXIS_SYNC_DATA_WIDTH $ad_project_params(AXIS_SYNC_DATA_WIDTH)
set AXIS_IF_DATA_WIDTH $ad_project_params(AXIS_IF_DATA_WIDTH)
set AXIS_TX_USER_WIDTH $ad_project_params(AXIS_TX_USER_WIDTH)
set AXIS_RX_USER_WIDTH $ad_project_params(AXIS_RX_USER_WIDTH)
set AXIS_RX_USE_READY $ad_project_params(AXIS_RX_USE_READY)
set AXIS_TX_PIPELINE $ad_project_params(AXIS_TX_PIPELINE)
set AXIS_TX_FIFO_PIPELINE $ad_project_params(AXIS_TX_FIFO_PIPELINE)
set AXIS_TX_TS_PIPELINE $ad_project_params(AXIS_TX_TS_PIPELINE)
set AXIS_RX_PIPELINE $ad_project_params(AXIS_RX_PIPELINE)
set AXIS_RX_FIFO_PIPELINE $ad_project_params(AXIS_RX_FIFO_PIPELINE)
set STAT_ENABLE $ad_project_params(STAT_ENABLE)
set STAT_DMA_ENABLE $ad_project_params(STAT_DMA_ENABLE)
set STAT_AXI_ENABLE $ad_project_params(STAT_AXI_ENABLE)
set STAT_INC_WIDTH $ad_project_params(STAT_INC_WIDTH)
set STAT_ID_WIDTH $ad_project_params(STAT_ID_WIDTH)
set DMA_ADDR_WIDTH_APP $ad_project_params(DMA_ADDR_WIDTH_APP)
set RAM_SEL_WIDTH_APP $ad_project_params(RAM_SEL_WIDTH_APP)
set RAM_SEG_COUNT_APP $ad_project_params(RAM_SEG_COUNT_APP)
set RAM_SEG_DATA_WIDTH_APP $ad_project_params(RAM_SEG_DATA_WIDTH_APP)
set RAM_SEG_BE_WIDTH_APP $ad_project_params(RAM_SEG_BE_WIDTH_APP)
set RAM_SEG_ADDR_WIDTH_APP $ad_project_params(RAM_SEG_ADDR_WIDTH_APP)
set AXIS_SYNC_KEEP_WIDTH_APP $ad_project_params(AXIS_SYNC_KEEP_WIDTH_APP)
set AXIS_SYNC_TX_USER_WIDTH_APP $ad_project_params(AXIS_SYNC_TX_USER_WIDTH_APP)
set AXIS_SYNC_RX_USER_WIDTH_APP $ad_project_params(AXIS_SYNC_RX_USER_WIDTH_APP)
set AXIS_IF_KEEP_WIDTH_APP $ad_project_params(AXIS_IF_KEEP_WIDTH_APP)
set AXIS_IF_TX_ID_WIDTH_APP $ad_project_params(AXIS_IF_TX_ID_WIDTH_APP)
set AXIS_IF_RX_ID_WIDTH_APP $ad_project_params(AXIS_IF_RX_ID_WIDTH_APP)
set AXIS_IF_TX_DEST_WIDTH_APP $ad_project_params(AXIS_IF_TX_DEST_WIDTH_APP)
set AXIS_IF_RX_DEST_WIDTH_APP $ad_project_params(AXIS_IF_RX_DEST_WIDTH_APP)
set AXIS_IF_TX_USER_WIDTH_APP $ad_project_params(AXIS_IF_TX_USER_WIDTH_APP)
set AXIS_IF_RX_USER_WIDTH_APP $ad_project_params(AXIS_IF_RX_USER_WIDTH_APP)
set TDMA_BER_ENABLE $ad_project_params(TDMA_BER_ENABLE)
set QSFP_CNT $ad_project_params(QSFP_CNT)
set PORT_MASK $ad_project_params(PORT_MASK)
set ETH_RX_CLK_FROM_TX $ad_project_params(ETH_RX_CLK_FROM_TX)
set ETH_RS_FEC_ENABLE $ad_project_params(ETH_RS_FEC_ENABLE)
set DMA_ADDR_WIDTH $ad_project_params(DMA_ADDR_WIDTH)
set RAM_SEL_WIDTH $ad_project_params(RAM_SEL_WIDTH)
set RAM_SEG_COUNT $ad_project_params(RAM_SEG_COUNT)
set RAM_SEG_DATA_WIDTH $ad_project_params(RAM_SEG_DATA_WIDTH)
set RAM_SEG_BE_WIDTH $ad_project_params(RAM_SEG_BE_WIDTH)
set RAM_SEG_ADDR_WIDTH $ad_project_params(RAM_SEG_ADDR_WIDTH)
set AXIS_SYNC_KEEP_WIDTH $ad_project_params(AXIS_SYNC_KEEP_WIDTH)
set AXIS_SYNC_TX_USER_WIDTH $ad_project_params(AXIS_SYNC_TX_USER_WIDTH)
set AXIS_SYNC_RX_USER_WIDTH $ad_project_params(AXIS_SYNC_RX_USER_WIDTH)
set AXIS_IF_KEEP_WIDTH $ad_project_params(AXIS_IF_KEEP_WIDTH)
set AXIS_IF_TX_ID_WIDTH $ad_project_params(AXIS_IF_TX_ID_WIDTH)
set AXIS_IF_RX_ID_WIDTH $ad_project_params(AXIS_IF_RX_ID_WIDTH)
set AXIS_IF_TX_DEST_WIDTH $ad_project_params(AXIS_IF_TX_DEST_WIDTH)
set AXIS_IF_RX_DEST_WIDTH $ad_project_params(AXIS_IF_RX_DEST_WIDTH)
set AXIS_IF_TX_USER_WIDTH $ad_project_params(AXIS_IF_TX_USER_WIDTH)
set AXIS_IF_RX_USER_WIDTH $ad_project_params(AXIS_IF_RX_USER_WIDTH)
set INPUT_CHANNELS $ad_project_params(INPUT_CHANNELS)
set INPUT_SAMPLES_PER_CHANNEL $ad_project_params(INPUT_SAMPLES_PER_CHANNEL)
set INPUT_SAMPLE_DATA_WIDTH $ad_project_params(INPUT_SAMPLE_DATA_WIDTH)
set OUTPUT_WIDTH $ad_project_params(OUTPUT_WIDTH)
set OUTPUT_CHANNELS $ad_project_params(OUTPUT_CHANNELS)

set INPUT_WIDTH [expr $INPUT_CHANNELS*$INPUT_SAMPLES_PER_CHANNEL*$INPUT_SAMPLE_DATA_WIDTH]

ad_ip_instance application_core application_core [list \
  IF_COUNT $IF_COUNT \
  PORTS_PER_IF $PORTS_PER_IF \
  PTP_PEROUT_COUNT $PTP_PEROUT_COUNT \
  PTP_TS_ENABLE $PTP_TS_ENABLE \
  PTP_TS_FMT_TOD $PTP_TS_FMT_TOD \
  PTP_TS_WIDTH $PTP_TS_WIDTH \
  TX_TAG_WIDTH $TX_TAG_WIDTH \
  DDR_CH $DDR_CH \
  AXI_DDR_DATA_WIDTH $AXI_DDR_DATA_WIDTH \
  AXI_DDR_ADDR_WIDTH $AXI_DDR_ADDR_WIDTH \
  AXI_DDR_STRB_WIDTH $AXI_DDR_STRB_WIDTH \
  AXI_DDR_ID_WIDTH $AXI_DDR_ID_WIDTH \
  AXI_DDR_AWUSER_ENABLE $AXI_DDR_AWUSER_ENABLE \
  AXI_DDR_WUSER_ENABLE $AXI_DDR_WUSER_ENABLE \
  AXI_DDR_BUSER_ENABLE $AXI_DDR_BUSER_ENABLE \
  AXI_DDR_ARUSER_ENABLE $AXI_DDR_ARUSER_ENABLE \
  AXI_DDR_RUSER_ENABLE $AXI_DDR_RUSER_ENABLE \
  HBM_CH $HBM_CH \
  AXI_HBM_DATA_WIDTH $AXI_HBM_DATA_WIDTH \
  AXI_HBM_ADDR_WIDTH $AXI_HBM_ADDR_WIDTH \
  AXI_HBM_STRB_WIDTH $AXI_HBM_STRB_WIDTH \
  AXI_HBM_ID_WIDTH $AXI_HBM_ID_WIDTH \
  AXI_HBM_AWUSER_ENABLE $AXI_HBM_AWUSER_ENABLE \
  AXI_HBM_AWUSER_WIDTH $AXI_HBM_AWUSER_WIDTH \
  AXI_HBM_WUSER_ENABLE $AXI_HBM_WUSER_ENABLE \
  AXI_HBM_WUSER_WIDTH $AXI_HBM_WUSER_WIDTH \
  AXI_HBM_BUSER_ENABLE $AXI_HBM_BUSER_ENABLE \
  AXI_HBM_BUSER_WIDTH $AXI_HBM_BUSER_WIDTH \
  AXI_HBM_ARUSER_ENABLE $AXI_HBM_ARUSER_ENABLE \
  AXI_HBM_ARUSER_WIDTH $AXI_HBM_ARUSER_WIDTH \
  AXI_HBM_RUSER_ENABLE $AXI_HBM_RUSER_ENABLE \
  AXI_HBM_RUSER_WIDTH $AXI_HBM_RUSER_WIDTH \
  APP_ID $APP_ID \
  APP_GPIO_IN_WIDTH $APP_GPIO_IN_WIDTH \
  APP_GPIO_OUT_WIDTH $APP_GPIO_OUT_WIDTH \
  DMA_ADDR_WIDTH $DMA_ADDR_WIDTH \
  DMA_IMM_WIDTH $DMA_IMM_WIDTH \
  DMA_LEN_WIDTH $DMA_LEN_WIDTH \
  DMA_TAG_WIDTH $DMA_TAG_WIDTH \
  RAM_SEL_WIDTH $RAM_SEL_WIDTH \
  RAM_ADDR_WIDTH $RAM_ADDR_WIDTH \
  RAM_SEG_COUNT $RAM_SEG_COUNT \
  RAM_SEG_DATA_WIDTH $RAM_SEG_DATA_WIDTH \
  RAM_SEG_BE_WIDTH $RAM_SEG_BE_WIDTH \
  RAM_SEG_ADDR_WIDTH $RAM_SEG_ADDR_WIDTH \
  AXIL_CTRL_DATA_WIDTH $AXIL_CTRL_DATA_WIDTH \
  AXIL_CTRL_ADDR_WIDTH $AXIL_CTRL_ADDR_WIDTH \
  AXIL_CTRL_STRB_WIDTH $AXIL_CTRL_STRB_WIDTH \
  AXIS_DATA_WIDTH $AXIS_DATA_WIDTH \
  AXIS_KEEP_WIDTH $AXIS_KEEP_WIDTH \
  AXIS_TX_USER_WIDTH $AXIS_TX_USER_WIDTH \
  AXIS_RX_USER_WIDTH $AXIS_RX_USER_WIDTH \
  AXIS_SYNC_DATA_WIDTH $AXIS_SYNC_DATA_WIDTH \
  AXIS_SYNC_KEEP_WIDTH $AXIS_SYNC_KEEP_WIDTH \
  AXIS_SYNC_TX_USER_WIDTH $AXIS_SYNC_TX_USER_WIDTH \
  AXIS_SYNC_RX_USER_WIDTH $AXIS_SYNC_RX_USER_WIDTH \
  AXIS_IF_DATA_WIDTH $AXIS_IF_DATA_WIDTH \
  AXIS_IF_KEEP_WIDTH $AXIS_IF_KEEP_WIDTH \
  AXIS_IF_TX_ID_WIDTH $AXIS_IF_TX_ID_WIDTH \
  AXIS_IF_RX_ID_WIDTH $AXIS_IF_RX_ID_WIDTH \
  AXIS_IF_TX_DEST_WIDTH $AXIS_IF_TX_DEST_WIDTH \
  AXIS_IF_RX_DEST_WIDTH $AXIS_IF_RX_DEST_WIDTH \
  AXIS_IF_TX_USER_WIDTH $AXIS_IF_TX_USER_WIDTH \
  AXIS_IF_RX_USER_WIDTH $AXIS_IF_RX_USER_WIDTH \
  STAT_INC_WIDTH $STAT_INC_WIDTH \
  STAT_ID_WIDTH $STAT_ID_WIDTH \
  INPUT_CHANNELS $INPUT_CHANNELS \
  INPUT_SAMPLES_PER_CHANNEL $INPUT_SAMPLES_PER_CHANNEL \
  INPUT_SAMPLE_DATA_WIDTH $INPUT_SAMPLE_DATA_WIDTH \
  OUTPUT_WIDTH $OUTPUT_WIDTH \
  OUTPUT_CHANNELS $OUTPUT_CHANNELS \
]

ad_ip_instance clk_vip corundum_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "CORUNDUM_CLK_VIP=corundum_clk_vip"

ad_connect corundum_clk corundum_clk_vip/clk_out

ad_ip_instance proc_sys_reset corundum_rstgen
ad_ip_parameter corundum_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_connect sys_rst_vip/rst_out corundum_rstgen/ext_reset_in
ad_connect corundum_clk corundum_rstgen/slowest_sync_clk
ad_connect corundum_reset corundum_rstgen/peripheral_reset
ad_connect corundum_resetn corundum_rstgen/peripheral_aresetn

ad_ip_instance clk_vip input_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 300000000 \
]
adi_sim_add_define "INPUT_CLK_VIP=input_clk_vip"

ad_connect input_clk input_clk_vip/clk_out

ad_ip_instance proc_sys_reset input_rstgen
ad_ip_parameter input_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_connect sys_rst_vip/rst_out input_rstgen/ext_reset_in
ad_connect input_clk input_rstgen/slowest_sync_clk
ad_connect input_reset input_rstgen/peripheral_reset
ad_connect input_resetn input_rstgen/peripheral_aresetn

ad_ip_instance io_vip enable_io_vip [list \
  MODE {Driver} \
  WIDTH $INPUT_CHANNELS \
]
adi_sim_add_define "EN_IO=enable_io_vip"

ad_ip_instance axi4stream_vip jesd_tx_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY 0 \
  HAS_TLAST 0 \
  HAS_TKEEP 0 \
  TDATA_NUM_BYTES [expr $INPUT_WIDTH/8] \
  TDEST_WIDTH 0 \
  TID_WIDTH 0 \
]
adi_sim_add_define "JESD_TX_AXIS=jesd_tx_axis"

ad_connect input_clk jesd_tx_axis/aclk
ad_connect input_resetn jesd_tx_axis/aresetn

ad_ip_instance axi4stream_vip os_tx_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY 1 \
  HAS_TLAST 1 \
  HAS_TKEEP 1 \
  TDATA_NUM_BYTES 64 \
  TDEST_WIDTH 0 \
  TID_WIDTH 0 \
]
adi_sim_add_define "OS_TX_AXIS=os_tx_axis"

ad_connect corundum_clk os_tx_axis/aclk
ad_connect corundum_resetn os_tx_axis/aresetn

ad_ip_instance axi4stream_vip jesd_rx_axis [list \
  INTERFACE_MODE {SLAVE} \
]
adi_sim_add_define "JESD_RX_AXIS=jesd_rx_axis"

ad_connect input_clk jesd_rx_axis/aclk
ad_connect input_resetn jesd_rx_axis/aresetn

ad_ip_instance axi4stream_vip os_rx_axis [list \
  INTERFACE_MODE {SLAVE} \
]
adi_sim_add_define "OS_RX_AXIS=os_rx_axis"

ad_connect corundum_clk os_rx_axis/aclk
ad_connect corundum_resetn os_rx_axis/aresetn

ad_ip_instance util_cpack2 input_cpack [ list \
  NUM_OF_CHANNELS $INPUT_CHANNELS \
  SAMPLE_DATA_WIDTH $INPUT_SAMPLE_DATA_WIDTH \
  SAMPLES_PER_CHANNEL $INPUT_SAMPLES_PER_CHANNEL \
]

ad_connect input_cpack/clk input_clk
ad_connect input_cpack/reset input_reset

create_bd_cell -type hier slicer_hier

create_bd_pin -dir I -from [expr {$INPUT_CHANNELS-1}] -to 0 slicer_hier/input_enable
create_bd_pin -dir I -from [expr {$INPUT_WIDTH-1}] -to 0 slicer_hier/input_data

ad_connect enable_io_vip/out slicer_hier/input_enable
ad_connect jesd_tx_axis/m_axis_tdata slicer_hier/input_data

for {set i 0} {$i < $INPUT_CHANNELS} {incr i} {
  create_bd_pin -dir O slicer_hier/input_enable_${i}
  create_bd_pin -dir O -from [expr {$INPUT_WIDTH/$INPUT_CHANNELS-1}] -to 0 slicer_hier/input_data_${i}

  ad_ip_instance xlslice slicer_hier/enable_slice_${i} [list \
    DIN_WIDTH $INPUT_CHANNELS \
    DIN_FROM $i \
    DIN_TO $i \
    DOUT_WIDTH 1 \
  ]

  ad_connect slicer_hier/input_enable slicer_hier/enable_slice_${i}/Din
  ad_connect slicer_hier/enable_slice_${i}/Dout slicer_hier/input_enable_${i}
  ad_connect slicer_hier/input_enable_${i} input_cpack/enable_${i}

  ad_ip_instance xlslice slicer_hier/data_slice_${i} [list \
    DIN_WIDTH $INPUT_WIDTH \
    DIN_FROM [expr $INPUT_WIDTH/$INPUT_CHANNELS*($i+1)-1] \
    DIN_TO [expr $INPUT_WIDTH/$INPUT_CHANNELS*$i] \
    DOUT_WIDTH [expr $INPUT_WIDTH/$INPUT_CHANNELS] \
  ]

  ad_connect slicer_hier/input_data slicer_hier/data_slice_${i}/Din
  ad_connect slicer_hier/data_slice_${i}/Dout slicer_hier/input_data_${i}
  ad_connect slicer_hier/input_data_${i} input_cpack/fifo_wr_data_${i}
}

ad_connect input_cpack/fifo_wr_en jesd_tx_axis/m_axis_tvalid

# Application connections

ad_connect application_core/clk corundum_clk
ad_connect application_core/rst corundum_reset
ad_connect application_core/ptp_clk corundum_clk
ad_connect application_core/ptp_rst corundum_reset
ad_connect application_core/ptp_sample_clk corundum_clk
ad_connect application_core/direct_tx_clk corundum_clk
ad_connect application_core/direct_tx_rst corundum_reset
ad_connect application_core/direct_rx_clk corundum_clk
ad_connect application_core/direct_rx_rst corundum_reset

set_property CONFIG.NUM_CLKS {2} [get_bd_cells axi_axi_interconnect]
ad_connect axi_axi_interconnect/aclk1 corundum_clk

ad_cpu_interconnect 0x50000000 application_core

ad_connect application_core/input_axis_tdata input_cpack/packed_fifo_wr_data
ad_connect application_core/input_axis_tvalid input_cpack/packed_fifo_wr_en

ad_connect application_core/s_axis_sync_tx os_tx_axis/M_AXIS
ad_connect application_core/m_axis_sync_tx application_core/s_axis_direct_tx
ad_connect application_core/m_axis_direct_tx application_core/s_axis_direct_rx
ad_connect application_core/m_axis_direct_rx application_core/s_axis_sync_rx
ad_connect application_core/m_axis_sync_rx os_rx_axis/S_AXIS

ad_connect application_core/output_axis jesd_rx_axis/S_AXIS

ad_connect enable_io_vip/clk input_clk
ad_connect enable_io_vip/out application_core/input_enable
ad_connect enable_io_vip/out application_core/output_enable

ad_connect application_core/jtag_tdi GND
ad_connect application_core/jtag_tms GND
ad_connect application_core/jtag_tck GND
ad_connect application_core/gpio_in GND

ad_connect application_core/ddr_clk GND
ad_connect application_core/ddr_rst GND
ad_connect application_core/ddr_status GND

ad_connect application_core/hbm_clk GND
ad_connect application_core/hbm_rst GND
ad_connect application_core/hbm_status GND

ad_connect application_core/input_clk input_clk
ad_connect application_core/input_rstn input_resetn

ad_connect application_core/output_clk input_clk
ad_connect application_core/output_rstn input_resetn
