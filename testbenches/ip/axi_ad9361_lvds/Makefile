####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
## SPDX short identifier: BSD-1-Clause
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk

# HDL library dependencies
LIB_DEPS := axi_ad9361

# list of test programs
TP := $(notdir $(basename $(wildcard tests/*.sv)))

# config files should have the following format: cfg_<param>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations to run
# Format: <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))

include $(ADI_TB_DIR)/scripts/project-sim.mk

# usage:
#
# run specific test on a specific configuration in gui mode
#   make CFG=<configuration_name> TST=<test_name> MODE=gui
#
# run all tests from a configuration
#   make <configuration_name>

####################################################################################
####################################################################################
