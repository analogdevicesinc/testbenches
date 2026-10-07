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

# Get VIP configuration parameters
set DATA_WIDTH $ad_project_params(DATA_WIDTH)
set TKEEP_EN $ad_project_params(TKEEP_EN)
set TSTRB_EN $ad_project_params(TSTRB_EN)
set TLAST_EN $ad_project_params(TLAST_EN)
set TUSER_EN $ad_project_params(TUSER_EN)
set TID_EN $ad_project_params(TID_EN)
set TDEST_EN $ad_project_params(TDEST_EN)
set TUSER_WIDTH $ad_project_params(TUSER_WIDTH)
set TID_WIDTH $ad_project_params(TID_WIDTH)
set TDEST_WIDTH $ad_project_params(TDEST_WIDTH)

ad_ip_instance axi4stream_vip src_axis [list \
  INTERFACE_MODE {MASTER} \
  TDATA_NUM_BYTES [expr {$DATA_WIDTH/8}] \
  HAS_TREADY 1 \
  HAS_TKEEP $TKEEP_EN \
  HAS_TSTRB $TSTRB_EN \
  HAS_TLAST $TLAST_EN \
  TUSER_WIDTH [expr $TUSER_WIDTH * $TUSER_EN] \
  TID_WIDTH [expr $TID_WIDTH * $TID_EN] \
  TDEST_WIDTH [expr $TDEST_WIDTH * $TDEST_EN] \
]
adi_sim_add_define "SRC_AXIS=src_axis"

ad_connect sys_dma_clk src_axis/aclk
ad_connect sys_dma_resetn src_axis/aresetn

ad_ip_instance axi4stream_vip dst_axis [list \
  INTERFACE_MODE {SLAVE} \
  TDATA_NUM_BYTES [expr {$DATA_WIDTH/8}] \
  HAS_TKEEP $TKEEP_EN \
  HAS_TSTRB $TSTRB_EN \
  HAS_TLAST $TLAST_EN \
  TUSER_WIDTH [expr $TUSER_WIDTH * $TUSER_EN] \
  TID_WIDTH [expr $TID_WIDTH * $TID_EN] \
  TDEST_WIDTH [expr $TDEST_WIDTH * $TDEST_EN] \
]
adi_sim_add_define "DST_AXIS=dst_axis"

ad_connect sys_dma_clk dst_axis/aclk
ad_connect sys_dma_resetn dst_axis/aresetn

ad_connect src_axis/m_axis dst_axis/s_axis
