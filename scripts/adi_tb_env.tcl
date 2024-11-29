###############################################################################
## Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# environment related stuff
if [info exists ::env(ADI_HDL_DIR)] {
  set ad_hdl_dir [file normalize $::env(ADI_HDL_DIR)]
} else {
  error "Missing ADI_HDL_DIR environment variable definition!"
}

set ad_tb_dir [file normalize [file join [file dirname [info script]] "../"]]

if [info exists ::env(ADI_TB_DIR)] {
  set ad_tb_dir [file normalize $::env(ADI_TB_DIR)]
}

source $ad_hdl_dir/scripts/adi_env.tcl
