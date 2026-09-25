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

# Set to use SmartConnect or AXI Interconnect
set use_smartconnect 0

# Create the project
#adi_sim_project_xilinx $project_name "xcvm1802-vfvc1760-3HP-e-S"
#adi_sim_project_xilinx $project_name "xcvu9p-flga2104-2L-e"
adi_sim_project_xilinx $project_name "xczu11eg-ffvf1517-2-i";

source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_jesd.tcl
source $ad_tb_dir/library/includes/sp_include_xcvr.tcl

# Add test files to the project
adi_sim_project_files [list \
  "$ad_tb_dir/library/regmaps/adi_regmap_dac_pkg.sv" \
  "$ad_tb_dir/library/regmaps/adi_regmap_common_pkg.sv" \
  "$ad_tb_dir/library/regmaps/adi_regmap_adc_pkg.sv" \
  "custom_test_harness_env.sv" \
  "tests/test_program.sv" \
  "tests/test_program_2.sv" \
  "tests/test_program_3.sv" \
  "tests/test_program_4.sv" \
]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
