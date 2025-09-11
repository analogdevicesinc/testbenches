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

global ad_project_params

adi_project_files [list \
	  "$ad_hdl_dir/library/common/ad_iobuf.v" \
]

#
#  Block design under test
#

source $ad_hdl_dir/projects/quad_adaq77681/common/quad_adaq77681_bd.tcl

ad_ip_instance axi_pwm_gen quad_adaq77681_trigger_gen
ad_ip_parameter quad_adaq77681_trigger_gen CONFIG.PULSE_0_PERIOD 16
ad_ip_parameter quad_adaq77681_trigger_gen CONFIG.PULSE_0_WIDTH 1

ad_connect mclk_clkgen/clk_0 quad_adaq77681_trigger_gen/ext_clk
ad_connect $sys_cpu_clk quad_adaq77681_trigger_gen/s_axi_aclk
ad_connect sys_cpu_resetn quad_adaq77681_trigger_gen/s_axi_aresetn

ad_ip_instance xlconcat concat_spi_trigger
ad_ip_parameter concat_spi_trigger CONFIG.NUM_PORTS 4
ad_cpu_interconnect 0x44c00000 quad_adaq77681_trigger_gen

ad_ip_instance adi_spi_vip spi_s_vip $ad_project_params(spi_s_vip_cfg)
adi_sim_add_define "SPI_S=spi_s_vip"

# Create a new interface with Monitor mode
create_bd_intf_port -mode Monitor -vlnv analog.com:interface:spi_engine_rtl:1.0 quad_adaq77681_spi_vip

# it is necessary to remove the connection with the input ports quad_ada77681_drdy
ad_disconnect quad_adaq77681_drdy drdy_buf/Op1
ad_connect  concat_spi_trigger/In3   quad_adaq77681_trigger_gen/pwm_0
ad_connect  concat_spi_trigger/In2   quad_adaq77681_trigger_gen/pwm_0
ad_connect  concat_spi_trigger/In1   quad_adaq77681_trigger_gen/pwm_0
ad_connect  concat_spi_trigger/In0   quad_adaq77681_trigger_gen/pwm_0
ad_connect  concat_spi_trigger/dout  drdy_buf/Op1


# it is necessary to remove the connection with the master interface of the quad_ada77681_bd
ad_disconnect quad_adaq77681_spi quad_adaq77681/m_spi
ad_connect spi_s_vip/s_spi quad_adaq77681/m_spi
ad_connect quad_adaq77681_spi_vip quad_adaq77681/m_spi

create_bd_port -dir O quad_adaq77681_spi_vip_clk
create_bd_port -dir O quad_adaq77681_irq
if {$ad_project_params(ECHO_SCLK)} {
    create_bd_port -dir I quad_adaq77681_echo_sclk
    ad_connect quad_adaq77681_echo_sclk $hier_spi_engine/echo_sclk
}

if ($ad_project_params(SDO_STREAMING)) {
    ad_ip_instance axi4stream_vip sdo_src $ad_project_params(axis_sdo_src_vip_cfg)
    adi_sim_add_define "SDO_SRC=sdo_src"
    ad_connect spi_clk sdo_src/aclk
    ad_connect sys_cpu_resetn sdo_src/aresetn
    ad_connect sdo_src/m_axis $hier_spi_engine/s_axis_sample
}

ad_ip_instance clk_vip mclk_clkgen_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 32768000 \
]
adi_sim_add_define "MCLK_CLK=mclk_clkgen_vip"

delete_bd_objs [get_bd_nets quad_adaq77681_mclk_refclk_1]
connect_bd_net [get_bd_pins mclk_clkgen_vip/clk_out] [get_bd_pins mclk_clkgen/clk]

ad_connect quad_adaq77681_spi_vip_clk spi_clkgen/clk_0
ad_connect quad_adaq77681_irq quad_adaq77681/irq

set BA_SPI_REGMAP 0x44A00000
set_property offset $BA_SPI_REGMAP [get_bd_addr_segs {mng_axi_vip/Master_AXI/quad_adaq77681_axi_regmap}]
adi_sim_add_define "QUAD_ADAQ77681_SPI_REGMAP_BA=[format "%d" ${BA_SPI_REGMAP}]"

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_qadc_dma}]
adi_sim_add_define "QUAD_ADAQ77681_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_SPI_CLKGEN 0x44A70000
set_property offset $BA_SPI_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_spi_clkgen}]
adi_sim_add_define "QUAD_ADAQ77681_AXI_SPI_CLKGEN_BA=[format "%d" ${BA_SPI_CLKGEN}]"

set BA_MCLK_CLKGEN 0x44B00000
set_property offset $BA_MCLK_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_mclk_clkgen}]
adi_sim_add_define "QUAD_ADAQ77681_AXI_MCLK_CLKGEN_BA=[format "%d" ${BA_MCLK_CLKGEN}]"

set BA_PWM 0x44C00000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_quad_adaq77681_trigger_gen}]
adi_sim_add_define "QUAD_ADAQ77681_PWM_GEN_BA=[format "%d" ${BA_PWM}]"
