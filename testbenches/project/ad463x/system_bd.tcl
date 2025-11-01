# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2018 Analog Devices, Inc. All rights reserved.
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

adi_project_files [list \
	"$ad_hdl_dir/library/common/ad_edge_detect.v" \
	"$ad_hdl_dir/library/util_cdc/sync_bits.v" \
]

#
#  Block design under test
#
#
source $ad_hdl_dir/projects/ad4630_fmc/common/ad463x_bd.tcl

create_bd_port -dir I ad463x_ddr_sclk
create_bd_port -dir O ad463x_spi_clk
create_bd_port -dir O ad463x_irq

ad_connect ad463x_spi_clk spi_clkgen/clk_0
ad_connect ad463x_irq spi_ad463x/irq

ad_ip_instance adi_spi_vip spi_s_vip $ad_project_params(spi_s_vip_cfg)
adi_sim_add_define "SPI_S=spi_s_vip"

# Create a new interface with Monitor mode
create_bd_intf_port -mode Monitor -vlnv analog.com:interface:spi_engine_rtl:1.0 ad463x_spi_vip

ad_disconnect spi_ad463x/spi_ad463x_execution/sclk  ad463x_spi_sclk
ad_disconnect spi_ad463x/spi_ad463x_execution/sdo   ad463x_spi_sdo
ad_disconnect spi_ad463x/spi_ad463x_execution/cs    ad463x_spi_cs
ad_disconnect spi_ad463x/spi_ad463x_execution/sdi   ad463x_spi_sdi

ad_disconnect spi_ad463x/ad463x_spi_sclk            ad463x_spi_sclk
ad_disconnect spi_ad463x/ad463x_spi_sdo             ad463x_spi_sdo
ad_disconnect spi_ad463x/ad463x_spi_cs              ad463x_spi_cs
ad_disconnect spi_ad463x/ad463x_spi_sdi             ad463x_spi_sdi

if {$ad_project_params(CLK_MODE) == 0} {
	ad_connect spi_s_vip/s_spi spi_ad463x/m_spi
	ad_connect ad463x_spi_vip  spi_ad463x/m_spi
} else {
	ad_connect spi_s_vip/s_spi spi_ad463x/m_spi
	ad_connect ad463x_spi_vip  spi_ad463x/m_spi
	if {$ad_project_params(DDR_EN) == 1} {
		ad_connect ad463x_ddr_sclk       spi_s_vip/s_spi_sclk
	} else {
		ad_connect spi_ad463x/m_spi_sclk spi_s_vip/s_spi_sclk
	}
	ad_disconnect ad463x_spi_sdi      data_capture/data_in
	ad_disconnect ad463x_spi_cs       data_capture/csn
	ad_connect spi_s_vip/s_spi_miso   data_capture/data_in
	ad_connect spi_ad463x/m_spi_cs    data_capture/csn

	ad_connect spi_s_vip/s_spi_miso   spi_ad463x/m_spi_sdi
	ad_connect spi_s_vip/s_spi_mosi   spi_ad463x/m_spi_sdo
	ad_connect spi_s_vip/s_spi_cs     spi_ad463x/m_spi_cs
	ad_connect ad463x_spi_vip_sclk    spi_ad463x/m_spi_sclk
	ad_connect ad463x_spi_vip_sdi     spi_s_vip/s_spi_miso
	ad_connect ad463x_spi_vip_sdo     spi_ad463x/m_spi_sdo
	ad_connect ad463x_spi_vip_cs      spi_ad463x/m_spi_cs
}

set BA_SPI_REGMAP 0x44A00000
set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/spi_ad463x_axi_regmap}]
adi_sim_add_define "SPI_AD463X_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad463x_dma}]
adi_sim_add_define "AD463X_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_CLKGEN 0x44A70000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_clkgen}]
adi_sim_add_define "AD463X_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"

set BA_PWM 0x44B00000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_cnv_generator}]
adi_sim_add_define "AD463X_PWM_GEN_BA=[format "%d" ${BA_PWM}]"

