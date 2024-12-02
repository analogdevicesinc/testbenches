####################################################################################
## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_common.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_axis.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_dmac.mk

# Remaining test-bench dependencies except test programs
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

include $(ADI_TB_DIR)/scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg2 TST=test_program_2d MODE=gui
#
# run all test from a configuration
# 	make cfg2

####################################################################################
####################################################################################
