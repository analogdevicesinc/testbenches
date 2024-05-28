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
source $ad_hdl_dir/library/spi_engine/scripts/spi_engine.tcl


global ad_project_params

adi_project_files [list \
    "../../library/common/ad_edge_detect.v" \
    "../../library/util_cdc/sync_bits.v" \
        "../../library/common/ad_iobuf.v" \
]

#
#  Block design under test
#

source ./spi_engine_test_bd.tcl

# Add test-specific VIPs
puts "CPOL: "
puts [$ad_project_params(CPOL)]
puts "CPHA: "
puts [$ad_project_params(CPHA)]

ad_ip_instance adi_spi_vip spi_s_vip $ad_project_params(spi_s_vip_cfg)

adi_sim_add_define "SPI_S=spi_s_vip"
ad_connect spi_engine/m_spi spi_s_vip/s_spi

# Last tasks
create_bd_port -dir O spi_engine_spi_clk
create_bd_port -dir O spi_engine_irq
if {$ad_project_params(ECHO_SCLK)} {
    create_bd_port -dir I spi_engine_echo_sclk
    ad_connect spi_engine_echo_sclk spi_engine/echo_sclk
}

ad_connect spi_engine_spi_clk spi_clkgen/clk_0
ad_connect spi_engine_irq spi_engine/irq

set BA_SPI_REGMAP 0x44A00000
set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_engine_axi_regmap}]
adi_sim_add_define "SPI_ENGINE_SPI_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_spi_engine_dma}]
adi_sim_add_define "SPI_ENGINE_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_CLKGEN 0x44A70000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_clkgen}]
adi_sim_add_define "SPI_ENGINE_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"

set BA_PWM 0x44B00000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_engine_trigger_gen}]
adi_sim_add_define "SPI_ENGINE_PWM_GEN_BA=[format "%d" ${BA_PWM}]"