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

# Aici adaugi directoarele pentru include-uri
set gpio_inc_dir "$ad_hdl_dir/library/gpio_adi"

# Obtine fileset-ul
set fileset [get_filesets sim_1]

# Seteaza include dir pentru compilator
set_property verilog_include_dirs $gpio_inc_dir $fileset

source $ad_tb_dir/library/includes/sp_include_axis.tcl
source $ad_tb_dir/library/includes/sp_include_scoreboard.tcl
source $ad_tb_dir/library/includes/sp_include_dmac.tcl
source $ad_tb_dir/library/includes/sp_include_data_offload.tcl

# Add test files to the project
adi_sim_project_files [list \
  "$ad_hdl_dir/library/gpio_adi/gpio_api_pkg.sv" \
  "environment.sv" \
  "tests/test_program.sv" \
]

# 2. Adaugam definitiile .svh ca surse (nu se includ automat la compile)
add_files -fileset sim_1 \
  "$ad_hdl_dir/library/gpio_adi/gpio_definitions.svh"

#set a default test program
adi_sim_add_define "TEST_PROGRAM=test_program"

adi_sim_generate $project_name
