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

source ../../../../scripts/adi_env.tcl

# system level parameters
global ad_project_params

set INPUT_WIDTH $ad_project_params(INPUT_WIDTH)
set OUTPUT_WIDTH $ad_project_params(OUTPUT_WIDTH)
set FIFO_LIMITED $ad_project_params(FIFO_LIMITED)
set ADDRESS_WIDTH $ad_project_params(ADDRESS_WIDTH)

# input clock and reset
create_bd_port -dir I input_clk

# output clock and reset
create_bd_port -dir I output_clk


ad_ip_instance util_axis_fifo_asym util_axis_fifo_asym_DUT [list \
  ASYNC_CLK 1 \
  S_DATA_WIDTH $INPUT_WIDTH \
  ADDRESS_WIDTH $ADDRESS_WIDTH \
  M_DATA_WIDTH $OUTPUT_WIDTH \
  M_AXIS_REGISTERED 1 \
  ALMOST_EMPTY_THRESHOLD 16 \
  ALMOST_FULL_THRESHOLD 16 \
  TLAST_EN 1 \
  TKEEP_EN 1 \
  FIFO_LIMITED $FIFO_LIMITED \
  ADDRESS_WIDTH_PERSPECTIVE 0 \
]

ad_connect input_clk util_axis_fifo_asym_DUT/s_axis_aclk
ad_connect sys_cpu_resetn util_axis_fifo_asym_DUT/s_axis_aresetn

ad_connect output_clk util_axis_fifo_asym_DUT/m_axis_aclk
ad_connect sys_cpu_resetn util_axis_fifo_asym_DUT/m_axis_aresetn
  
ad_ip_instance axi4stream_vip input_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY {1} \
  HAS_TLAST {1} \
  HAS_TKEEP {1} \
  TDATA_NUM_BYTES [expr {$INPUT_WIDTH/8}] \
]
adi_sim_add_define "INPUT_AXIS=input_axis"

ad_connect input_clk input_axis/aclk
ad_connect sys_cpu_resetn input_axis/aresetn

ad_connect util_axis_fifo_asym_DUT/s_axis input_axis/m_axis

ad_ip_instance axi4stream_vip output_axis [list \
  INTERFACE_MODE {SLAVE} \
  TDATA_NUM_BYTES [expr {$OUTPUT_WIDTH/8}] \
  HAS_TLAST {1} \
]
adi_sim_add_define "OUTPUT_AXIS=output_axis"

ad_connect output_clk output_axis/aclk
ad_connect sys_cpu_resetn output_axis/aresetn

ad_connect util_axis_fifo_asym_DUT/m_axis output_axis/s_axis
