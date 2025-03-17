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

# Device clk
ad_ip_instance clk_vip ssi_clk_vip [ list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "SSI_CLK=ssi_clk_vip"
create_bd_port -dir O ssi_clk_out
ad_connect ssi_clk_out ssi_clk_vip/clk_out

# Remove duplicated objects
delete_bd_objs \
  [get_bd_cells sys_concat_intc] \
  [get_bd_cells sys_rstgen]

ad_disconnect [get_bd_pins sys_clk_vip/clk_out] sys_cpu_clk

# Block design under test
source $ad_hdl_dir/projects/pluto/system_bd.tcl

# Remove unnecessary objects
delete_bd_objs \
  [get_bd_intf_nets axi_ad9361_adc_dma_m_dest_axi] \
  [get_bd_intf_nets axi_ad9361_dac_dma_m_src_axi] \
  [get_bd_intf_nets S00_AXI_1] \
  [get_bd_intf_nets sys_ps7_DDR] \
  [get_bd_intf_nets sys_ps7_FIXED_IO] \
  [get_bd_nets gpio_i_1] \
  [get_bd_nets spi0_clk_i_1] \
  [get_bd_nets spi0_csn_i_1] \
  [get_bd_nets spi0_sdi_i_1] \
  [get_bd_nets spi0_sdo_i_1] \
  [get_bd_nets sys_200m_clk] \
  [get_bd_nets sys_concat_intc_dout] \
  [get_bd_nets sys_ps7_FCLK_RESET0_N] \
  [get_bd_nets sys_ps7_GPIO_O] \
  [get_bd_nets sys_ps7_GPIO_T] \
  [get_bd_nets sys_ps7_SPI0_MOSI_O] \
  [get_bd_nets sys_ps7_SPI0_SCLK_O] \
  [get_bd_nets sys_ps7_SPI0_SS_O] \
  [get_bd_nets sys_ps7_SPI0_SS1_O] \
  [get_bd_nets sys_ps7_SPI0_SS2_O] \
  [get_bd_cells sys_ps7]

ad_connect sys_cpu_clk sys_clk_vip/clk_out
ad_connect sys_cpu_clk mng_axi_vip/aclk
ad_connect sys_cpu_clk axi_intc/s_axi_aclk
ad_connect sys_cpu_clk axi_axi_interconnect/aclk
ad_connect sys_cpu_clk axi_mem_interconnect/aclk1
ad_connect sys_rst_vip/rst_out sys_rstgen/ext_reset_in
ad_connect axi_intc/intr sys_concat_intc/dout
ad_connect $sys_iodelay_clk axi_ad9361/delay_clk

ad_mem_hp1_interconnect sys_cpu_clk axi_ad9361_adc_dma/m_dest_axi
ad_mem_hp2_interconnect sys_cpu_clk axi_ad9361_dac_dma/m_src_axi

ad_ip_parameter axi_ad9361 CONFIG.DELAY_REFCLK_FREQUENCY 400

set RX_DMA 0x7C400000
set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9361_adc_dma}]
adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

set TX_DMA 0x7C420000
set_property offset $TX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9361_dac_dma}]
adi_sim_add_define "TX_DMA_BA=[format "%d" ${TX_DMA}]"

set TDDN 0x7C440000
set_property offset $TDDN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_tdd_0}]
adi_sim_add_define "TDDN_BA=[format "%d" ${TDDN}]"

set AXI_AD9361 0x79020000
set_property offset $AXI_AD9361 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad9361}]
adi_sim_add_define "AXI_AD9361_BA=[format "%d" ${AXI_AD9361}]"
