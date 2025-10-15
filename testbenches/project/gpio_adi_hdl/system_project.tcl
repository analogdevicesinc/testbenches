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

# Create the project
adi_sim_project_xilinx $project_name "xcvu9p-flga2104-2L-e"

# Directoare pentru include-uri
set gpio_inc_dir "$ad_hdl_dir/library/gpio_adi"
set fileset [get_filesets sim_1]
set_property verilog_include_dirs $gpio_inc_dir $fileset

# Include scripturi adi
source $ad_tb_dir/library/includes/sp_include_axis.tcl
source $ad_tb_dir/library/includes/sp_include_scoreboard.tcl
source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_data_offload.tcl


# Include fisiere HDL (proiectul gpio_adi)

adi_sim_project_files [list \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/coraz7s/coraz7s_system_constr.xdc" \
  "$ad_hdl_dir/library/axi_gpio_adi/axi_gpio_adi.v" \
  "$ad_hdl_dir/projects/gpio_adi/coraz7s/system_top.v" \
]

# Include fisiere testbench + API

adi_sim_project_files [list \
  "$ad_hdl_dir/library/gpio_adi/gpio_api_pkg.sv" \
  "environment.sv" \
  "tests/test_program_gpio.sv" \
]

# Include definitii .svh
add_files -fileset sim_1 \
  "$ad_hdl_dir/library/gpio_adi/gpio_definitions.svh"

# Set default test program
adi_sim_add_define "TEST_PROGRAM_GPIO=test_program_gpio"

# Genereaza proiectul
adi_sim_generate $project_name

