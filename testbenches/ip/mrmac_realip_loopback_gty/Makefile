####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_axis.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_scoreboard.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += environment.sv

# Library IP dependencies (resolve to $(ADI_HDL_DIR)/library/<dep>/component.xml).
# The MRMAC MAC shim (DUT) + the Corundum-lib submodules it instantiates are
# packaged as the single library IP corundum/mrmac_gty_wrapper; listing it here
# makes the flow (re)build its component.xml from the current RTL before the sim
# elaborates. Unlike the behavioral mrmac_loopback, this TB ALSO instantiates the
# real encrypted MRMAC (xilinx.com:ip:mrmac) + gtwiz_versal + clk_wizard + the
# mrmac_versal_glue RTL cell directly in system_bd.tcl -- those are AMD catalog IP
# / a repo RTL module, not library IP, so they are not LIB_DEPS.
LIB_DEPS := corundum/mrmac_gty_wrapper

# list of test programs
TP := $(notdir $(basename $(wildcard tests/*.sv)))

# config files should have the following format
# cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is: <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))

include ../../../scripts/project-sim.mk

# usage:
#
# run specific test on a specific configuration in gui mode
# 	make CFG=<configuration_name> TST=<test_name> MODE=gui
#
# run all test from a configuration
# 	make <configuration_name>

####################################################################################
####################################################################################
