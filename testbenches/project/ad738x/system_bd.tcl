# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
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

source $ad_hdl_dir/projects/ad738x_fmc/common/ad738x_bd.tcl

# Add test-specific VIPs
puts "CPOL: "
puts [$ad_project_params(CPOL)]
puts "CPHA: "
puts [$ad_project_params(CPHA)]

ad_ip_instance adi_spi_vip spi_s_vip $ad_project_params(spi_s_vip_cfg)
adi_sim_add_define "SPI_S=spi_s_vip"

# Create a new interface with Monitor mode
create_bd_intf_port -mode Monitor -vlnv analog.com:interface:spi_engine_rtl:1.0 ad738x_spi_vip

# it is necessary to remove the connection with the master interface of the quad_ada77681_bd
ad_disconnect ad738x_spi $hier_spi_engine/m_spi
ad_connect spi_s_vip/s_spi $hier_spi_engine/m_spi
ad_connect ad738x_spi_vip $hier_spi_engine/m_spi

if ($ad_project_params(SDO_STREAMING)) {
    ad_ip_instance axi4stream_vip sdo_src $ad_project_params(axis_sdo_src_vip_cfg)
    adi_sim_add_define "SDO_SRC=sdo_src"
    ad_connect spi_clk sdo_src/aclk
    ad_connect sys_cpu_resetn sdo_src/aresetn
    ad_connect sdo_src/m_axis $hier_spi_engine/s_axis_sample
}

create_bd_port -dir O ad738x_spi_vip_clk
create_bd_port -dir O ad738x_irq

ad_connect ad738x_spi_vip_clk spi_clkgen/clk_0
ad_connect ad738x_irq $hier_spi_engine/irq

set BA_SPI_REGMAP 0x44A00000
set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_ad738x_adc_axi_regmap}]
adi_sim_add_define "SPI_AD738x_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad738x_dma}]
adi_sim_add_define "AD738x_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_CLKGEN 0x44A70000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_clkgen}]
adi_sim_add_define "AD738x_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"

set BA_PWM 0x44B00000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_trigger_gen}]
adi_sim_add_define "AD738x_PWM_GEN_BA=[format "%d" ${BA_PWM}]"