####################################################################################
####################################################################################
## Copyright (C) 2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_common.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_dmac.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_converter.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_pwm_gen_pkg.sv

SV_DEPS += cn0577_environment.sv

LIB_DEPS += axi_pwm_gen
LIB_DEPS += axi_dmac
LIB_DEPS += axi_ltc2387

# default test programs
# Format is: <test name>
TP := $(notdir $(basename $(wildcard tests/*.sv)))

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))

include $(ADI_TB_DIR)/scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg1 TST=test_program MODE=gui
#
# run all test from a configuration
# 	make cfg1

####################################################################################
####################################################################################
