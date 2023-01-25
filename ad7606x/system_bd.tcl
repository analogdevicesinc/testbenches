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

source ../../scripts/adi_env.tcl

# system level parameters
set DEV_CONFIG  $ad_project_params(DEV_CONFIG)
set EXT_CLK $ad_project_params(EXT_CLK)

global ad_project_params

adi_project_files [list \
	"../../library/common/ad_edge_detect.v" \
	"../../library/util_cdc/sync_bits.v"]

#
#  Block design under test
#

source ../../projects/ad7606x_fmc/common/ad7606x_bd.tcl

create_bd_port -dir O sys_clk

ad_connect sys_clk sys_cpu_clk

ad_ip_parameter axi_ad7606x CONFIG.DEV_CONFIG $DEV_CONFIG
ad_ip_parameter axi_ad7606x CONFIG.EXT_CLK $EXT_CLK
