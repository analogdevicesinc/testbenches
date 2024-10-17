###############################################################################
## Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

source ../../../../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create adi_spi_vip
adi_ip_files adi_spi_vip [list \
    "adi_spi_vip_pkg.sv" \
    "adi_spi_vip.sv" \
    "spi_vip_if.sv" \
    "adi_spi_vip_pkg.ttcl" \
    "$ad_hdl_dir/testbenches/library/utilities/utils.svh" \
    "$ad_hdl_dir/testbenches/library/utilities/logger_pkg.sv" \
]

adi_ip_properties_lite adi_spi_vip
adi_ip_sim_ttcl adi_spi_vip "adi_spi_vip_pkg.ttcl"

set_property company_url {https://wiki.analog.com/resources/fpga/peripherals/spi_engine} [ipx::current_core]

# Remove all inferred interfaces
ipx::remove_all_bus_interface [ipx::current_core]

## Interface definitions

adi_add_bus "s_spi" "slave" \
  "analog.com:interface:spi_engine_rtl:1.0" \
  "analog.com:interface:spi_engine:1.0" \
  {
    {"s_spi_sclk" "sclk"} \
    {"s_spi_miso" "sdi"} \
    {"s_spi_mosi" "sdo"} \
    {"s_spi_cs" "cs"} \
  }
adi_add_bus "m_spi" "master" \
  "analog.com:interface:spi_engine_rtl:1.0" \
  "analog.com:interface:spi_engine:1.0" \
  {
    {"m_spi_sclk" "sclk"} \
    {"m_spi_miso" "sdi"} \
    {"m_spi_mosi" "sdo"} \
    {"m_spi_cs" "cs"} \
  }

  adi_set_bus_dependency "s_spi" "s_spi" \
  "(spirit:decode(id('MODELPARAM_VALUE.MODE')) == 0) || (spirit:decode(id('MODELPARAM_VALUE.MODE')) == 2)"
    adi_set_bus_dependency "m_spi" "m_spi" \
  "(spirit:decode(id('MODELPARAM_VALUE.MODE')) == 1) || (spirit:decode(id('MODELPARAM_VALUE.MODE')) == 2)"

## Parameter validations

set cc [ipx::current_core]

## MODE
set_property -dict [list \
  "value_validation_type" "pairs" \
  "value_validation_pairs" { \
      "SLAVE" "0" \
      "MASTER" "1" \
      "MONITOR" "2" \
    } \
 ] \
 [ipx::get_user_parameters MODE -of_objects $cc]

 ## CPOL
set_property -dict [list \
  "value_format" "bool" \
  "value" "false" \
 ] \
 [ipx::get_user_parameters CPOL -of_objects $cc]
 set_property -dict [list \
  "value_format" "bool" \
  "value" "false" \
 ] \
 [ipx::get_hdl_parameters CPOL -of_objects $cc]

 ## CPHA
set_property -dict [list \
  "value_format" "bool" \
  "value" "false" \
 ] \
 [ipx::get_user_parameters CPHA -of_objects $cc]
set_property -dict [list \
  "value_format" "bool" \
  "value" "false" \
 ] \
 [ipx::get_hdl_parameters CPHA -of_objects $cc]

 ## INV_CS
set_property -dict [list \
  "value_format" "bool" \
  "value" "false" \
 ] \
 [ipx::get_user_parameters INV_CS -of_objects $cc]
set_property -dict [list \
  "value_format" "bool" \
  "value" "false" \
 ] \
 [ipx::get_hdl_parameters INV_CS -of_objects $cc]

## SLAVE_TIN
 set_property	-dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "-10000" \
  "value_validation_range_maximum" "10000" \
  "enablement_tcl_expr" "\$MODE==0" \
 ] \
 [ipx::get_user_parameters SLAVE_TIN -of_objects $cc]

## SLAVE_TOUT
 set_property	-dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "-10000" \
  "value_validation_range_maximum" "10000" \
  "enablement_tcl_expr" "\$MODE==0" \
 ] \
 [ipx::get_user_parameters SLAVE_TOUT -of_objects $cc]

## MASTER_TIN
 set_property	-dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "-10000" \
  "value_validation_range_maximum" "10000" \
  "enablement_tcl_expr" "\$MODE==1" \
 ] \
 [ipx::get_user_parameters MASTER_TIN -of_objects $cc]

## MASTER_TOUT
 set_property	-dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "-10000" \
  "value_validation_range_maximum" "10000" \
  "enablement_tcl_expr" "\$MODE==1" \
 ] \
 [ipx::get_user_parameters MASTER_TOUT -of_objects $cc]

## CS_TO_MISO
 set_property	-dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "-10000" \
  "value_validation_range_maximum" "10000" \
  "enablement_tcl_expr" "\$MODE==0" \
 ] \
 [ipx::get_user_parameters CS_TO_MISO -of_objects $cc]

## DATA_DLENGTH
set_property -dict [list \
  "value_validation_type" "range_long" \
  "value_validation_range_minimum" "1" \
  "value_validation_range_maximum" "32" \
 ] \
 [ipx::get_user_parameters DATA_DLENGTH -of_objects $cc]

## DEFAULT_MISO_DATA
set_property	-dict [list \
  "value_bit_string_length" "32" \
  "value_format" "bit_string" \
  "enablement_tcl_expr" "\$MODE==0" \
] \
[ipx::get_user_parameters DEFAULT_MISO_DATA -of_objects $cc]

## Customize IP Layout

## Remove the automatically generated GUI page
ipgui::remove_page -component $cc [ipgui::get_pagespec -name "Page 0" -component $cc]
ipx::save_core [ipx::current_core]

## Create general configuration page
ipgui::add_page -name {ADI SPI VIP} -component [ipx::current_core] -display_name {ADI SPI VIP}
set page0 [ipgui::get_pagespec -name "ADI SPI VIP" -component $cc]

set general_group [ipgui::add_group -name "General Configuration" -component $cc \
    -parent $page0 -display_name "General Configuration" ]

set model_timing  [ipgui::add_group -name "Model Timing Configuration" -component $cc \
    -parent $page0 -display_name "Model Timing Configuration" ]

ipgui::add_param -name "MODE" -component $cc -parent $general_group
set_property -dict [list \
  "widget" "comboBox" \
  "display_name" "VIP Mode" \
  "tooltip" "\[MODE\] Defines the mode of operation"
] [ipgui::get_guiparamspec -name "MODE" -component $cc]

set spi_group [ipgui::add_group -name "SPI Configuration" -component $cc \
    -parent $page0 -display_name "SPI Configuration" ]

ipgui::add_param -name "CPOL" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "CPOL" \
  "tooltip" "\[CPOL\] Defines SPI CPOL (serial clock polarity)" \
] [ipgui::get_guiparamspec -name "CPOL" -component $cc]

ipgui::add_param -name "CPHA" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "CPHA" \
  "tooltip" "\[CPHA\] Defines SPI CPHA (serial clock phase)" \
] [ipgui::get_guiparamspec -name "CPHA" -component $cc]

ipgui::add_param -name "INV_CS" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "INV_CS" \
  "tooltip" "\[INV_CS\] Invert CS polarity (if selected, CS is active-high)" \
] [ipgui::get_guiparamspec -name "INV_CS" -component $cc]

ipgui::add_param -name "DATA_DLENGTH" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "DATA_DLENGTH" \
  "tooltip" "\[DATA_DLENGTH\] Define the SPI word length" \
] [ipgui::get_guiparamspec -name "DATA_DLENGTH" -component $cc]

ipgui::add_param -name "DEFAULT_MISO_DATA" -component $cc -parent $general_group
set_property -dict [list \
  "display_name" "Default MISO data" \
  "tooltip" "\[DEFAULT_MISO_DATA\] Default data sent by slave-mode VIP when it has nothing enqueued" \
  "widget" "hexEdit" \
] [ipgui::get_guiparamspec -name DEFAULT_MISO_DATA -component $cc]

ipgui::add_param -name "SLAVE_TIN" -component $cc -parent $model_timing
set_property -dict [list \
  "display_name" "Slave T_in" \
  "tooltip" "\[SLAVE_TIN\] Input delay for slave interface mode."
] [ipgui::get_guiparamspec -name "SLAVE_TIN" -component $cc]

ipgui::add_param -name "SLAVE_TOUT" -component $cc -parent $model_timing
set_property -dict [list \
  "display_name" "Slave T_out" \
  "tooltip" "\[SLAVE_TOUT\] Output delay for slave interface mode."
] [ipgui::get_guiparamspec -name "SLAVE_TOUT" -component $cc]

ipgui::add_param -name "MASTER_TIN" -component $cc -parent $model_timing
set_property -dict [list \
  "display_name" "Master T_in" \
  "tooltip" "\[MASTER_TIN\] Input delay for master interface mode."
] [ipgui::get_guiparamspec -name "MASTER_TIN" -component $cc]

ipgui::add_param -name "MASTER_TOUT" -component $cc -parent $model_timing
set_property -dict [list \
  "display_name" "Master T_out" \
  "tooltip" "\[MASTER_TOUT\] Output delay for master interface mode."
] [ipgui::get_guiparamspec -name "MASTER_TOUT" -component $cc]

ipgui::add_param -name "CS_TO_MISO" -component $cc -parent $model_timing
set_property -dict [list \
  "display_name" "CS to MISO delay" \
  "tooltip" "\[CS_TO_MISO\] Chip-Select to MISO delay for slave interface mode."
] [ipgui::get_guiparamspec -name "CS_TO_MISO" -component $cc]

## Create and save the XGUI file
ipx::create_xgui_files [ipx::current_core]
ipx::save_core $cc