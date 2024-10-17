source ../../../scripts/adi_sim.tcl
source ../../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

if {$argc < 1} {
  puts "Expecting at least one argument that specifies the test configuration"
  exit 1
} else {
  set cfg_file [lindex $argv 0]
}

# Read config file 
source "cfgs/${cfg_file}"

# Set the project name
set project_name [file rootname $cfg_file]

# Create the project
adi_sim_project_xilinx $project_name "xcvu9p-flga2104-2L-e"

# Add test files to the project
adi_sim_project_files [list \
 "../../../library/utilities/utils.svh" \
 "../../../library/utilities/logger_pkg.sv" \
 "../../../library/regmaps/reg_accessor.sv" \
 "../../../library/vip/amd/m_axis_sequencer.sv" \
 "../../../library/vip/amd/s_axis_sequencer.sv" \
 "../../../library/vip/amd/m_axi_sequencer.sv" \
 "../../../library/vip/amd/s_axi_sequencer.sv" \
 "../../../library/regmaps/adi_peripheral_pkg.sv" \
 "../../../library/regmaps/adi_regmap_pkg.sv" \
 "../../../library/utilities/test_harness_env.sv" \
 "../../../library/drivers/common/mailbox.sv" \
 "../../../library/drivers/common/x_monitor.sv" \
 "../../../library/drivers/common/scoreboard.sv" \
 "../../../library/drivers/dmac/dmac_api.sv" \
 "../../../library/drivers/dmac/dma_trans.sv" \
 "../../../library/regmaps/adi_regmap_dmac_pkg.sv" \
 "../../../library/drivers/data_offload/data_offload_api.sv" \
 "../../../library/regmaps/adi_regmap_data_offload_pkg.sv" \
 "environment.sv" \
 "tests/test_program.sv" \
 "system_tb.sv" \
 ]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
