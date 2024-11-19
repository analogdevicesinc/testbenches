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

global ad_project_params

# system level parameters
set SER_PAR_N  $ad_project_params(SER_PAR_N)

adi_project_files [list \
	"$ad_hdl_dir/library/common/ad_edge_detect.v" \
	"$ad_hdl_dir/library/util_cdc/sync_bits.v"]

#
#  Block design under test
#

source $ad_hdl_dir/projects/ad7616_sdz/common/ad7616_bd.tcl

if {$SER_PAR_N == 1} {

  create_bd_port -dir O spi_clk
  create_bd_port -dir O ad7616_irq

  ad_connect spi_clk sys_cpu_clk
  ad_connect ad7616_irq spi_ad7616/irq

  set BA_SPI_REGMAP 0x44A00000
  set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_ad7616_axi_regmap}]
  adi_sim_add_define "SPI_AD7616_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

} else {

  create_bd_port -dir O sys_clk
  ad_disconnect  spi_clk ad7616_pwm_gen/ext_clk
  ad_connect  sys_cpu_clk ad7616_pwm_gen/ext_clk
  ad_connect sys_clk sys_cpu_clk

  set BA_AD7616 0x44A80000
  set_property offset $BA_AD7616 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad7616}]
  adi_sim_add_define "AXI_AD7616_BA=[format "%d" ${BA_AD7616}]"

}

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad7616_dma}]
adi_sim_add_define "AD7616_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_PWM 0x44B00000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad7616_pwm_gen}]
adi_sim_add_define "AD7616_PWM_GEN_BA=[format "%d" ${BA_PWM}]"

set BA_CLKGEN 0x44A70000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_clkgen}]
adi_sim_add_define "AD7616_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"
