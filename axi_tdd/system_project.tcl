source ../scripts/adi_sim.tcl
source ../../library/scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

if {$argc < 1} {
  puts "Expecting at least one argument that specifies the test configuration"
  set cfg_file cfg2.tcl
  #exit 1
} else {
  set cfg_file [lindex $argv 0]
}

# Read common configuration file
source "cfgs/common_cfg.tcl"
# Read configuration file with topology information
source "cfgs/${cfg_file}"

# Set the project name
set project_name [file rootname $cfg_file]

# Create the project
#set bd_design_name "test_harness"
set part "xczu9eg-ffvb1156-2-e"

adi_sim_project_xilinx $project_name $part

set TST $::env(TST)

# Add test files to the project
adi_sim_project_files [list \
 "../common/sv/utils.svh" \
 "../common/sv/logger_pkg.sv" \
 "../common/sv/reg_accessor.sv" \
 "../common/sv/m_axi_sequencer.sv" \
 "environment.sv" \
 "tests/$TST.sv" \
 "system_tb.sv" \
 "axi_tdd_pkg.sv" \
]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=$TST"

adi_sim_generate $project_name
