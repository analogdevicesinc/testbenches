source ../../../scripts/adi_sim.tcl

if {$argc < 1} {
  puts "Expecting at least one argument that specifies the test configuration"
  exit 1
} else {
  set cfg_file [lindex $argv 0]
}

source "cfgs/${cfg_file}"

set project_name [file rootname $cfg_file]

adi_sim_project_xilinx $project_name

source $ad_tb_dir/library/includes/sp_include_pwm_gen.tcl

adi_sim_project_files [list \
 "pwmgen_environment.sv" \
 "tests/test_program.sv" \
 ]

adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name