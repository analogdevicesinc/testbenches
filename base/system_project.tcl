source ../scripts/adi_sim.tcl
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

if {$argc < 1} {
  puts "Expecting at least one argument that specifies the test configuration"
  exit 1
} else {
  set cfg_file [lindex $argv 0]
  if {$argc == 2} {
    set questa_sim [lindex $argv 1]
  } else {
    set questa_sim n
  }
}

# Read config file 
source "cfgs/${cfg_file}"

# Set the project name
set project_name [file rootname $cfg_file]

# Create the project
adi_sim_project_xilinx $project_name "xcvu9p-flga2104-2L-e"

# Add test files to the project
adi_sim_project_files [list \
 "../common/sv/utils.svh" \
 "../common/sv/logger_pkg.sv" \
 "../common/sv/reg_accessor.sv" \
 "../common/sv/m_axis_sequencer.sv" \
 "../common/sv/s_axis_sequencer.sv" \
 "../common/sv/m_axi_sequencer.sv" \
 "../common/sv/s_axi_sequencer.sv" \
 "../common/sv/adi_peripheral_pkg.sv" \
 "../common/sv/adi_regmap_pkg.sv" \
 "../common/sv/test_harness_env.sv" \
 "../common/sv/mailbox.sv" \
 "../common/sv/x_monitor.sv" \
 "../common/sv/scoreboard.sv" \
 "environment.sv" \
 "tests/test_program.sv" \
 "system_tb.sv" \
 ]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name $questa_sim

# Use this only for debugging specific seeds that failed previously
#set_property -name {xsim.simulate.xsim.more_options} -value {-sv_seed 1695199824} -objects [get_filesets sim_1]

