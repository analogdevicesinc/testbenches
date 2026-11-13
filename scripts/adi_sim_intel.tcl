###############################################################################
## Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# The environment is built in three steps: quartus_sh creates the Quartus
# project, qsys-script builds the test harness from the configuration and
# qsys-generate writes its simulation model. The Questa libraries of the model
# are compiled once per configuration, the test bench files on every run.

variable adi_sim_files {}
variable design_name "test_harness"

global ad_hdl_dir
global ad_tb_dir

source ../../../scripts/adi_tb_env.tcl
source $ad_tb_dir/scripts/adi_sim_intel_qsys.tcl

proc adi_part_decode {board_name} {

  switch $board_name {
    "a5e" {
      set part_name "A5ED065BB32AE6SR0"
    }
    "fm87" {
      set part_name "AGIB027R31B1E1V"
    }
    default {
      error "ERROR: Unknown board '$board_name'"
    }
  }

  return $part_name
}

proc adi_family_decode {board_name} {

  switch $board_name {
    "a5e" {
      set family "Agilex 5"
    }
    "fm87" {
      set family "Agilex 7"
    }
    default {
      error "ERROR: Unknown board '$board_name'"
    }
  }

  return $family
}

proc adi_sim_project_intel {project_name} {
  global design_name
  global ad_project_params
  global ad_hdl_dir
  global ad_tb_dir
  global adi_sim_defines
  global quartus

  if {![info exists ad_project_params(FPGA_BOARD)]} {
    set ad_project_params(FPGA_BOARD) "a5e"
  }
  set board $ad_project_params(FPGA_BOARD)
  set ad_project_params(FPGA_PART) [adi_part_decode $board]
  set family [adi_family_decode $board]
  set part $ad_project_params(FPGA_PART)
  puts "INFO: Using board '$board' with part '$part'"

  set run_dir [file normalize ./runs/${project_name}]
  set qsys_bin $quartus(quartus_rootpath)/sopc_builder/bin

  # project_new changes the working directory to the project
  set project_dir [pwd]
  project_new $run_dir/$project_name -overwrite

  set lib_dirs "$ad_hdl_dir/library/**/*;$ad_tb_dir/library/**/*"
  set_global_assignment -name IP_SEARCH_PATHS $lib_dirs
  set_global_assignment -name FAMILY $family
  set_global_assignment -name DEVICE $part

  project_close
  cd $project_dir

  set qsys_defines_file $run_dir/qsys_defines.txt
  set QFILE [open "$run_dir/system_qsys_script.tcl" "w"]
  puts $QFILE "package require qsys"
  puts $QFILE "set ad_hdl_dir $ad_hdl_dir"
  puts $QFILE "set ad_tb_dir $ad_tb_dir"
  puts $QFILE "source $ad_tb_dir/scripts/adi_sim_intel_qsys.tcl"
  puts $QFILE "set_module_property NAME {$design_name}"
  puts $QFILE "set_project_property DEVICE_FAMILY {$family}"
  puts $QFILE "set_project_property DEVICE $part"
  puts $QFILE [list array set ad_project_params [array get ad_project_params]]
  if { ![info exists ad_project_params(CUSTOM_HARNESS)] || !$ad_project_params(CUSTOM_HARNESS) } {
    puts $QFILE "source $ad_tb_dir/library/utilities/test_harness_system_qsys.tcl"
  }
  puts $QFILE "source [file normalize system_bd.tcl]"
  puts $QFILE "set_domain_assignment {\$system} {qsys_mm.maxAdditionalLatency} {4}"
  puts $QFILE "set_domain_assignment {\$system} {qsys_mm.clockCrossingAdapter} {AUTO}"
  puts $QFILE "set_domain_assignment {\$system} {qsys_mm.burstAdapterImplementation} {PER_BURST_TYPE_CONVERTER}"
  puts $QFILE "save_system {$run_dir/$design_name.qsys}"
  puts $QFILE "adi_sim_write_defines $qsys_defines_file"
  close $QFILE

  # The Platform Designer tools do not take IP_SEARCH_PATHS from the project
  set search_path "$ad_hdl_dir/library/**/*,$ad_tb_dir/library/**/*,\$"

  exec -ignorestderr $qsys_bin/qsys-script \
    --quartus-project=$run_dir/$project_name \
    --search-path=$search_path \
    --script=$run_dir/system_qsys_script.tcl >@ stdout

  exec -ignorestderr $qsys_bin/qsys-generate $run_dir/$design_name.qsys \
    --simulation=VERILOG \
    --family=$family \
    --part=$part \
    --quartus-project=$run_dir/$project_name \
    --search-path=$search_path \
    --output-directory=$run_dir/$design_name >@ stdout

  # qsys-generate only reports the errors, the simulation model is missing
  # when the generation failed
  if {![file exists $run_dir/$design_name/sim/mentor/msim_setup.tcl]} {
    error "ERROR: Platform Designer generation of $design_name failed"
  }

  foreach {k v} [array get ad_project_params] {
    if { [llength $ad_project_params($k)] == 1} {
      adi_sim_add_define $k=$v
    } else {
      foreach {h v} $ad_project_params($k) {
        adi_sim_add_define ${k}_${h}=$v
      }
    }
  }

  # after the parameters, so a define of the test harness overrides them, as
  # in the Vivado flow (e.g. the quoted JESD_MODE)
  set fh [open $qsys_defines_file r]
  foreach define [split [string trim [read $fh]] "\n"] {
    adi_sim_add_define $define
  }
  close $fh

  set outfile [open "$run_dir/parameters.log" w+]
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

  adi_sim_add_define "TH=$design_name"

  adi_sim_add_define "TB=system_tb"

  source $ad_tb_dir/library/includes/sp_include_common_intel.tcl
}

proc adi_sim_project_files {project_files} {
  global adi_sim_files

  foreach pfile $project_files {
    set pfile [file normalize $pfile]
    if {[lsearch -exact $adi_sim_files $pfile] == -1} {
      lappend adi_sim_files $pfile
    }
  }
}

# Questa compiles the files in command line order, a package has to come
# before every file that imports it.
proc adi_sim_sort_files {files} {
  global adi_sim_pkg_file
  global adi_sim_file_deps
  global adi_sim_sorted

  array unset adi_sim_pkg_file
  array unset adi_sim_file_deps
  set adi_sim_sorted {}

  foreach f $files {
    set fh [open $f r]
    set text($f) [read $fh]
    close $fh
    foreach {match pkg} [regexp -all -inline -line {^\s*package\s+(\w+)\s*;} $text($f)] {
      set adi_sim_pkg_file($pkg) $f
    }
  }

  foreach f $files {
    set adi_sim_file_deps($f) {}
    foreach {match pkg} [regexp -all -inline {(\w+)::} $text($f)] {
      if {[info exists adi_sim_pkg_file($pkg)] && $adi_sim_pkg_file($pkg) ne $f} {
        lappend adi_sim_file_deps($f) $adi_sim_pkg_file($pkg)
      }
    }
  }

  foreach f $files {
    adi_sim_visit_file $f {}
  }

  return $adi_sim_sorted
}

proc adi_sim_visit_file {f path} {
  global adi_sim_file_deps
  global adi_sim_sorted

  if {[lsearch -exact $adi_sim_sorted $f] != -1} {
    return
  }
  if {[lsearch -exact $path $f] != -1} {
    error "ERROR: Circular package dependency through $f"
  }
  foreach dep [lsort -unique $adi_sim_file_deps($f)] {
    adi_sim_visit_file $dep [concat $path [list $f]]
  }
  lappend adi_sim_sorted $f
}

proc adi_sim_generate {project_name} {
  global design_name
  global adi_sim_defines
  global adi_sim_files

  set run_dir [file normalize ./runs/${project_name}]

  set sources {}
  set include_dirs [list [file normalize .]]
  foreach f $adi_sim_files {
    if {[file extension $f] eq ".svh"} {
      lappend include_dirs [file dirname $f]
    } else {
      lappend sources $f
    }
  }

  set fh [open $run_dir/sim_files.f w]
  foreach dir [lsort -unique $include_dirs] {
    puts $fh "+incdir+$dir"
  }
  # The test program is selected on every run. The quotes of string values
  # are kept only when escaped in the argument file.
  foreach define $adi_sim_defines {
    if {![string match "TEST_PROGRAM=*" $define]} {
      puts $fh "+define+[string map {\" \\\"} $define]"
    }
  }
  foreach f [adi_sim_sort_files $sources] {
    puts $fh $f
  }
  close $fh

  # Compile the device and the test harness libraries
  set DFILE [open "$run_dir/compile_libs.do" "w"]
  puts $DFILE "onerror {quit -f -code 1}"
  puts $DFILE "set QSYS_SIMDIR $run_dir/$design_name/sim"
  # msim_setup compiles the .v files as SystemVerilog too, util_pack uses
  # interconnect, a keyword since IEEE 1800-2012, as a signal name.
  # IP7521SERDES_UX_SIMSPEED selects the fast simulation models of the GTS
  # transceivers.
  puts $DFILE "set USER_DEFINED_VERILOG_COMPILE_OPTIONS {-sv09compat +define+IP7521SERDES_UX_SIMSPEED}"
  puts $DFILE "source \$QSYS_SIMDIR/mentor/msim_setup.tcl"
  puts $DFILE "dev_com"
  puts $DFILE "com"
  puts $DFILE "quit -f"
  close $DFILE

  set cwd [pwd]
  cd $run_dir
  set status [catch {exec -ignorestderr vsim -c -do compile_libs.do >@ stdout} result]
  cd $cwd
  if {$status} {
    error "ERROR: Compiling the simulation libraries failed: $result"
  }
}
