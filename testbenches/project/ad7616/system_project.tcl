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

set INTF $ad_project_params(INTF)

#set a default test program
if {$INTF == 1} {
  adi_sim_add_define "TEST_PROGRAM=test_program_si"
} elseif {$INTF == 0} {
  adi_sim_add_define "TEST_PROGRAM=test_program_pi"
} else {
  adi_sim_add_define "TEST_PROGRAM=test_program_si"
}

#global mng_axi_cfg
global use_smartconnect
if {[expr {![info exists use_smartconnect]}]} {
  set use_smartconnect 1
}

# Create the project
adi_sim_project_xilinx $project_name "xc7z020clg484-1"

source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_spi_engine.tcl

# Add test files to the project
adi_sim_project_files [list \
  "$ad_tb_dir/library/regmaps/adi_regmap_adc_pkg.sv" \
  "$ad_tb_dir/library/regmaps/adi_regmap_common_pkg.sv" \
  "$ad_tb_dir/library/regmaps/adi_regmap_clkgen_pkg.sv" \
  "$ad_tb_dir/library/regmaps/adi_regmap_pwm_gen_pkg.sv" \
  "tests/test_program_si.sv" \
  "tests/test_program_pi.sv" \
]

adi_sim_generate $project_name

# Use this only for debugging specific seeds that failed previously
#set_property -name {xsim.simulate.xsim.more_options} -value {-sv_seed 1695199824} -objects [get_filesets sim_1]
