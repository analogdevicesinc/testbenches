####################################################################################
####################################################################################
## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

include ../common/Makeinclude

# All test-bench dependencies except test programs
SV_DEPS += ../common/sv/m_axis_sequencer.sv
SV_DEPS += ../common/sv/s_axis_sequencer.sv
SV_DEPS += ../common/sv/dmac_api.sv
SV_DEPS += ../common/sv/adi_regmap_dmac_pkg.sv
SV_DEPS += ../common/sv/dma_trans.sv
SV_DEPS += scoreboard.sv

LIB_DEPS += axi_dmac

# default test program
TP := test_program

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))
#$(warning $(CFG_FILES))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
#TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(cfg):$(TP))
TESTS += cfg1:test_program
TESTS += cfg2_fsync:test_program
TESTS += cfg2_fsync:test_program_frame_delay
TESTS += cfg3_fsync_autorun:test_program_frame_delay

include ../scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg2_fsync TST=test_program_frame_delay MODE=gui
#
# run all test from a configuration
# 	make cfg1_mm2mm_default



####################################################################################
####################################################################################
