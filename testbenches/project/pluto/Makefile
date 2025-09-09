####################################################################################
## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_dmac.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_tdd.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_dac_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_adc_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_common_pkg.sv

LIB_DEPS += axi_ad9361
LIB_DEPS += axi_dmac
LIB_DEPS += axi_tdd
LIB_DEPS += util_pack/util_cpack2
LIB_DEPS += util_pack/util_upack2

# list of test programs
TP := $(notdir $(basename $(wildcard tests/*.sv)))

# config files should have the following format
# cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is: <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(cfg):$(TP))

include $(ADI_TB_DIR)/scripts/project-sim.mk
