###############################################################################
## Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# Shared by adi_sim_intel.tcl and the qsys-script context, whose Tcl lacks
# some commands (e.g. file normalize), so keep this file to plain Tcl.

variable adi_sim_defines {}

proc adi_sim_add_define {value} {
  global adi_sim_defines
  lappend adi_sim_defines $value
}

proc adi_sim_write_defines {file_name} {
  global adi_sim_defines

  set fh [open $file_name w]
  foreach define $adi_sim_defines {
    puts $fh $define
  }
  close $fh
}
