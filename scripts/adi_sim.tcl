# List of defines which will be passed to the simulation
variable adi_sim_defines {}
variable design_name "test_harness"

global ad_hdl_dir
global ad_tb_dir

source ../../../scripts/adi_tb_env.tcl

source $ad_hdl_dir/projects/scripts/adi_board.tcl
source $ad_hdl_dir/projects/xcvr_wizard/scripts/adi_xcvr_xilinx.tcl

proc adi_sim_add_define {value} {
  global adi_sim_defines
  lappend adi_sim_defines $value
}

proc adi_part_decode {board_name} {

  switch $board_name {
    "zed" {
      set part_name "xc7z020clg484-1"
    }
    "zc702" {
      set part_name "xc7z020clg484-1"
    }
    "microzed" {
      set part_name "xc7z010clg400-1"
    }
    "zc706" {
      set part_name "xc7z045ffg900-2"
    }
    "mitx045" {
      set part_name "xc7z045ffg900-2"
    }
    "coraz7s" {
      set part_name "xc7z007sclg400-1"
    }
    "zcu102" {
      set part_name "xczu9eg-ffvb1156-2-e"
    }
    "kv260" {
      set part_name "xck26-sfvc784-2LV-c"
    }
    "k26" {
      set part_name "xck26-sfvc784-2LVI-i"
    }
    "ac701" {
      set part_name "xc7a200tfbg676-2"
    }
    "kc705" {
      set part_name "xc7k325tffg900-2"
    }
    "kcu105" {
      set part_name "xcku040-ffva1156-2-e"
    }
    "vc707" {
      set part_name "xc7vx485tffg1761-2"
    }
    "vc709" {
      set part_name "xc7vx690tffg1761-2"
    }
    "vcu118" {
      set part_name "xcvu9p-flga2104-2L-e"
    }
    "vcu128" {
      set part_name "xcvu37p-fsvh2892-2L-e"
    }
    "vmk180" {
      set part_name "xcvm1802-vsva2197-2MP-e-S"
    }
    "vmk180_es1" {
      set part_name "xcvm1802-vsva2197-2MP-e-S-es1"
    }
    "vck190" {
      set part_name "xcvc1902-vsva2197-2MP-e-S"
    }
    "vpk180" {
      set part_name "xcvp1802-lsvc4072-2MP-e-S"
    }
    default {
      error "ERROR: Unknown board '$board_name'"
    }
  }

  return $part_name
}

proc adi_board_decode {part_name} {

  switch $part_name {
    "xc7z020clg484-1" {
      puts "WARNING: Multiple boards use part '$part_name' (zed, zc702). Using 'zed' as default. To specify a different board, set FPGA_BOARD in ad_project_params."
      set board_name "zed"
    }
    "xc7z045ffg900-2" {
      puts "WARNING: Multiple boards use part '$part_name' (zc706, mitx045). Using 'zc706' as default. To specify a different board, set FPGA_BOARD in ad_project_params."
      set board_name "zc706"
    }
    "xc7z007sclg400-1" {
      set board_name "coraz7s"
    }
    "xc7z010clg400-1" {
      set board_name "microzed"
    }
    "xczu9eg-ffvb1156-2-e" {
      set board_name "zcu102"
    }
    "xck26-sfvc784-2LV-c" {
      set board_name "kv260"
    }
    "xck26-sfvc784-2LVI-i" {
      set board_name "k26"
    }
    "xc7a200tfbg676-2" {
      set board_name "ac701"
    }
    "xc7k325tffg900-2" {
      set board_name "kc705"
    }
    "xcku040-ffva1156-2-e" {
      set board_name "kcu105"
    }
    "xc7vx485tffg1761-2" {
      set board_name "vc707"
    }
    "xc7vx690tffg1761-2" {
      set board_name "vc709"
    }
    "xcvu9p-flga2104-2L-e" {
      set board_name "vcu118"
    }
    "xcvu37p-fsvh2892-2L-e" {
      set board_name "vcu128"
    }
    "xcvm1802-vsva2197-2MP-e-S" {
      set board_name "vmk180"
    }
    "xcvm1802-vsva2197-2MP-e-S-es1" {
      set board_name "vmk180_es1"
    }
    "xcvc1902-vsva2197-2MP-e-S" {
      set board_name "vck190"
    }
    "xcvp1802-lsvc4072-2MP-e-S" {
      set board_name "vpk180"
    }
    default {
      error "ERROR: Unknown part '$part_name'"
    }
  }

  return $board_name
}

proc adi_resolve_fpga_target {} {
  global ad_project_params

  set board_name ""
  set part_name ""

  set has_part [info exists ad_project_params(FPGA_PART)]
  set has_board [info exists ad_project_params(FPGA_BOARD)]

  if {$has_part && $has_board} {
    # Both are present - validate they match
    set part_name $ad_project_params(FPGA_PART)
    set board_name $ad_project_params(FPGA_BOARD)

    set decoded_part [adi_part_decode $board_name]

    if {[string compare $decoded_part $part_name] != 0} {
      error "ERROR: FPGA_PART '$part_name' does not match decoded part '$decoded_part' from board '$board_name'"
    }

  } elseif {$has_part && !$has_board} {
    set part_name $ad_project_params(FPGA_PART)
    set board_name [adi_board_decode $part_name]

    if {$board_name eq ""} {
      error "ERROR: Could not decode board name from part '$part_name'"
    }
    set ad_project_params(FPGA_BOARD) $board_name

  } elseif {!$has_part && $has_board} {
    set board_name $ad_project_params(FPGA_BOARD)
    set part_name [adi_part_decode $board_name]

    if {$part_name eq ""} {
      error "ERROR: Could not decode part name from board '$board_name'"
    }
    set ad_project_params(FPGA_PART) $part_name

  } else {
    # Set a random board
    set board_no [expr {int(rand()*20)}]

    switch $board_no {
        0  { set board_name "zed" }
        1  { set board_name "zc702" }
        2  { set board_name "microzed" }
        3  { set board_name "zc706" }
        4  { set board_name "mitx045" }
        5  { set board_name "coraz7s" }
        6  { set board_name "zcu102" }
        7  { set board_name "kv260" }
        8  { set board_name "k26" }
        9  { set board_name "ac701" }
        10 { set board_name "kc705" }
        11 { set board_name "kcu105" }
        12 { set board_name "vc707" }
        13 { set board_name "vc709" }
        14 { set board_name "vcu118" }
        15 { set board_name "vcu128" }
        16 { set board_name "vmk180" }
        17 { set board_name "vmk180_es1" }
        18 { set board_name "vck190" }
        19 { set board_name "vpk180" }
        default {
            error "ERROR: board_no invalid '$board_no'"
        }
    }

    # Neither is present
    puts "WARNING: Neither FPGA_PART nor FPGA_BOARD is defined in ad_project_params. Board name was randomized '$board_name'"

    set part_name [adi_part_decode $board_name]
    set ad_project_params(FPGA_BOARD) $board_name
    set ad_project_params(FPGA_PART) $part_name
  }
}

proc adi_xcvr_sim_init {} {
  global ad_project_params

  # Clear environment variables
  foreach var {CFG TST MODE MAKEFLAGS} {
    if {[info exists ::env($var)]} {
      unset ::env($var)
    }
  }

  # Get XCVR parameters from ad_project_params or defaults
  set lane_rate $ad_project_params(LANE_RATE)
  set ref_clk   $ad_project_params(REF_CLK_RATE)
  set pll_type  $ad_project_params(PLL_TYPE)
  set board_name $ad_project_params(FPGA_BOARD)

  set xcvr_config_paths [adi_xcvr_project [list \
    LANE_RATE $lane_rate \
    REF_CLK   $ref_clk \
    PLL_TYPE  $pll_type \
  ] $board_name]

  puts "INFO: XCVR config - LANE_RATE: $lane_rate, REF_CLK: $ref_clk, PLL_TYPE: $pll_type"

  return $xcvr_config_paths
}

proc adi_sim_project_xilinx {project_name {part "xc7vx485tffg1157-1"}} {
  global design_name
  global ad_project_params
  global use_smartconnect
  global ad_hdl_dir
  global ad_tb_dir
  global xcvr_config_required
  global xcvr_config_paths

  adi_resolve_fpga_target
  puts "INFO: Using board '$ad_project_params(FPGA_BOARD)' with part '$ad_project_params(FPGA_PART)'"

  set part $ad_project_params(FPGA_PART)

  if {[info exists xcvr_config_required]} {

    if {$xcvr_config_required == 1} {
      set xcvr_config_paths [adi_xcvr_sim_init]
    }
  }

  # Create project
  create_project ${project_name} ./runs/${project_name} -part $part -force

  # Set project properties
  set_property -name "default_lib" -value "xil_defaultlib" -objects [current_project]

  # Set IP repository paths
  set lib_dirs $ad_hdl_dir/library
  lappend lib_dirs "$ad_tb_dir/library"
  set_property ip_repo_paths $lib_dirs \
    [get_filesets sources_1]

  # Rebuild user ip_repo's index before adding any source files
  update_ip_catalog -rebuild

  ## Create the bd
  ######################
  create_bd_design $design_name

  global sys_zynq
  set sys_zynq -1
  if { ![info exists ad_project_params(CACHE_COHERENCY)] } {
    set CACHE_COHERENCY false
  }
  if { ![info exists ad_project_params(CUSTOM_HARNESS)] || !$ad_project_params(CUSTOM_HARNESS) } {
    source $ad_tb_dir/library/utilities/test_harness_system_bd.tcl
  }

  # transfer tcl parameters as defines to verilog
  foreach {k v} [array get ad_project_params] {
    if { [llength $ad_project_params($k)] == 1} {
      adi_sim_add_define $k=$v
    } else {
      foreach {h v} $ad_project_params($k) {
        adi_sim_add_define ${k}_${h}=$v
      }
    }
  }

  # write tcl parameters into a file
  set outfile [open "./runs/${project_name}/parameters.log" w+]
  puts $outfile "Configuration parameters\n"
  foreach name [array names ad_project_params] {
    if { [llength $ad_project_params($name)] == 1} {
      puts $outfile "$name : $ad_project_params($name)"
    } else {
      puts $outfile "$name :"
      foreach {k v} $ad_project_params($name) {
        puts $outfile "  $k : $v"
      }
    }
  }
  close $outfile

  # Build the test harness based on the topology
  source system_bd.tcl

  save_bd_design
  validate_bd_design

  # Pass the test harness instance name to the simulation
  adi_sim_add_define "TH=$design_name"

  # Use a define for the top module
  adi_sim_add_define "TB=system_tb"

  source $ad_tb_dir/library/includes/sp_include_common.tcl
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

  set_property -name {xsim.simulate.xsim.more_options} -value {-sv_seed random} -objects [get_filesets sim_1]

  set project_system_dir "./runs/$project_name/$project_name.srcs/sources_1/bd/$design_name"

  generate_target Simulation [get_files $project_system_dir/$design_name.bd]

  set_property include_dirs . [get_filesets sim_1]

  set_msg_config -string mb_reset -suppress
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
