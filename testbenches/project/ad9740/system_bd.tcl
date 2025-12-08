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

adi_project_files [list \
    "$ad_hdl_dir/library/common/ad_edge_detect.v" \
    "$ad_hdl_dir/library/util_cdc/sync_bits.v" \
    "$ad_hdl_dir/library/common/ad_iobuf.v" \
]

#
#  Block design under test
#

# Extract DEVICE from ad_project_params and set as standalone variable
# This is required because ad9740_fmc_bd.tcl checks [info exists DEVICE]
if {[info exists ad_project_params(DEVICE)]} {
  set DEVICE $ad_project_params(DEVICE)
  puts "system_bd.tcl: Setting DEVICE=$DEVICE from ad_project_params"
} else {
  set DEVICE "AD9744"
  puts "system_bd.tcl: DEVICE not in ad_project_params, defaulting to AD9744"
}

source $ad_hdl_dir//projects/ad9740_fmc/common/ad9740_fmc_bd.tcl

# Add test-specific VIPs

# Base address defines for test program
# Address segments are created by ad9740_fmc_bd.tcl as SEG_data_ad974x_*
adi_sim_add_define "AD974X_DMA_BA=0x44A40000"
adi_sim_add_define "AD974X_DAC_BA=0x44A70000"

