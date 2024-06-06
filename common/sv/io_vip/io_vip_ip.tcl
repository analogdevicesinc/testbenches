###############################################################################
## Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

source ../../../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create io_vip
adi_ip_files io_vip [list \
  "io_vip.sv" \
  "io_vip_if.sv" \
]

adi_ip_properties_lite io_vip

# Remove all inferred interfaces
ipx::remove_all_bus_interface [ipx::current_core]

## Interface definitions

adi_set_ports_dependency "in" \
      "(spirit:decode(id('MODELPARAM_VALUE.MODE')) = 0)"
adi_set_ports_dependency "out" \
      "(spirit:decode(id('MODELPARAM_VALUE.MODE')) = 1)"

set cc [ipx::current_core]

## MODE
set_property -dict [list \
	"value_validation_type" "pairs" \
	"value_validation_pairs" {"Monitor" 0 "Driver" 1} \
] \
[ipx::get_user_parameters MODE -of_objects $cc]

## Customize IP Layout
## Remove the automatically generated GUI page
ipgui::remove_page -component $cc [ipgui::get_pagespec -name "Page 0" -component $cc]
ipx::save_core [ipx::current_core]


## Create general configuration page
ipgui::add_page -name {IO VIP} -component [ipx::current_core] -display_name {IO VIP}
set page0 [ipgui::get_pagespec -name "IO VIP" -component $cc]

set general_group [ipgui::add_group -name "General Configuration" -component $cc \
    -parent $page0 -display_name "General Configuration" ]

ipgui::add_param -name "WIDTH" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "IO Width" \
  "tooltip" "\[WIDTH\] Width of the IO" \
] [ipgui::get_guiparamspec -name "WIDTH" -component $cc]


ipgui::add_param -name "MODE" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "Mode" \
  "tooltip" "\[MODE\] Set as output or input" \
] [ipgui::get_guiparamspec -name "MODE" -component $cc]

## Create and save the XGUI file
ipx::create_xgui_files $cc
ipx::save_core $cc
