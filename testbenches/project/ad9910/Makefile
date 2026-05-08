####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_common.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_common_pkg.sv

LIB_DEPS += axi_ad9910

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS += cfg1_drg:test_program_drg
TESTS += cfg2_par_if:test_program_par_if

include $(ADI_TB_DIR)/scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg1_drg TST=test_program_drg MODE=gui
# 	make CFG=cfg2_par_if TST=test_program_par_if MODE=gui
#
# run all test from a configuration
# 	make cfg1_drg
# 	make cfg2_par_if

####################################################################################
####################################################################################
