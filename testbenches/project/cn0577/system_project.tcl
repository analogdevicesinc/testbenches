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

# Set project params
global ad_project_params

set TWOLANES $ad_project_params(TWOLANES)
set ADC_RES $ad_project_params(ADC_RES)

# Set to use SmartConnect or AXI Interconnect
set use_smartconnect 1

# Create the project
adi_sim_project_xilinx $project_name "xc7z007sclg400-1"

source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_pwm_gen.tcl

# Add test files to the project
adi_sim_project_files [list \
  "$ad_tb_dir/library/regmaps/adi_regmap_adc_pkg.sv" \
  "$ad_tb_dir/library/regmaps/adi_regmap_common_pkg.sv" \
  "cn0577_environment.sv" \
  "tests/test_program.sv" \
]

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
