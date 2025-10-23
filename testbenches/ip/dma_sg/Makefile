####################################################################################
## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_axis.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_dmac.mk

# Remaining test-bench dependencies except test programs
LIB_DEPS += axi_dmac

# List of tests and configuration combinations that has to be run
# Format is: <configuration>:<test name>
TESTS += cfg1:test_program_1d
TESTS += cfg2:test_program_2d
TESTS += cfg1:test_program_tr_queue

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
