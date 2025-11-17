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

set LVDS_CMOS_N $ad_project_params(LVDS_CMOS_N)

#set a default test program
if {$LVDS_CMOS_N == 1} {
  adi_sim_add_define "TEST_PROGRAM=test_program_lvds"
} elseif {$LVDS_CMOS_N == 0} {
  adi_sim_add_define "TEST_PROGRAM=test_program_cmos"
} else {
  error "ERROR: Invalid LVDS_CMOS_N value. Expected 0 or 1."
}

# Set to use SmartConnect
set use_smartconnect 1

# Create the project
adi_sim_project_xilinx $project_name "xc7z020clg484-1"

source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_pwm_gen.tcl
source $ad_tb_dir/library/includes/sp_include_clk_gen.tcl
source $ad_tb_dir/library/includes/sp_include_converter.tcl

# Add test files to the project
adi_sim_project_files [list \
  "tests/test_program_cmos.sv" \
  "tests/test_program_lvds.sv" \
]

adi_sim_generate $project_name

# Use this only for debugging specific seeds that failed previously
#set_property -name {xsim.simulate.xsim.more_options} -value {-sv_seed 1695199824} -objects [get_filesets sim_1]
