# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2025-2026 Analog Devices, Inc. All rights reserved.
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

# system level parameters
set CN0577_ADAQ2387X_N $ad_project_params(CN0577_ADAQ2387X_N)

#
#  Block design under test
#

if {$CN0577_ADAQ2387X_N == 1} {
  source $ad_hdl_dir/projects/cn0577/common/cn0577_bd.tcl
} else {
  source $ad_hdl_dir/projects/adaq23875/common/adaq23875_bd.tcl
}

ad_ip_parameter axi_ltc2387 CONFIG.ADC_INIT_DELAY 0

ad_disconnect  sys_200m_clk  axi_ltc2387/delay_clk
ad_connect     sys_dma_clk   axi_ltc2387/delay_clk

delete_bd_objs [get_bd_nets ref_clk_1]
delete_bd_objs [get_bd_nets sys_200m_clk]

if {$CN0577_ADAQ2387X_N == 1} {
  # 120MHz ref_clk for cn0577
 set ref_freq 120000000
} else {
  # 100Mhz ref_clk for adaq2387x
 set ref_freq 100000000
}

ad_ip_instance clk_vip ref_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ $ref_freq \
]

adi_sim_add_define "REF_CLK=ref_clk_vip"

create_bd_port -dir O ref_clk_out
ad_connect ref_clk_out ref_clk_vip/clk_out
ad_connect axi_ltc2387/ref_clk ref_clk_vip/clk_out
ad_connect axi_ltc2387_dma/fifo_wr_clk ref_clk_vip/clk_out
ad_connect axi_pwm_gen/ext_clk ref_clk_vip/clk_out

set BA_AXI_LTC2387 0x44A00000
set_property offset $BA_AXI_LTC2387 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ltc2387}]
adi_sim_add_define "AXI_LTC2387_BA=[format "%d" ${BA_AXI_LTC2387}]"

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ltc2387_dma}]
adi_sim_add_define "AXI_LTC2387_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_PWM 0x44A60000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_pwm_gen}]
adi_sim_add_define "AXI_PWM_GEN_BA=[format "%d" ${BA_PWM}]"
