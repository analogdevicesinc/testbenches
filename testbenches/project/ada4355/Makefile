####################################################################################
####################################################################################
## Copyright 2025 (c) Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_dmac.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_converter.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_tdd.mk

LIB_DEPS += axi_ada4355
LIB_DEPS += axi_dmac
LIB_DEPS += axi_tdd

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS += cfg1:test_program
TESTS += cfg2:test_program
TESTS += cfg_tdd:test_program_tdd

include $(ADI_TB_DIR)/scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=<configuration_name> TST=<test_name> MODE=gui
#
# run all test from a configuration
# 	make <configuration_name>

####################################################################################
####################################################################################
