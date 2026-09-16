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

# system level parameters
set DEVICE "AD4858"
adi_sim_add_define "DEVICE_NO=4858"

#
#  Block design under test
#

# In simulation, ad_mem_hp1_interconnect with sys_ps8 is not needed - the
# ddr_axi_vip handles memory. Redefine to no-op before sourcing the BD.
rename ad_mem_hp1_interconnect ad_mem_hp1_interconnect_orig
proc ad_mem_hp1_interconnect {p_clk p_name} {
  if {[string match "*sys_ps8*" $p_name]} { return }
  ad_mem_hp1_interconnect_orig $p_clk $p_name
}

source $ad_hdl_dir/projects/ad4858_fmcz_dual/common/ad4858_fmcz_bd.tcl

rename ad_mem_hp1_interconnect {}
rename ad_mem_hp1_interconnect_orig ad_mem_hp1_interconnect

# System 200MHz clk
# Create VIP instance
ad_ip_instance clk_vip sys_200m_clk_vip [list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 200000000 \
]
adi_sim_add_define "SYS_200M_CLK=sys_200m_clk_vip"
ad_connect sys_200m_clk sys_200m_clk_vip/clk_out

create_bd_port -dir O sys_200mhz_clk_out
ad_connect sys_200mhz_clk_out sys_200m_clk_vip/clk_out

# Reconnect delay_clk to sys_mem_clk (400MHz DDR clock, already in the
# test harness) so IDELAYE3 REFCLK_FREQUENCY >= 300MHz as required.
# Also set DELAY_REFCLK_FREQ parameter to match.
ad_ip_parameter axi_ad4858_0 CONFIG.DELAY_REFCLK_FREQ 400
ad_ip_parameter axi_ad4858_1 CONFIG.DELAY_REFCLK_FREQ 400
disconnect_bd_net [get_bd_nets sys_200m_clk] [get_bd_pins axi_ad4858_0/delay_clk]
disconnect_bd_net [get_bd_nets sys_200m_clk] [get_bd_pins axi_ad4858_1/delay_clk]
ad_connect sys_mem_clk axi_ad4858_0/delay_clk
ad_connect sys_mem_clk axi_ad4858_1/delay_clk

# AXI address map for ADC 0
set BA_AD4858_0 0x43C00000
set_property offset $BA_AD4858_0 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad4858_0}]
adi_sim_add_define "AXI_AD4858_0_BA=[format "%d" ${BA_AD4858_0}]"

set BA_DMA_0 0x43E00000
set_property offset $BA_DMA_0 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad4858_dma_0}]
adi_sim_add_define "AD4858_DMA_0_BA=[format "%d" ${BA_DMA_0}]"

set BA_PWM_0 0x43D00000
set_property offset $BA_PWM_0 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_pwm_gen_0}]
adi_sim_add_define "AD4858_AXI_PWM_GEN_0_BA=[format "%d" ${BA_PWM_0}]"

# AXI address map for ADC 1
set BA_AD4858_1 0x44C00000
set_property offset $BA_AD4858_1 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad4858_1}]
adi_sim_add_define "AXI_AD4858_1_BA=[format "%d" ${BA_AD4858_1}]"

set BA_DMA_1 0x44E00000
set_property offset $BA_DMA_1 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad4858_dma_1}]
adi_sim_add_define "AD4858_DMA_1_BA=[format "%d" ${BA_DMA_1}]"

set BA_PWM_1 0x44D00000
set_property offset $BA_PWM_1 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_pwm_gen_1}]
adi_sim_add_define "AD4858_AXI_PWM_GEN_1_BA=[format "%d" ${BA_PWM_1}]"

# AXI address map for shared clkgen
set BA_CLKGEN 0x44000000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_adc_clkgen}]
adi_sim_add_define "AD4858_ADC_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"
