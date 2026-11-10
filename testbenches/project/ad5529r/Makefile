####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_dmac.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_spi_engine.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_clk_gen.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_pwm_gen.mk

LIB_DEPS += axi_clkgen
LIB_DEPS += axi_pwm_gen
LIB_DEPS += axi_dmac
LIB_DEPS += util_axis_fifo
LIB_DEPS += spi_engine/axi_spi_engine
LIB_DEPS += spi_engine/spi_engine_execution
LIB_DEPS += spi_engine/spi_engine_interconnect
LIB_DEPS += spi_engine/spi_engine_offload

# Shared test flow body, `included by every tests/test_*.sv. Tracked so a change
# to it re-runs all tests (it is not a standalone *.sv test program).
SV_DEPS += tests/ad5529r_test_flow.svh

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
