source ../scripts/adi_sim.tcl
source ../../scripts/adi_env.tcl
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
 "../common/sv/utils.svh" \
 "../common/sv/logger_pkg.sv" \
 "../common/sv/reg_accessor.sv" \
 "../common/sv/m_axis_sequencer.sv" \
 "../common/sv/s_axis_sequencer.sv" \
 "../common/sv/m_axi_sequencer.sv" \
 "../common/sv/s_axi_sequencer.sv" \
 "../common/sv/spi_vip/adi_spi_vip_pkg.sv" \
 "../common/sv/s_spi_sequencer.sv" \
 "../common/sv/dmac_api.sv" \
 "../common/sv/adi_regmap_pkg.sv" \
 "../common/sv/adi_regmap_clkgen_pkg.sv" \
 "../common/sv/adi_regmap_dmac_pkg.sv" \
 "../common/sv/adi_regmap_pwm_gen_pkg.sv" \
 "../common/sv/adi_regmap_spi_engine_pkg.sv" \
 "../common/sv/dma_trans.sv" \
 "../common/sv/test_harness_env.sv" \
 "../common/sv/spi_engine_instr_pkg.sv" \
 "spi_execution_environment.sv" \
 "tests/test_program.sv" \
 "system_tb.sv" \
 ]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
