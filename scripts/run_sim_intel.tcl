###############################################################################
## Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# Questa do script, run from the directory of the configuration:
#   do run_sim_intel.tcl <configuration> <test program> <mode>

if {$argc < 3} {
  echo "Expecting the test configuration, the test program and the mode"
  quit -code 1
}

set topology_file $1
set test_program $2
set mode $3

if {$mode != "gui"} {
  onerror {quit -f -code 1}
}

set QSYS_SIMDIR [pwd]/test_harness/sim

# The bind module attaches the ADI interfaces to the Intel BFMs
set TOP_LEVEL_NAME "work.system_tb work.adi_intel_vip_bind"

# The C objects of the models are linked with the system ld, the one of the
# gcc bundled with Questa does not read the libraries of newer glibc versions
# (unknown section .relr.dyn). The objects are compiled by the bundled gcc,
# switching the compiler with -dpicpppath leaves them out of the link.
set USER_DEFINED_ELAB_OPTIONS "-sv_seed random -ldflags -B/usr/bin/"
if {$mode == "gui"} {
  append USER_DEFINED_ELAB_OPTIONS " -voptargs=+acc"
}

source $QSYS_SIMDIR/mentor/msim_setup.tcl

# One compilation unit, the register map macros are used by the drivers.
# 2244: the shared packages initialize variables of static functions in
# their declaration, which Vivado accepts without a static keyword
vlog -sv -mfcu -work work -L altera_common_sv_packages \
  -suppress 2244 \
  -f sim_files.f \
  +define+TEST_PROGRAM=$test_program

elab

if {$mode == "gui"} {
  log -r /system_tb/test_harness/*

  set wave_file ../../waves/$topology_file.do
  if {[file exists $wave_file]} {
    do $wave_file
  }
}

run -all

if {$mode != "gui"} {
  quit -f
}
