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

set ASYNC_CLK $ad_project_params(ASYNC_CLK)
set TKEEP_EN $ad_project_params(TKEEP_EN)
set TLAST_EN $ad_project_params(TLAST_EN)
set DATA_WIDTH $ad_project_params(DATA_WIDTH)
set ADDRESS_WIDTH $ad_project_params(ADDRESS_WIDTH)
set INPUT_CLK $ad_project_params(INPUT_CLK)
set OUTPUT_CLK $ad_project_params(OUTPUT_CLK)

# Input clock
ad_ip_instance clk_vip input_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ [expr pow(10, 9)/$INPUT_CLK] \
]
adi_sim_add_define "INPUT_CLK_VIP=input_clk_vip"

ad_ip_instance clk_vip output_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ [expr pow(10, 9)/$OUTPUT_CLK] \
]
adi_sim_add_define "OUTPUT_CLK_VIP=output_clk_vip"

ad_connect input_clk input_clk_vip/clk_out
ad_connect output_clk output_clk_vip/clk_out

ad_ip_instance proc_sys_reset input_rstgen
ad_ip_parameter input_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_ip_instance proc_sys_reset output_rstgen
ad_ip_parameter output_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_connect sys_rst_vip/rst_out input_rstgen/ext_reset_in
ad_connect sys_rst_vip/rst_out output_rstgen/ext_reset_in

ad_connect input_clk input_rstgen/slowest_sync_clk
ad_connect output_clk output_rstgen/slowest_sync_clk

ad_connect input_resetn input_rstgen/peripheral_aresetn
ad_connect output_resetn output_rstgen/peripheral_aresetn

ad_ip_instance util_axis_fifo util_axis_fifo_DUT [list \
  ASYNC_CLK $ASYNC_CLK \
  DATA_WIDTH $DATA_WIDTH \
  ADDRESS_WIDTH $ADDRESS_WIDTH \
  M_AXIS_REGISTERED 1 \
  ALMOST_EMPTY_THRESHOLD 0 \
  ALMOST_FULL_THRESHOLD 0 \
  TLAST_EN $TLAST_EN \
  TKEEP_EN $TKEEP_EN \
  REMOVE_NULL_BEAT_EN 0 \
]

ad_connect input_clk util_axis_fifo_DUT/s_axis_aclk
ad_connect input_resetn util_axis_fifo_DUT/s_axis_aresetn

ad_connect output_clk util_axis_fifo_DUT/m_axis_aclk
ad_connect output_resetn util_axis_fifo_DUT/m_axis_aresetn

ad_ip_instance axi4stream_vip input_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY {1} \
  TDEST_WIDTH {0} \
  TID_WIDTH {0} \
  HAS_TLAST $TLAST_EN \
  HAS_TKEEP $TKEEP_EN \
  TDATA_NUM_BYTES [expr {$DATA_WIDTH/8}] \
]
adi_sim_add_define "INPUT_AXIS=input_axis"

ad_connect input_clk input_axis/aclk
ad_connect input_resetn input_axis/aresetn

ad_connect util_axis_fifo_DUT/s_axis input_axis/m_axis

ad_ip_instance axi4stream_vip output_axis [list \
  INTERFACE_MODE {SLAVE} \
  HAS_TLAST $TLAST_EN \
  HAS_TKEEP $TKEEP_EN \
  TDATA_NUM_BYTES [expr {$DATA_WIDTH/8}] \
]
adi_sim_add_define "OUTPUT_AXIS=output_axis"

ad_connect output_clk output_axis/aclk
ad_connect output_resetn output_axis/aresetn

ad_connect util_axis_fifo_DUT/m_axis output_axis/s_axis
