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

# Set to use SmartConnect or AXI Interconnect
set use_smartconnect 1

# Create the project
adi_sim_project_xilinx $project_name "xc7z007sclg400-1"

source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_spi_engine.tcl
source $ad_tb_dir/library/includes/sp_include_clk_gen.tcl
source $ad_tb_dir/library/includes/sp_include_pwm_gen.tcl

# Add test files to the project.
# Every tests/*.sv is a thin program wrapper that `includes the shared flow
# (tests/ad5529r_test_flow.svh, pulled in via `include, not compiled directly).
adi_sim_project_files [glob "tests/*.sv"]

#set a default test program (run_sim.tcl overrides TEST_PROGRAM per run)
adi_sim_add_define "TEST_PROGRAM=test_streaming"

adi_sim_generate $project_name
