source ../../../scripts/adi_sim.tcl

if {$argc < 1} {
  puts "Expecting at least one argument that specifies the test configuration"
  exit 1
} else {
  set cfg_file [lindex $argv 0]
}


source "cfgs/${cfg_file}"


set project_name [file rootname $cfg_file]


adi_sim_project_xilinx $project_name "xcvu9p-flga2104-2L-e"


set gpio_inc_dir "$ad_hdl_dir/library/gpio_adi"


set fileset [get_filesets sim_1]


set_property verilog_include_dirs $gpio_inc_dir $fileset

source $ad_tb_dir/library/includes/sp_include_axis.tcl
source $ad_tb_dir/library/includes/sp_include_scoreboard.tcl
source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_data_offload.tcl


adi_sim_project_files [list \
  "$ad_hdl_dir/library/gpio_adi/gpio_api_pkg.sv" \
  "environment.sv" \
  "tests/test_program.sv" \
]


add_files -fileset sim_1 \
  "$ad_hdl_dir/library/gpio_adi/gpio_definitions.svh"


adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
