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
set TSTRB_EN $ad_project_params(TSTRB_EN)
set TID_WIDTH $ad_project_params(TID_WIDTH)
set TDEST_WIDTH $ad_project_params(TDEST_WIDTH)
set INPUT_WIDTH $ad_project_params(INPUT_WIDTH)
set OUTPUT_WIDTH $ad_project_params(OUTPUT_WIDTH)
set TUSER_BITS_PER_BYTE $ad_project_params(TUSER_BITS_PER_BYTE)
set TUSER_WIDTH $ad_project_params(TUSER_WIDTH)
set REDUCED_FIFO $ad_project_params(REDUCED_FIFO)
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
if {$ASYNC_CLK} {
  ad_connect output_clk output_clk_vip/clk_out
  set output_clk output_clk
} else {
  set output_clk input_clk
}

ad_ip_instance proc_sys_reset input_rstgen
ad_ip_parameter input_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_ip_instance proc_sys_reset output_rstgen
ad_ip_parameter output_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_connect sys_rst_vip/rst_out input_rstgen/ext_reset_in
ad_connect sys_rst_vip/rst_out output_rstgen/ext_reset_in

ad_connect input_clk input_rstgen/slowest_sync_clk
ad_connect $output_clk output_rstgen/slowest_sync_clk

ad_connect input_resetn input_rstgen/peripheral_aresetn
ad_connect output_resetn output_rstgen/peripheral_aresetn

ad_ip_instance util_axis_fifo_asym util_axis_fifo_asym_DUT [list \
  ADDRESS_WIDTH $ADDRESS_WIDTH \
  M_AXIS_REGISTERED 1 \
  ALMOST_EMPTY_THRESHOLD 0 \
  ALMOST_FULL_THRESHOLD 0 \
  REDUCED_FIFO $REDUCED_FIFO \
]

ad_connect input_clk util_axis_fifo_asym_DUT/s_axis_aclk
ad_connect input_resetn util_axis_fifo_asym_DUT/s_axis_aresetn

ad_connect $output_clk util_axis_fifo_asym_DUT/m_axis_aclk
ad_connect output_resetn util_axis_fifo_asym_DUT/m_axis_aresetn

ad_ip_instance axi4stream_vip input_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY {1} \
  TDEST_WIDTH $TDEST_WIDTH \
  TID_WIDTH $TID_WIDTH \
  TUSER_WIDTH $TUSER_WIDTH \
  HAS_TLAST $TLAST_EN \
  HAS_TKEEP $TKEEP_EN \
  HAS_TSTRB $TSTRB_EN \
  TDATA_NUM_BYTES [expr {$INPUT_WIDTH/8}] \
]
adi_sim_add_define "INPUT_AXIS=input_axis"

ad_connect input_clk input_axis/aclk
ad_connect input_resetn input_axis/aresetn

ad_connect util_axis_fifo_asym_DUT/s_axis input_axis/m_axis

ad_ip_instance axi4stream_vip output_axis [list \
  INTERFACE_MODE {SLAVE} \
  HAS_TREADY {1} \
  TDEST_WIDTH $TDEST_WIDTH \
  TID_WIDTH $TID_WIDTH \
  TUSER_WIDTH $TUSER_WIDTH \
  HAS_TLAST $TLAST_EN \
  HAS_TKEEP $TKEEP_EN \
  HAS_TSTRB $TSTRB_EN \
  TDATA_NUM_BYTES [expr {$OUTPUT_WIDTH/8}] \
]
adi_sim_add_define "OUTPUT_AXIS=output_axis"

ad_connect $output_clk output_axis/aclk
ad_connect output_resetn output_axis/aresetn

ad_connect util_axis_fifo_asym_DUT/m_axis output_axis/s_axis
