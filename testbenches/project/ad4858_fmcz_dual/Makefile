####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_dmac.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_converter.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_pwm_gen.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_clk_gen.mk

# Remaining test-bench dependencies except test programs
LIB_DEPS += axi_ad485x
LIB_DEPS += axi_dmac
LIB_DEPS += axi_clkgen
LIB_DEPS += axi_pwm_gen
LIB_DEPS += util_pack/util_cpack2

# list of test programs
TP := $(notdir $(basename $(wildcard tests/*.sv)))

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>

# CMOS interface configurations
TESTS += cfg_cmos_rand:test_program_cmos

# LVDS interface configurations
TESTS += cfg_lvds_rand:test_program_lvds

include $(ADI_TB_DIR)/scripts/project-sim.mk

# usage:
#
# run specific test on a specific configuration in gui mode
# 	make CFG=<configuration_name> TST=<test_name> MODE=gui
#
# run all test from a configuration
# 	make <configuration_name>

####################################################################################
####################################################################################
