# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
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

#
#  Block design under test
#

# Create dummy GPIO ports that cn0363_bd.tcl expects
create_bd_port -dir I -from 34 -to 0 GPIO_I
create_bd_port -dir O -from 34 -to 0 GPIO_O
create_bd_port -dir O -from 34 -to 0 GPIO_T

# Override ad_ip_parameter to skip sys_ps7 configuration in testbench
rename ad_ip_parameter ad_ip_parameter_orig
proc ad_ip_parameter {p_name args} {
  if {$p_name eq "sys_ps7"} {
    puts "INFO: Skipping sys_ps7 configuration in testbench"
    return
  }
  ad_ip_parameter_orig $p_name {*}$args
}

# Override ad_mem_hp2_interconnect to skip sys_ps7 references in testbench
rename ad_mem_hp2_interconnect ad_mem_hp2_interconnect_orig
proc ad_mem_hp2_interconnect {p_clk p_name} {
  if {[string match "*sys_ps7*" $p_name]} {
    puts "INFO: Skipping sys_ps7 memory interconnect in testbench"
    return
  }
  ad_mem_hp2_interconnect_orig $p_clk $p_name
}

# Change to project directory so relative paths in cn0363_bd.tcl work correctly
# (e.g., ../common/filters/hpf.mat)
set saved_dir [pwd]
cd $ad_hdl_dir/projects/cn0363/zed

source $ad_hdl_dir/projects/cn0363/common/cn0363_bd.tcl

# Restore working directory
cd $saved_dir

# Restore original procs
rename ad_ip_parameter ""
rename ad_ip_parameter_orig ad_ip_parameter
rename ad_mem_hp2_interconnect ""
rename ad_mem_hp2_interconnect_orig ad_mem_hp2_interconnect

create_bd_port -dir O cn0363_spi_clk
create_bd_port -dir O cn0363_irq

ad_connect cn0363_spi_clk sys_cpu_clk
ad_connect cn0363_irq spi_cn0363/irq

set BA_ADC 0x43C00000
set_property offset $BA_ADC [get_bd_addr_segs {mng_axi_vip/Master_AXI/axi_adc}]
adi_sim_add_define "AXI_ADC_BA=[format "%d" ${BA_ADC}]"

set BA_SPI_REGMAP 0x44A00000
set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_cn0363_axi_regmap}]
adi_sim_add_define "SPI_CN0363_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/axi_dma}]
adi_sim_add_define "CN0363_DMA_BA=[format "%d" ${BA_DMA}]"
