####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes. Only make_tb_path + the common set (pulled in by project-sim.mk):
# NO Makeinclude_axis.mk and NO Makeinclude_scoreboard.mk, because this bench has no
# AXIS VIPs and no scoreboard -- the traffic generator and byte-exact checker are
# plain RTL cells inside the block design.
include ../../../scripts/make_tb_path.mk

# The generator/checker RTL, its flat-AXIS wrappers, and (increment 2) the axis_fifo
# wrappers. Listed as dependencies so a change to any of them re-runs the environment
# build (system_bd.tcl add_files them into sources_1).
#
# Only the files LOCAL to this directory belong here. The library RTL that system_bd.tcl
# also adds to sources_1 -- mrmac_versal_glue.v, mrmac_{tx,rx}_adapt.v, and increment
# 2's axis_fifo.v / sync_reset.v -- is deliberately not listed: SV_DEPS is a make
# dependency list for triggering a rebuild when THIS bench's own sources change, and
# putting shared library paths in it would make every unrelated library edit re-run an
# hour-long GT power-up sim.
SV_DEPS += mrmac_seg_pkt_gen_chk.v
SV_DEPS += mrmac_flat_pkt_gen_chk.v
SV_DEPS += mrmac_shim_fifo.v

# NO LIB_DEPS, still. The sibling mrmac_realip_loopback_gty lists
# corundum/mrmac_gty_wrapper -- the Corundum MAC shim packaged as library IP, i.e. a
# component.xml build. This bench keeps taking the shim apart piece by piece instead:
# increment 1 pulled mrmac_tx_adapt.v / mrmac_rx_adapt.v out of that package, and
# increment 2 pulls the two generic modules the shim uses (axis_fifo.v and
# sync_reset.v, from the same canonical corundum/fpga/lib paths the IP tcl packages);
# all are added to sources_1 as plain RTL. So everything instantiated here is AMD
# catalog IP (mrmac, gtwiz_versal, clk_wizard), repo/Corundum RTL in sources_1
# (mrmac_versal_glue.v, mrmac_{tx,rx}_adapt.v, axis_fifo.v, sync_reset.v,
# mrmac_seg_pkt_gen_chk.v, mrmac_flat_pkt_gen_chk.v, mrmac_shim_fifo.v), or a BD
# utility cell -- none of which need a library IP build.

# list of test programs
TP := $(notdir $(basename $(wildcard tests/*.sv)))

# config files should have the following format
# cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is: <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))

include ../../../scripts/project-sim.mk

# usage:
#
# run specific test on a specific configuration in gui mode
# 	make CFG=<configuration_name> TST=<test_name> MODE=gui
#
# run all tests from a configuration
# 	make <configuration_name>
#
# this bench:
# 	make CFG=cfg_1x100g TST=test_program MODE=batch
#
# EXPECT A LONG RUN: gtwiz SIM_SPEEDUP is {false} (the reference ships false; with
# true the GT power-up ramp is shortcut and rx_reset_done never asserts), so the
# encrypted GTY power-up takes many ms of sim time = tens of minutes wall clock
# before the first [MRMAC-ONLY][HB] heartbeat lines show gtpowergood=1. That is
# expected, not a hang -- the heartbeat prints every 50 us of sim time.

####################################################################################
####################################################################################
