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

source ../../scripts/adi_env.tcl

global ad_project_params

adi_project_files [list \
	"../../library/common/ad_edge_detect.v" \
	"../../library/util_cdc/sync_bits.v" \
        "../../library/common/ad_iobuf.v" \
]

#
#  Block design under test
#

create_bd_intf_port -mode Master -vlnv analog.com:interface:i3c_controller_rtl:1.0 i3c
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 offload_sdi
create_bd_port -dir I offload_trigger

source $ad_hdl_dir/library/i3c_controller/scripts/i3c_controller_bd.tcl

set async_clk 0
set clk_mod 0
set offload 1
set max_devs 16

i3c_controller_create i3c $async_clk $clk_mod $offload $max_devs

ad_connect i3c/m_i3c i3c
ad_connect i3c/offload_sdi offload_sdi
ad_connect offload_trigger i3c/trigger

ad_connect sys_cpu_clk i3c/clk
ad_connect sys_cpu_resetn i3c/reset_n

ad_cpu_interconnect 0x44a00000 i3c/host_interface

ad_cpu_interrupt "ps-12" "mb-12" i3c/irq

ad_mem_hp1_interconnect sys_cpu_clk sys_ps7/S_AXI_HP1

create_bd_port -dir O i3c_irq
create_bd_port -dir O i3c_clk

ad_connect i3c_irq i3c/irq
ad_connect i3c_clk sys_clk_vip/clk_out

set I3C_CONTROLLER 0x44A00000
set_property offset $I3C_CONTROLLER [get_bd_addr_segs {mng_axi_vip/Master_AXI/host_interface}]
adi_sim_add_define "I3C_CONTROLLER_BA=[format "%d" ${I3C_CONTROLLER}]"
