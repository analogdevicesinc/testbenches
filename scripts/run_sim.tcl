
set script_path [ file dirname [ file normalize [ info script ] ] ]
source $script_path/adi_sim.tcl

if {$argc < 3} {
  puts "Expecting at least one argument that specifies the test configuration and procedure"
  exit 1
} else {
  set topology_file [lindex $argv 0]
  set test_program [lindex $argv 1]
  set mode [lindex $argv 2]
}

# Optional 4th arg: fixed SV seed for reproducible runs. Empty -> keep the
# project default (-sv_seed random, set in adi_sim.tcl).
set sv_seed ""
if {$argc >= 4} {
  set sv_seed [lindex $argv 3]
}

# Set the project name
set project_name [file rootname $topology_file]

adi_open_project "runs/$project_name/$project_name.xpr"

adi_update_define TEST_PROGRAM $test_program

# Override the random seed with a fixed value when SEED was passed in.
if {$sv_seed ne ""} {
  puts "run_sim: forcing -sv_seed $sv_seed"
  set_property -name {xsim.simulate.xsim.more_options} \
    -value "-sv_seed $sv_seed" -objects [get_filesets sim_1]
}

launch_simulation

if {$mode == "gui"} {
  log_wave -r {/system_tb/test_harness/DUT}

  set wave_file waves/$topology_file.wcfg
  if {[file exists $wave_file] == 0} {
    if {[file exists waves] == 0} {
      file mkdir waves
    }
    create_wave_config
    save_wave_config $wave_file
  } else {
    open_wave_config $wave_file
  }
  add_files -fileset sim_1 -norecurse $wave_file
  set_property xsim.view $wave_file [get_filesets sim_1]
}

run all
