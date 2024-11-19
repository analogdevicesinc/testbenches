####################################################################################
####################################################################################
## Copyright 2021(c) Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path
include $(TB_LIBRARY_PATH)/includes/Makeinclude_common
include $(TB_LIBRARY_PATH)/includes/Makeinclude_dmac
include $(TB_LIBRARY_PATH)/includes/Makeinclude_spi_engine

# Remaining test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_clkgen_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_pwm_gen_pkg.sv

ENV_DEPS += $(HDL_LIBRARY_PATH)/util_cdc/sync_bits.v
ENV_DEPS += $(HDL_LIBRARY_PATH)/common/ad_edge_detect.v

LIB_DEPS += axi_clkgen
LIB_DEPS += axi_pwm_gen
LIB_DEPS += axi_dmac
LIB_DEPS += axi_sysid
LIB_DEPS += util_cdc
LIB_DEPS += util_axis_fifo
LIB_DEPS += axi_pulsar_lvds
LIB_DEPS += spi_engine/axi_spi_engine
LIB_DEPS += spi_engine/spi_engine_execution
LIB_DEPS += spi_engine/spi_engine_interconnect
LIB_DEPS += spi_engine/spi_engine_offload
LIB_DEPS += sysid_rom

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
