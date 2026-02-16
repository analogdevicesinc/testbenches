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

# Set project params
global ad_project_params

# Set default test program
adi_sim_add_define "TEST_PROGRAM=test_program_drg"

# Set to use SmartConnect
set use_smartconnect 1

# Create the project
adi_sim_project_xilinx $project_name "xc7z020clg484-1"

# Add test files to the project
adi_sim_project_files [list \
  "$ad_tb_dir/library/regmaps/adi_regmap_pkg.sv" \
  "$ad_tb_dir/library/regmaps/adi_regmap_common_pkg.sv" \
  "tests/test_program_drg.sv" \
]

adi_sim_generate $project_name
