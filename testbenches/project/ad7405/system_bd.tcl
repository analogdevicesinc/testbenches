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

source ../../../../scripts/adi_env.tcl

# system level parameters

global ad_project_params

#
#  Block design under test
#

source $ad_hdl_dir/projects/ad7405_fmc/common/ad7405_bd.tcl

set BA_AD7405 0x44A00000
set_property offset $BA_AD7405 [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad7405}]
adi_sim_add_define "AXI_AD7405_BA=[format "%d" ${BA_AD7405}]"

set BA_DMA 0x44A30000
set_property offset $BA_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_ad7405_dma}]
adi_sim_add_define "AD7405_DMA_BA=[format "%d" ${BA_DMA}]"

set BA_CLKGEN 0x44A40000
set_property offset $BA_CLKGEN [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_axi_adc_clkgen}]
adi_sim_add_define "AD7405_AXI_CLKGEN_BA=[format "%d" ${BA_CLKGEN}]"
