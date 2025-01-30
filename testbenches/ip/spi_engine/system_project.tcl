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

# Create the project
adi_sim_project_xilinx $project_name "xc7z007sclg400-1"

source $ad_tb_dir/library/includes/sp_include_axis.tcl
source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_spi_engine.tcl

# Add test files to the project
adi_sim_project_files [list \
 "$ad_tb_dir/library/regmaps/adi_regmap_clkgen_pkg.sv" \
 "$ad_tb_dir/library/regmaps/adi_regmap_pwm_gen_pkg.sv" \
 "spi_environment.sv" \
 "tests/test_program.sv" \
 "tests/test_sleep_delay.sv" \
 "tests/test_slowdata.sv" \
 ]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
