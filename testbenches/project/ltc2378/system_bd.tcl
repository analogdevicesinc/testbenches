# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
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

ad_ip_instance clk_vip ltc2378_ext_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 100000000 \
]

adi_sim_add_define "LTC2378_EXT_CLK=ltc2378_ext_clk_vip"

#
#  Block design under test
#

source $ad_hdl_dir/projects/ltc2378_fmc/common/ltc2378_bd.tcl

delete_bd_objs [get_bd_ports ltc2378_ext_clk]

# Connect the clock VIP directly to the PWM generator
ad_connect ltc2378_ext_clk_vip/clk_out ltc2378_trigger_gen/ext_clk

create_bd_port -dir O ltc2378_spi_clk
create_bd_port -dir O ltc2378_irq

ad_connect ltc2378_spi_clk spi_clkgen/clk_0
ad_connect ltc2378_irq spi_ltc2378/irq

set BA_SPI_REGMAP 0x44A00000
set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_ltc2378_axi_regmap}]
adi_sim_add_define "SPI_LTC2378_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ltc2378_dma}]
adi_sim_add_define "LTC2378_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_CLKGEN 0x44A70000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_clkgen}]
adi_sim_add_define "LTC2378_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"

set BA_PWM 0x44B00000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ltc2378_trigger_gen}]
adi_sim_add_define "LTC2378_PWM_GEN_BA=[format "%d" ${BA_PWM}]"
