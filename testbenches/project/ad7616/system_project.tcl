source ../../../scripts/adi_sim.tcl
source ../../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

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

set SER_PAR_N $ad_project_params(SER_PAR_N)

#set a default test program
if {$SER_PAR_N == 1} {
  adi_sim_add_define "TEST_PROGRAM=test_program_si"
} elseif {$SER_PAR_N == 0} {
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

# Add test files to the project
adi_sim_project_files [list \
 "../../../library/utilities/utils.svh" \
 "../../../library/utilities/logger_pkg.sv" \
 "../../../library/regmaps/reg_accessor.sv" \
 "../../../library/vip/amd/m_axis_sequencer.sv" \
 "../../../library/vip/amd/s_axis_sequencer.sv" \
 "../../../library/vip/amd/m_axi_sequencer.sv" \
 "../../../library/vip/amd/s_axi_sequencer.sv" \
 "../../../library/drivers/dmac/dmac_api.sv" \
 "../../../library/regmaps/adi_regmap_pkg.sv" \
 "../../../library/regmaps/adi_regmap_axi_ad7616_pkg.sv" \
 "../../../library/regmaps/adi_regmap_clkgen_pkg.sv" \
 "../../../library/regmaps/adi_regmap_dmac_pkg.sv" \
 "../../../library/regmaps/adi_regmap_spi_engine_pkg.sv" \
 "../../../library/regmaps/adi_regmap_pwm_gen_pkg.sv" \
 "../../../library/drivers/dmac/dma_trans.sv" \
 "../../../library/utilities/test_harness_env.sv" \
 "tests/test_program_si.sv" \
 "tests/test_program_pi.sv" \
 "system_tb.sv"]

adi_sim_generate $project_name