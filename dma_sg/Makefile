####################################################################################
## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################

.INCLUDE : ../common/Makeinclude

# All test-bench dependencies except test programs
SV_DEPS += ../common/sv/m_axis_sequencer.sv
SV_DEPS += ../common/sv/s_axis_sequencer.sv
SV_DEPS += ../common/sv/dmac_api.sv
SV_DEPS += ../common/sv/adi_regmap_dmac_pkg.sv
SV_DEPS += ../common/sv/dma_trans.sv

LIB_DEPS += axi_dmac

# default test program
TP := test_program_1d

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))
#$(warning $(CFG_FILES))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
#TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(cfg):$(TP))
TESTS += cfg1:test_program_1d
TESTS += cfg2:test_program_2d
TESTS += cfg1:test_program_tr_queue

include ../scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg2 TST=test_program_2d MODE=gui
#
# run all test from a configuration
# 	make cfg2

####################################################################################
####################################################################################
