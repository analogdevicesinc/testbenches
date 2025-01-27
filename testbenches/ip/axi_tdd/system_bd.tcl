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

# Device clk
ad_ip_instance clk_vip device_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "DEVICE_CLK=device_clk_vip"

set device_clk device_clk_vip/clk_out

#  ------------------
#
# Blocks under test 
#
#  ------------------

global ad_project_params
ad_ip_instance axi_tdd dut_tdd $ad_project_params(tdd_cfg)

ad_connect  $device_clk dut_tdd/clk
ad_connect  $sys_cpu_resetn dut_tdd/resetn

create_bd_port -dir I sync_in
create_bd_port -dir O sync_out
ad_connect  sync_in  dut_tdd/sync_in
ad_connect  sync_out dut_tdd/sync_out

set num_ch [lindex $ad_project_params(tdd_cfg) 3]
create_bd_port -from 0 -to [expr $num_ch-1] -dir O tdd_channel
ad_connect tdd_channel dut_tdd/tdd_channel

ad_cpu_interconnect 0x7c420000 dut_tdd

set TDD 0x7C420000
set_property offset $TDD [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dut_tdd}]
adi_sim_add_define "TDD_BA=[format "%d" ${TDD}]"
