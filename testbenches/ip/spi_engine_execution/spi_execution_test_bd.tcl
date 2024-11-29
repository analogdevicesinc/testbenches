###############################################################################
## Copyright (C) 2024 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################
puts "spi execution test bd"
source $ad_hdl_dir/library/spi_engine/scripts/spi_engine.tcl

set data_width              $ad_project_params(DATA_WIDTH)
set num_cs                  $ad_project_params(NUM_OF_CS)
set num_sdi                 $ad_project_params(NUM_OF_SDI)
set num_sdo                 $ad_project_params(NUM_OF_SDO)
set sdi_delay               $ad_project_params(SDI_DELAY)
set echo_sclk               $ad_project_params(ECHO_SCLK)

create_bd_intf_port -mode Monitor -vlnv analog.com:interface:spi_engine_rtl:1.0 spi_execution_spi
create_bd_intf_port -mode Slave  -vlnv analog.com:interface:spi_engine_ctrl_rtl:1.0 s_spi_execution_ctrl
create_bd_port -dir O  spi_execution_trigger

set execution spi_execution
ad_ip_instance spi_engine_execution $execution
ad_ip_parameter $execution CONFIG.DATA_WIDTH $data_width
ad_ip_parameter $execution CONFIG.NUM_OF_CS $num_cs
ad_ip_parameter $execution CONFIG.NUM_OF_SDI $num_sdi
ad_ip_parameter $execution CONFIG.SDO_DEFAULT 1
ad_ip_parameter $execution CONFIG.SDI_DELAY $sdi_delay
ad_ip_parameter $execution CONFIG.ECHO_SCLK $echo_sclk

ad_ip_instance axi_clkgen spi_clkgen
ad_ip_parameter spi_clkgen CONFIG.CLK0_DIV 5
ad_ip_parameter spi_clkgen CONFIG.VCO_DIV 1
ad_ip_parameter spi_clkgen CONFIG.VCO_MUL 8

ad_ip_instance axi_pwm_gen spi_engine_trigger_gen
ad_ip_parameter spi_engine_trigger_gen CONFIG.PULSE_0_PERIOD 120
ad_ip_parameter spi_engine_trigger_gen CONFIG.PULSE_0_WIDTH 1

ad_connect $sys_cpu_clk spi_clkgen/clk
ad_connect spi_clk spi_clkgen/clk_0

ad_connect spi_clk spi_engine_trigger_gen/ext_clk
ad_connect $sys_cpu_clk spi_engine_trigger_gen/s_axi_aclk
ad_connect sys_cpu_resetn spi_engine_trigger_gen/s_axi_aresetn
ad_connect spi_engine_trigger_gen/pwm_0 spi_execution_trigger

ad_connect $execution/spi spi_execution_spi
ad_connect $execution/ctrl s_spi_execution_ctrl

ad_connect spi_clk $execution/clk
ad_connect sys_cpu_resetn $execution/resetn

ad_cpu_interconnect 0x44a70000 spi_clkgen
ad_cpu_interconnect 0x44b00000 spi_engine_trigger_gen

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1

if {$ad_project_params(ECHO_SCLK)} {
  adi_sim_add_define DEF_ECHO_SCLK
}