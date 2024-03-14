# ***************************************************************************
# ***************************************************************************
# Copyright 2022 (c) Analog Devices, Inc. All rights reserved.
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

global ad_hdl_dir

source ../../scripts/adi_env.tcl

global ad_project_params

ad_ip_instance axi4stream_vip src_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY 1 \
  HAS_TLAST 1 \
  TDATA_NUM_BYTES 4 \
  TDEST_WIDTH 0 \
  TID_WIDTH 0 \
]
adi_sim_add_define "SRC_AXIS=src_axis"

ad_connect sys_dma_clk src_axis/aclk
ad_connect sys_dma_resetn src_axis/aresetn

ad_ip_instance axi4stream_vip dst_axis [list \
  INTERFACE_MODE {SLAVE} \
]
adi_sim_add_define "DST_AXIS=dst_axis"

ad_connect sys_dma_clk dst_axis/aclk
ad_connect sys_dma_resetn dst_axis/aresetn

ad_connect src_axis/m_axis dst_axis/s_axis
