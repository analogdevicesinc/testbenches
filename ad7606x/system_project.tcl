source ../scripts/adi_sim.tcl
source ../../scripts/adi_env.tcl
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

set INTF $ad_project_params(INTF)
set NUM_OF_CH $ad_project_params(NUM_OF_CH)

#set a default test program
if {$INTF == 0} {
  if {$NUM_OF_CH == 8} {
    adi_sim_add_define "TEST_PROGRAM=test_program_8ch"
  } elseif {$NUM_OF_CH == 4} {
    adi_sim_add_define "TEST_PROGRAM=test_program_4ch"
  } elseif {$NUM_OF_CH == 6} {
    adi_sim_add_define "TEST_PROGRAM=test_program_6ch"
  }
} else {
  adi_sim_add_define "TEST_PROGRAM=test_program"
}

# Create the project
adi_sim_project_xilinx $project_name "xc7z020clg484-1"

# Add test files to the project
adi_sim_project_files [list \
 "../common/sv/utils.svh" \
 "../common/sv/logger_pkg.sv" \
 "../common/sv/reg_accessor.sv" \
 "../common/sv/m_axis_sequencer.sv" \
 "../common/sv/s_axis_sequencer.sv" \
 "../common/sv/m_axi_sequencer.sv" \
 "../common/sv/s_axi_sequencer.sv" \
 "../common/sv/dmac_api.sv" \
 "../common/sv/adi_regmap_pkg.sv" \
 "../common/sv/adi_regmap_adc_pkg.sv" \
 "../common/sv/adi_regmap_common_pkg.sv" \
 "../common/sv/adi_regmap_dmac_pkg.sv" \
 "../common/sv/adi_regmap_pwm_gen_pkg.sv" \
 "../common/sv/dma_trans.sv" \
 "../common/sv/test_harness_env.sv" \
 "tests/test_program_8ch.sv" \
 "tests/test_program_4ch.sv" \
 "tests/test_program_6ch.sv" \
 "tests/test_program.sv" \
 "system_tb.sv"]

adi_sim_generate $project_name
