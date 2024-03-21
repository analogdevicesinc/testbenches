# ***************************************************************************
# ***************************************************************************
# Copyright 2023 (c) Analog Devices, Inc. All rights reserved.
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

# common zed-based bd for test
#source ../../projects/common/zed/zed_system_bd.tcl

#  ------------------
#
# Block under test 
#
#  ------------------

create_bd_port -dir O pwm_gen_o_0
create_bd_port -dir O pwm_gen_o_1
create_bd_port -dir O pwm_gen_o_2
create_bd_port -dir O pwm_gen_o_3
create_bd_port -dir O pwm_gen_o_4
create_bd_port -dir O pwm_gen_o_5
create_bd_port -dir O pwm_gen_o_6
create_bd_port -dir O pwm_gen_o_7
create_bd_port -dir O pwm_gen_o_8
create_bd_port -dir O pwm_gen_o_9
create_bd_port -dir O pwm_gen_o_10
create_bd_port -dir O pwm_gen_o_11
create_bd_port -dir O pwm_gen_o_12
create_bd_port -dir O pwm_gen_o_13
create_bd_port -dir O pwm_gen_o_14
create_bd_port -dir O pwm_gen_o_15

ad_ip_instance axi_pwm_gen dut_pwm_gen
ad_ip_parameter dut_pwm_gen CONFIG.ASYNC_CLK_EN 1
ad_ip_parameter dut_pwm_gen CONFIG.N_PWMS 16


ad_connect ddr_clk_vip/clk_out dut_pwm_gen/ext_clk
adi_project_files [list \
	"../../library/common/ad_edge_detect.v" \
	"../../library/util_cdc/sync_bits.v"]

ad_connect pwm_gen_o_0 dut_pwm_gen/pwm_0
ad_connect pwm_gen_o_1 dut_pwm_gen/pwm_1
ad_connect pwm_gen_o_2 dut_pwm_gen/pwm_2
ad_connect pwm_gen_o_3 dut_pwm_gen/pwm_3
ad_connect pwm_gen_o_4 dut_pwm_gen/pwm_4
ad_connect pwm_gen_o_5 dut_pwm_gen/pwm_5
ad_connect pwm_gen_o_6 dut_pwm_gen/pwm_6
ad_connect pwm_gen_o_7 dut_pwm_gen/pwm_7
ad_connect pwm_gen_o_8 dut_pwm_gen/pwm_8
ad_connect pwm_gen_o_9 dut_pwm_gen/pwm_9
ad_connect pwm_gen_o_10 dut_pwm_gen/pwm_10
ad_connect pwm_gen_o_11 dut_pwm_gen/pwm_11
ad_connect pwm_gen_o_12 dut_pwm_gen/pwm_12
ad_connect pwm_gen_o_13 dut_pwm_gen/pwm_13
ad_connect pwm_gen_o_14 dut_pwm_gen/pwm_14
ad_connect pwm_gen_o_15 dut_pwm_gen/pwm_15

# connect resets

ad_cpu_interconnect 0x7c000000 dut_pwm_gen

create_bd_port -dir O sys_clk

ad_connect sys_clk sys_cpu_clk
