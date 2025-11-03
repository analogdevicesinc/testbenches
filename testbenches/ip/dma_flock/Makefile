####################################################################################
####################################################################################
## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_dmac.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_axis.mk

# All test-bench dependencies except test programs
SV_DEPS += environment.sv
SV_DEPS += scoreboard.sv

LIB_DEPS := axi_dmac

# List of tests and configuration combinations that has to be run
# Format is: <configuration>:<test name>
TESTS += cfg1:test_program
TESTS += cfg2_fsync:test_program
TESTS += cfg2_fsync:test_program_frame_delay
TESTS += cfg3_fsync_autorun:test_program_frame_delay

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
