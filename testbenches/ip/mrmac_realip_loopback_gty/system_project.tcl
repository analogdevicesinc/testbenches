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

# Create the project (builds the base test_harness + sources system_bd.tcl).
# The part MUST be passed explicitly: adi_sim_project_xilinx's part arg defaults
# to the Virtex-7 xc7vx485tffg1157-1 and it does NOT read ad_project_params(FPGA_BOARD),
# so an omitted part silently falls back to Virtex-7 -> mrmac (a Versal-only IP)
# fails create_bd_cell with "[BD 5-683] ... not supported for the current part".
# Pass the VCK190 (Versal AI Core, GTY) part explicitly. This is the decoded
# value of ad_project_params(FPGA_BOARD)="vck190" (adi_project_xilinx.tcl _vck190
# branch) and matches the user's VCK190/GTY reference example mrmac_0_ex exactly
# (xcvc1902-vsva2197-2MP-e-S). GTY (not GTM) is the whole reason for the pivot:
# its boolean serial p/n pins carry real data so the TB loopback is a plain wire.
adi_sim_project_xilinx $project_name "xcvc1902-vsva2197-2MP-e-S"

# AXI-Stream VIP + byte-scoreboard packages (same as the behavioral loopback).
source $ad_tb_dir/library/includes/sp_include_axis.tcl
source $ad_tb_dir/library/includes/sp_include_scoreboard.tcl

# Add test files to the project
adi_sim_project_files [list \
  "environment.sv" \
  "tests/test_program.sv" \
]

# set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
