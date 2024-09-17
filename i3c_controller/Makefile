####################################################################################
####################################################################################
## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

.INCLUDE : ../common/Makeinclude

# All test-bench dependencies except test programs
SV_DEPS += ../common/sv/m_axis_sequencer.sv
SV_DEPS += ../common/sv/s_axis_sequencer.sv

ENV_DEPS +=../../library/util_cdc/sync_bits.v
ENV_DEPS +=../../library/common/ad_edge_detect.v

LIB_DEPS += axi_sysid
LIB_DEPS += i3c_controller/i3c_controller_host_interface
LIB_DEPS += i3c_controller/i3c_controller_core
LIB_DEPS += sysid_rom

# default test program
TP := test_program

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))
#$(warning $(CFG_FILES))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(cfg):$(TP))

include ../scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg1 TST=test_program MODE=gui
#
# run all test from a configuration
# 	make cfg1

####################################################################################
####################################################################################
