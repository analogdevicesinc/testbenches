# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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

proc log2 {x} {
  return [expr {log($x) / log(2)}]
}

set CHANNELS $ad_project_params(CHANNELS)
set SAMPLES $ad_project_params(SAMPLES)
set WIDTH $ad_project_params(WIDTH)
set MAX_WIDTH [expr {2 ** ceil([log2 $CHANNELS]) * $SAMPLES * $WIDTH}]

ad_ip_instance xlconstant VCC [list \
  CONST_VAL 1 \
]
ad_connect vcc VCC/dout

# Create CPack configuration
ad_ip_instance axi_dmac dmac_tx [list \
  DMA_TYPE_SRC 2 \
  DMA_TYPE_DEST 1 \
  ID 0 \
  FIFO_SIZE 4 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  MAX_BYTES_PER_BURST 4096 \
  CYCLIC 1 \
  DMA_DATA_WIDTH_SRC $MAX_WIDTH \
  DMA_DATA_WIDTH_DEST $MAX_WIDTH \
]

ad_connect sys_cpu_clk dmac_tx/m_axis_aclk
ad_connect sys_cpu_clk dmac_tx/fifo_wr_clk

set BA 0x50010000
ad_cpu_interconnect ${BA} dmac_tx
adi_sim_add_define "TX_DMA_BA=[format "%d" ${BA}]"

ad_ip_instance axi4stream_vip tx_src_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY {0} \
  HAS_TLAST {0} \
  HAS_TKEEP {0} \
  TDATA_NUM_BYTES [expr {$CHANNELS * $SAMPLES * $WIDTH / 8}] \
]
adi_sim_add_define "TX_SRC_AXIS=tx_src_axis"

ad_connect sys_cpu_clk tx_src_axis/aclk
ad_connect sys_cpu_resetn tx_src_axis/aresetn

ad_ip_instance axi4stream_vip tx_dst_axis [list \
  INTERFACE_MODE {SLAVE} \
  TDATA_NUM_BYTES [expr $MAX_WIDTH / 8] \
]
adi_sim_add_define "TX_DST_AXIS=tx_dst_axis"

ad_connect sys_cpu_clk tx_dst_axis/aclk
ad_connect sys_cpu_resetn tx_dst_axis/aresetn

ad_ip_instance util_cpack2 util_cpack2_DUT [list \
  NUM_OF_CHANNELS $CHANNELS \
  SAMPLES_PER_CHANNEL $SAMPLES \
  SAMPLE_DATA_WIDTH $WIDTH \
]

ad_connect sys_cpu_clk util_cpack2_DUT/clk
ad_connect sys_cpu_reset util_cpack2_DUT/reset

ad_connect util_cpack2_DUT/packed_fifo_wr dmac_tx/fifo_wr
ad_connect dmac_tx/m_axis tx_dst_axis/s_axis

for {set i 0} {$i < $CHANNELS} {incr i} {
  ad_ip_instance xlslice tx_data_slice${i} [list \
    DIN_WIDTH $MAX_WIDTH \
    DIN_FROM [expr ($i + 1) * $WIDTH * $SAMPLES - 1] \
    DIN_TO [expr ${i} * $WIDTH * $SAMPLES] \
  ]

  ad_connect tx_src_axis/m_axis_tdata tx_data_slice${i}/Din
  ad_connect tx_data_slice${i}/Dout util_cpack2_DUT/fifo_wr_data_${i}

  ad_connect vcc util_cpack2_DUT/enable_${i}
}

ad_connect tx_src_axis/m_axis_tvalid util_cpack2_DUT/fifo_wr_en

# Create UPack configuration
ad_ip_instance axi_dmac dmac_rx [list \
  DMA_TYPE_SRC 1 \
  DMA_TYPE_DEST 1 \
  ID 0 \
  FIFO_SIZE 4 \
  AXI_SLICE_SRC 1 \
  AXI_SLICE_DEST 1 \
  SYNC_TRANSFER_START 0 \
  DMA_LENGTH_WIDTH 24 \
  DMA_2D_TRANSFER 0 \
  MAX_BYTES_PER_BURST 4096 \
  CYCLIC 0 \
  DMA_DATA_WIDTH_SRC $MAX_WIDTH \
  DMA_DATA_WIDTH_DEST $MAX_WIDTH \
]

ad_connect sys_cpu_clk dmac_rx/s_axis_aclk
ad_connect sys_cpu_clk dmac_rx/m_axis_aclk

set BA 0x50000000
ad_cpu_interconnect ${BA} dmac_rx
adi_sim_add_define "RX_DMA_BA=[format "%d" ${BA}]"

ad_ip_instance axi4stream_vip rx_src_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY {1} \
  HAS_TLAST {1} \
  HAS_TKEEP {1} \
  TDATA_NUM_BYTES [expr {$MAX_WIDTH / 8}] \
]
adi_sim_add_define "RX_SRC_AXIS=rx_src_axis"

ad_connect sys_cpu_clk rx_src_axis/aclk
ad_connect sys_cpu_resetn rx_src_axis/aresetn

ad_ip_instance axi4stream_vip rx_dst_axis [list \
  INTERFACE_MODE {SLAVE} \
  HAS_TREADY {1} \
  TDATA_NUM_BYTES [expr {$CHANNELS * $SAMPLES * $WIDTH / 8}] \
]
adi_sim_add_define "RX_DST_AXIS=rx_dst_axis"

ad_connect sys_cpu_clk rx_dst_axis/aclk
ad_connect sys_cpu_resetn rx_dst_axis/aresetn

ad_ip_instance util_upack2 util_upack2_DUT [list \
  NUM_OF_CHANNELS $CHANNELS \
  SAMPLES_PER_CHANNEL $SAMPLES \
  SAMPLE_DATA_WIDTH $WIDTH \
]

ad_connect sys_cpu_clk util_upack2_DUT/clk
ad_connect sys_cpu_reset util_upack2_DUT/reset

ad_connect util_upack2_DUT/s_axis dmac_rx/m_axis
ad_connect dmac_rx/s_axis rx_src_axis/m_axis

ad_ip_instance xlconcat rx_data_concat [list \
  NUM_PORTS $CHANNELS \
]

for {set i 0} {$i < $CHANNELS} {incr i} {
  ad_connect rx_data_concat/In${i} util_upack2_DUT/fifo_rd_data_${i}
  ad_connect vcc util_upack2_DUT/enable_${i}
}

ad_connect rx_dst_axis/s_axis_tdata rx_data_concat/dout
ad_connect rx_dst_axis/s_axis_tvalid util_upack2_DUT/fifo_rd_valid

ad_connect vcc util_upack2_DUT/fifo_rd_en
