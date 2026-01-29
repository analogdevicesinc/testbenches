source ../../../scripts/adi_sim.tcl

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
adi_sim_project_xilinx $project_name

source $ad_tb_dir/library/includes/sp_include_axis.tcl
source $ad_tb_dir/library/includes/sp_include_scoreboard.tcl

# Add test files to the project
adi_sim_project_files [list \
  "environment.sv" \
  "tests/test_program.sv" \
  "tests/test_tkeep.sv" \
]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
