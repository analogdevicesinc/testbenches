###############################################################################
## Copyright (C) 2024-2025 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

source ../../../../scripts/adi_tb_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create io_vip
adi_ip_files io_vip_top [list \
  "io_vip.sv" \
  "io_vip_top.v" \
  "io_vip_if.sv" \
  "io_vip_if_base_pkg.sv" \
]

adi_ip_properties_lite io_vip

set cc [ipx::current_core]

set_property company_url {https://www.analog.com/en/index.html} $cc

set_property display_name "ADI IO VIP" $cc
set_property description "ADI IO VIP" $cc

# Remove all inferred interfaces
ipx::remove_all_bus_interface $cc

## Interface definitions

adi_set_ports_dependency "i" \
      "(spirit:decode(id('MODELPARAM_VALUE.MODE')) != 1)"

adi_set_ports_dependency "o" \
      "(spirit:decode(id('MODELPARAM_VALUE.MODE')) != 0)"

adi_set_ports_dependency "clk" \
      "(spirit:decode(id('MODELPARAM_VALUE.ASYNC')) = 0)"

## MODE
set_property -dict [list \
	"value_validation_type" "pairs" \
	"value_validation_pairs" {"Slave" 0 "Master" 1 "Passthrough" 2} \
] \
[ipx::get_user_parameters MODE -of_objects $cc]

set_property -dict [list \
	"value_format" "bool" \
	"value" "false" \
] \
[ipx::get_user_parameters ASYNC -of_objects $cc]
set_property -dict [list \
    "value_format" "bool" \
    "value" "false" \
  ] [ipx::get_hdl_parameters ASYNC -of_objects $cc]

set_property driver_value 0 [ipx::get_ports i -of_objects $cc]

## Customize IP Layout
## Remove the automatically generated GUI page
ipgui::remove_page -component $cc [ipgui::get_pagespec -name "Page 0" -component $cc]
ipx::save_core $cc

## Create general configuration page
ipgui::add_page -name {IO VIP} -component $cc -display_name {IO VIP}
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
  "tooltip" "\[MODE\] Set as master, slave or passthrough" \
] [ipgui::get_guiparamspec -name "MODE" -component $cc]

ipgui::add_param -name "ASYNC" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "Asynchronous clock" \
  "tooltip" "\[ASYNC\] Set clock mode" \
] [ipgui::get_guiparamspec -name "ASYNC" -component $cc]

## Create and save the XGUI file
ipx::create_xgui_files $cc
ipx::save_core $cc
