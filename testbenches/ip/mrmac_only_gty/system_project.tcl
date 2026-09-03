source ../../../scripts/adi_sim.tcl

if {$argc < 1} {
  puts "Expecting one argument that specifies the test configuration"
  set cfg_file cfg_1x100g.tcl
} else {
  set cfg_file [lindex $argv 0]
}

global ad_project_params
global ad_tb_dir

# Read the configuration. This is what sets ad_project_params(CUSTOM_HARNESS) 1, so
# it MUST be sourced before adi_sim_project_xilinx -- that proc checks the flag
# (adi_sim.tcl:48) to decide whether to build the ADI base test harness. Same
# ordering as the in-repo precedent, testbenches/ip/data_offload_2.
source "cfgs/${cfg_file}"

set project_name [file rootname $cfg_file]

# The part must be passed EXPLICITLY: adi_sim_project_xilinx's part argument defaults
# to a Virtex-7 (xc7vx485tffg1157-1) and it does NOT decode ad_project_params(FPGA_BOARD),
# so omitting it fails with "[BD 5-683] mrmac not supported for the current part".
# xcvc1902-vsva2197-2MP-e-S = VCK190 / Versal AI Core, the same part as the passing
# reference example design.
adi_sim_project_xilinx $project_name "xcvc1902-vsva2197-2MP-e-S"

# No sp_include_axis.tcl / sp_include_scoreboard.tcl here: this bench has no AXIS
# VIPs and no scoreboard (the traffic generator and byte-exact checker are plain RTL
# inside the block design). sp_include_common.tcl, which adi_sim_project_xilinx
# sources unconditionally, already adds logger_pkg + the rest of the base utilities
# and system_tb.sv.
adi_sim_project_files [list \
  "tests/test_program.sv" \
]

adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
