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

source ../../../../scripts/adi_env.tcl

# system level parameters
set INTF  $ad_project_params(INTF)
set ADC_N_BITS $ad_project_params(ADC_N_BITS)
set NUM_OF_SDI $ad_project_params(NUM_OF_SDI)

global ad_project_params

adi_project_files [list \
	"../../../../library/common/ad_edge_detect.v" \
	"../../../../library/util_cdc/sync_bits.v"]

#
#  Block design under test
#

source $ad_hdl_dir/projects/ad7606x_fmc/common/ad7606x_bd.tcl

create_bd_port -dir O sys_clk

ad_connect sys_clk sys_cpu_clk

if {$INTF == 0} {
  set BA_AD7606X 0x44A00000
  set_property offset $BA_AD7606X [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad7606x}]
  adi_sim_add_define "AXI_AD7606X_BA=[format "%d" ${BA_AD7606X}]"
} else {
  create_bd_port -dir O spi_clk
  ad_connect spi_clk spi_clkgen/clk_0

  create_bd_port -dir O ad7606_irq
  ad_connect ad7606_irq spi_ad7606/irq

  set BA_SPI_REGMAP 0x44A00000
  set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_ad7606_axi_regmap}]
  adi_sim_add_define "SPI_AD7606_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

  set BA_CLKGEN 0x44A70000
  set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_clkgen}]
  adi_sim_add_define "AD7606X_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"
}

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad7606x_dma}]
adi_sim_add_define "AD7606X_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_PWM 0x44A60000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad7606_pwm_gen}]
adi_sim_add_define "AXI_PWMGEN_BA=[format "%d" ${BA_PWM}]"
