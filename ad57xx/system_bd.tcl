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
#      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
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

source ../../projects/ad57xx_ardz/common/ad57xx_ardz_bd.tcl

# Add test-specific VIPs

ad_ip_instance adi_spi_vip spi_s_vip $ad_project_params(spi_s_vip_cfg)

adi_sim_add_define "SPI_S=spi_s_vip"

ad_disconnect ad57xx_spi spi_ad57xx/m_spi

ad_connect spi_s_vip/s_spi spi_ad57xx/m_spi

# Last tasks
create_bd_port -dir O ad57xx_spi_clk
create_bd_port -dir O ad57xx_spi_irq
create_bd_port -dir O ad57xx_spi_sclk
ad_connect ad57xx_spi_clk axi_ad57xx_clkgen/clk_0
ad_connect ad57xx_spi_irq spi_ad57xx/irq

set BA_SPI_REGMAP 0x44A00000
set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_ad57xx_axi_regmap}]
adi_sim_add_define "SPI_ENGINE_SPI_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

set BA_TX_DMA 0x44A40000
set_property offset $BA_TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad57xx_dma}]
adi_sim_add_define "SPI_ENGINE_TX_DMA_BA=[format "%d" ${BA_TX_DMA}]"

set BA_CLKGEN 0x44A70000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad57xx_clkgen}]
adi_sim_add_define "SPI_ENGINE_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"

set BA_PWM 0x44B00000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_trig_gen}]
adi_sim_add_define "SPI_ENGINE_PWM_GEN_BA=[format "%d" ${BA_PWM}]"
