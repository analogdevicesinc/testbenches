###############################################################################
## Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

source ../../../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create io_vip
adi_ip_files io_vip [list \
  "io_vip_top.sv" \
  "io_vip_if.sv" \
]

adi_ip_properties_lite io_vip
adi_ip_sim_ttcl io_vip "io_vip_pkg.ttcl"

set_property company_url {https://wiki.analog.com/resources/fpga/docs/axi_dmac} [ipx::current_core]

set_property display_name "ADI IO VIP" [ipx::current_core]
set_property description "ADI IO VIP" [ipx::current_core]

# Remove all inferred interfaces
ipx::remove_all_bus_interface [ipx::current_core]

## Interface definitions

adi_set_ports_dependency "i" \
      "(spirit:decode(id('MODELPARAM_VALUE.MODE')) != 1)"

adi_set_ports_dependency "o" \
      "(spirit:decode(id('MODELPARAM_VALUE.MODE')) != 0)"

adi_set_ports_dependency "clk" \
      "(spirit:decode(id('MODELPARAM_VALUE.ASYNC')) = 0)"

set cc [ipx::current_core]

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
