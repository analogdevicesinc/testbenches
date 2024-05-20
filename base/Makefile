####################################################################################
####################################################################################
## Copyright 2022(c) Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += ../common/sv/utils.svh
SV_DEPS += ../common/sv/logger_pkg.sv
SV_DEPS += ../common/sv/reg_accessor.sv
SV_DEPS += ../common/sv/m_axis_sequencer.sv
SV_DEPS += ../common/sv/s_axis_sequencer.sv
SV_DEPS += ../common/sv/m_axi_sequencer.sv
SV_DEPS += ../common/sv/s_axi_sequencer.sv
SV_DEPS += ../common/sv/test_harness_env.sv
SV_DEPS += ../common/sv/adi_peripheral_pkg.sv
SV_DEPS += ../common/sv/adi_regmap_pkg.sv
SV_DEPS += ../common/sv/mailbox.sv
SV_DEPS += ../common/sv/x_monitor.sv
SV_DEPS += ../common/sv/scoreboard.sv
SV_DEPS += ../common/sv/watchdog.sv
SV_DEPS += environment.sv
SV_DEPS += system_tb.sv

ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS +=../scripts/adi_sim.tcl
ENV_DEPS +=../scripts/run_sim.tcl

# default test program
TP := test_program

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))
#$(warning $(CFG_FILES))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))
#TESTS += cfg1:test_program

include ../scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg2_fsync TST=test_frame_delay MODE=gui
#
# run all test from a configuration
# 	make cfg1_mm2mm_default

####################################################################################
####################################################################################
