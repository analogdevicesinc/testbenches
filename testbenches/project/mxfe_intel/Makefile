####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_dmac.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_jesd.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_xcvr_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_dac_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_common_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_adc_pkg.sv
SV_DEPS += $(ADI_HDL_DIR)/library/intel/common/gts_refclk_reset.v

LIB_DEPS += axi_dmac
LIB_DEPS += jesd204/ad_ip_jesd204_tpl_adc
LIB_DEPS += jesd204/ad_ip_jesd204_tpl_dac
LIB_DEPS += util_pack/util_cpack2
LIB_DEPS += util_pack/util_upack2
LIB_DEPS += intel/adi_data_offload
LIB_DEPS += intel/adi_jesd204
LIB_DEPS += intel/jesd204c/jesd204_f_tile_adapter_rx
LIB_DEPS += intel/jesd204c/jesd204_f_tile_adapter_tx

# io_vip, set by the dmac include, has no Intel packaging
SIM_LIB_DEPS :=

# list of test programs
TP := $(notdir $(basename $(wildcard tests/*.sv)))

# config files should have the following format
# cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is: <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))

include $(ADI_TB_DIR)/scripts/project-sim-intel.mk

# usage:
#
# run specific test on a specific configuration in gui mode
# 	make CFG=<configuration_name> TST=<test_name> MODE=gui
#
# run all test from a configuration
# 	make <configuration_name>

####################################################################################
####################################################################################
