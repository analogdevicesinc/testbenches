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

source $ad_hdl_dir/library/spi_engine/scripts/spi_engine.tcl

#
#  Block design under test
#

source $ad_hdl_dir/projects/ad5529r_ardz/common/ad5529r_ardz_bd.tcl

# Add test-specific VIPs

ad_ip_instance adi_spi_vip spi_s_vip $ad_project_params(spi_s_vip_cfg)

adi_sim_add_define "SPI_S=spi_s_vip"

ad_disconnect ad5529r_spi spi_ad5529r/m_spi

ad_connect spi_s_vip/s_spi spi_ad5529r/m_spi

# Create output ports for testbench signals
create_bd_port -dir O ad5529r_spi_clk
create_bd_port -dir O ad5529r_spi_irq
create_bd_port -dir O ad5529r_tg0
create_bd_port -dir O ad5529r_tg1
create_bd_port -dir O ad5529r_tg2
create_bd_port -dir O ad5529r_tg3

ad_connect ad5529r_spi_clk axi_ad5529r_clkgen/clk_0
ad_connect ad5529r_spi_irq spi_ad5529r/irq
ad_connect ad5529r_tg0 tg0
ad_connect ad5529r_tg1 tg1
ad_connect ad5529r_tg2 tg2
ad_connect ad5529r_tg3 tg3

# AXI address map
set BA_SPI_REGMAP 0x44A00000
set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_ad5529r_axi_regmap}]
adi_sim_add_define "SPI_ENGINE_SPI_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

set BA_TX_DMA 0x44A40000
set_property offset $BA_TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad5529r_dma}]
adi_sim_add_define "SPI_ENGINE_TX_DMA_BA=[format "%d" ${BA_TX_DMA}]"

set BA_CLKGEN 0x44B10000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad5529r_clkgen}]
adi_sim_add_define "SPI_ENGINE_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"

set BA_TRIG_GEN 0x44B00000
set_property offset $BA_TRIG_GEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_trig_gen}]
adi_sim_add_define "SPI_ENGINE_TRIG_GEN_BA=[format "%d" ${BA_TRIG_GEN}]"

set BA_TOGGLE_GEN 0x44B20000
set_property offset $BA_TOGGLE_GEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_toggle_gen}]
adi_sim_add_define "SPI_ENGINE_TOGGLE_GEN_BA=[format "%d" ${BA_TOGGLE_GEN}]"
