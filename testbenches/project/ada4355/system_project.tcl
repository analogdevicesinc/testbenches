source ../../../scripts/adi_sim.tcl

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

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

# Create the project
adi_sim_project_xilinx $project_name "xc7z020clg484-1" ;

# Source the include files for package dependencies
source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_converter.tcl

# Add test files to the project
adi_sim_project_files [list \
 "tests/test_program.sv" \
 ]

adi_sim_generate $project_name
