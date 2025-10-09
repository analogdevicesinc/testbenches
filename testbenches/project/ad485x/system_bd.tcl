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

# system level parameters
set LVDS_CMOS_N $ad_project_params(LVDS_CMOS_N)
set DEVICE $ad_project_params(DEVICE)

adi_project_files [list \
    "$ad_hdl_dir/library/common/ad_iobuf.v" 
]

#
#  Block design under test
#

source $ad_hdl_dir//projects/ad485x_fmcz/common/ad485x_fmcz_bd.tcl

if {$LVDS_CMOS_N == "0"} {
  create_bd_port -dir O scki
  create_bd_port -dir I scko
  create_bd_port -dir I adc_lane_0
  create_bd_port -dir I adc_lane_1
  create_bd_port -dir I adc_lane_2
  create_bd_port -dir I adc_lane_3
  create_bd_port -dir I adc_lane_4
  create_bd_port -dir I adc_lane_5
  create_bd_port -dir I adc_lane_6
  create_bd_port -dir I adc_lane_7
} else {
  create_bd_port -dir O scki_p
  create_bd_port -dir O scki_n
  create_bd_port -dir I scko_p
  create_bd_port -dir I scko_n
  create_bd_port -dir I sdo_p
  create_bd_port -dir I sdo_n
}

create_bd_port -dir I busy
create_bd_port -dir O cnv
create_bd_port -dir O lvds_cmos_n

create_bd_port -dir O system_cpu_clk

#mai verifica acolo la Master_AXI ..
set BA_AD485X 0x43C00000
set_property offset $BA_AD485X[get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad485x}]
adi_sim_add_define "AXI_AD485X_BA=[format "%d" ${BA_AD485X}]" #spi??

set BA_TX_DMA 0x43E00000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_ad485x_dma}]
adi_sim_add_define "AD485X_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_CLKGEN 0x44000000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_adc_clkgen}]
adi_sim_add_define "AD485X_ADC_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"

set BA_PWM 0x43D00000
set_property offset $BA_PWM [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_pwm_gen}]
adi_sim_add_define "AD485X_AXI_PWM_GEN_BA=[format "%d" ${BA_PWM}]"


