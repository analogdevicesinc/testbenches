source ../../../scripts/adi_sim.tcl
source ../../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

if {$argc < 1} {
  puts "Expecting at least one argument that specifies the test configuration"
  exit 1
} else {
  set cfg_file [lindex $argv 0]
}

# Read common config file
source "cfgs/${cfg_file}"

# Set the project name
set project_name [file rootname $cfg_file]

# Set to use SmartConnect or AXI Interconnect
set use_smartconnect 1

# Create the project
adi_sim_project_xilinx $project_name "xc7z007sclg400-1"

# Add test files to the project
adi_sim_project_files [list \
 "../../../library/utilities/utils.svh" \
 "../../../library/utilities/logger_pkg.sv" \
 "../../../library/utilities/reg_accessor.sv" \
 "../../../library/xilinx_vip/m_axis_sequencer.sv" \
 "../../../library/xilinx_vip/s_axis_sequencer.sv" \
 "../../../library/xilinx_vip/m_axi_sequencer.sv" \
 "../../../library/xilinx_vip/s_axi_sequencer.sv" \
 "../../../library/ips/dmac/dmac_api.sv" \
 "../../../library/utilities/adi_regmap_pkg.sv" \
 "../../../library/ips/adi_regmap_clkgen_pkg.sv" \
 "../../../library/ips/dmac/adi_regmap_dmac_pkg.sv" \
 "../../../library/ips/adi_regmap_pwm_gen_pkg.sv" \
 "../../../library/ips/spi_engine/adi_regmap_spi_engine_pkg.sv" \
 "../../../library/ips/dmac/dma_trans.sv" \
 "../../../library/utilities/test_harness_env.sv" \
 "spi_engine.svh" \
 "tests/test_program.sv" \
 "system_tb.sv" \
 ]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
