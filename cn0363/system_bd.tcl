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

# system level parameters

global ad_project_params

#
#  Block design under test
#

source ../../projects/cn0363/common/cn0363_bd.tcl

create_bd_port -dir O cn0363_spi_clk
create_bd_port -dir O cn0363_irq

ad_connect cn0363_spi_clk sys_cpu_clk
ad_connect cn0363_irq spi_cn0363/irq

set BA_ADC 0x43C00000
set_property offset $BA_ADC [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adc}]
adi_sim_add_define "AXI_ADC_BA=[format "%d" ${BA_ADC}]"

set BA_SPI_REGMAP 0x44A00000
set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_cn0363_axi_regmap}]
adi_sim_add_define "SPI_CN0363_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_dma}]
adi_sim_add_define "CN0363_DMA_BA=[format "%d" ${BA_DMA}]"
