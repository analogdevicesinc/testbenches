# List of defines which will be passed to the simulation
variable adi_sim_defines {}
variable design_name "test_harness"

proc adi_sim_add_define {value} {
  global adi_sim_defines
  lappend adi_sim_defines $value
}

proc adi_sim_project_xilinx {project_name {part "xc7vx485tffg1157-1"}} {
  global design_name
  global ad_project_params

  # Create project
  create_project ${project_name} ./runs/${project_name} -part $part -force

  # Set project properties
  set_property -name "default_lib" -value "xil_defaultlib" -objects [current_project]

  # Set IP repository paths
  set_property "ip_repo_paths" "[file normalize "./../../library"] " \
    [get_filesets sources_1]

  # Rebuild user ip_repo's index before adding any source files
  update_ip_catalog -rebuild

  ## Create the bd
  ######################
  create_bd_design $design_name

  global sys_zynq
  set sys_zynq -1
  if { ![info exists ad_project_params(CUSTOM_HARNESS)] || !$ad_project_params(CUSTOM_HARNESS) } {
    source ../common/test_harness/test_harness_system_bd.tcl
  }

  # transfer tcl parameters as defines to verilog
  foreach {k v} [array get ad_project_params] {
    adi_sim_add_define $k=$v
  }

  # Build the test harness based on the topology
  source system_bd.tcl

  save_bd_design
  validate_bd_design

  # Pass the test harness instance name to the simulation
  adi_sim_add_define "TH=$design_name"

  # Use a define for the top module
  adi_sim_add_define "TB=system_tb"
}

proc adi_sim_project_files {project_files} {
  add_files -fileset sim_1 $project_files
  # Set 'sim_1' fileset properties
  set_property -name "top" -value "system_tb" -objects [get_filesets sim_1]
}

proc adi_sim_generate {project_name } {
  global design_name
  global adi_sim_defines

  # Set the defines for simulation
  set_property verilog_define $adi_sim_defines [get_filesets sim_1]

  set_property -name {xsim.simulate.runtime} -value {} -objects [get_filesets sim_1]

  # Show all Xilinx primitives e.g GTYE4_COMMON
  set_property -name {xsim.elaborate.debug_level} -value {all} -objects [get_filesets sim_1]
  # Log all waves
  set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]

  set project_system_dir "./runs/$project_name/$project_name.srcs/sources_1/bd/$design_name"

  generate_target Simulation [get_files $project_system_dir/$design_name.bd]

  set_property include_dirs . [get_filesets sim_1]
}

proc adi_open_project {project_path} {
  open_project $project_path
}

proc adi_update_define {name value} {
  set defines [get_property verilog_define [get_filesets sim_1]]
  set defines_new {}
  foreach def $defines {
    set def [split $def {=}]
    if {[lindex $def 0] == $name} {
      set def [lreplace $def 1 1 $value]
      puts "reaplacing"
      }
    lappend defines_new "[lindex $def 0]=[lindex $def 1]"
  }
  set_property verilog_define $defines_new [get_filesets sim_1]

}

proc adi_project_files {project_files} {

  foreach pfile $project_files {
    if {[string range $pfile [expr 1 + [string last . $pfile]] end] == "xdc"} {
      add_files -norecurse -fileset constrs_1 $pfile
    } else {
      add_files -norecurse -fileset sources_1 $pfile
    }
  }
}
