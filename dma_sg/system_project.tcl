source ../scripts/adi_sim.tcl
source ../../scripts/adi_env.tcl
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
 "../common/sv/m_axis_sequencer.sv" \
 "../common/sv/s_axis_sequencer.sv" \
 "../common/sv/dmac_api.sv" \
 "../common/sv/adi_regmap_dmac_pkg.sv" \
 "../common/sv/dma_trans.sv" \
 "tests/test_program_1d.sv" \
 "tests/test_program_2d.sv" \
 "tests/test_program_tr_queue.sv" \
 ]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program_1d"

adi_sim_generate $project_name