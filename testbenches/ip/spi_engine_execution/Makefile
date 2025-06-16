####################################################################################
####################################################################################
## Copyright 2025(c) Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_common.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_axis.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_pwm_gen.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_clk_gen.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_spi_engine.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += spi_execution_environment.sv

ENV_DEPS += $(HDL_LIBRARY_PATH)/util_cdc/sync_bits.v
ENV_DEPS += $(HDL_LIBRARY_PATH)/common/ad_edge_detect.v

LIB_DEPS += axi_clkgen
LIB_DEPS += axi_pwm_gen
LIB_DEPS += spi_engine/spi_engine_execution

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
