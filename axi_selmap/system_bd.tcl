# ***************************************************************************
# ***************************************************************************
# Copyright 2024 (c) Analog Devices, Inc. All rights reserved.
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

#  ------------------
#
# Blocks under test
#
#  ------------------

global selmap_cfg
ad_ip_instance axi_selmap dut_selmap $selmap_cfg

create_bd_port -dir O -from 7 -to 0 data
create_bd_port -dir O cclk
create_bd_port -dir O program_b
create_bd_port -dir O rdwr_b
create_bd_port -dir O csi_b
create_bd_port -dir I init_b
create_bd_port -dir I done

ad_connect data      dut_selmap/data
ad_connect cclk      dut_selmap/cclk
ad_connect program_b dut_selmap/program_b
ad_connect rdwr_b    dut_selmap/rdwr_b
ad_connect csi_b     dut_selmap/csi_b
ad_connect init_b    dut_selmap/init_b
ad_connect done      dut_selmap/done

ad_cpu_interconnect 0x7c000000 dut_selmap
