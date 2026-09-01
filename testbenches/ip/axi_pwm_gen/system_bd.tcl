# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

create_bd_port -dir O pwm_0

ad_ip_instance clk_vip pwm_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ [expr pow(10, 9)/$ad_project_params(EXT_CLK_PERIOD)] \
]
adi_sim_add_define "PWM_CLK=pwm_clk_vip"
adi_sim_add_define "PWM_CLK_PERIOD=$ad_project_params(EXT_CLK_PERIOD)"

ad_ip_instance axi_pwm_gen test_axi_pwm_gen
ad_ip_parameter test_axi_pwm_gen CONFIG.PULSE_0_PERIOD $ad_project_params(PULSE_0_PERIOD)
ad_ip_parameter test_axi_pwm_gen CONFIG.PULSE_0_WIDTH $ad_project_params(PULSE_0_WIDTH)

ad_connect pwm_clk_vip/clk_out test_axi_pwm_gen/ext_clk
ad_connect sys_cpu_clk test_axi_pwm_gen/s_axi_aclk
ad_connect sys_cpu_resetn test_axi_pwm_gen/s_axi_aresetn
ad_connect test_axi_pwm_gen/pwm_0 pwm_0

ad_cpu_interconnect 0x7c420000 test_axi_pwm_gen

set BA_PWM 0x7c420000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_test_axi_pwm_gen}]
adi_sim_add_define "AXI_PWM_GEN_BA=[format "%d" ${BA_PWM}]"