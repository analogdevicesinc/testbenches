####################################################################################
####################################################################################
## Copyright (C) 2018 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_axis.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_scoreboard.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_dmac.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_data_offload.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += environment.sv

LIB_DEPS := util_cdc
LIB_DEPS += util_axis_fifo
LIB_DEPS += axi_dmac
LIB_DEPS += data_offload
LIB_DEPS += util_do_ram
LIB_DEPS += util_hbm

# list of test programs
TP := $(notdir $(basename $(wildcard tests/*.sv)))

# config files should have the following format
# cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is: <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))

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
