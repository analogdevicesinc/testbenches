####################################################################################
####################################################################################
## Copyright (C) 2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_common.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_dmac.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_jesd.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_xcvr.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_tdd.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_dac_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_common_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_adc_pkg.sv

ENV_DEPS += $(ADI_HDL_DIR)/library/util_cdc/sync_bits.v

LIB_DEPS += axi_dmac
LIB_DEPS += axi_fsrc/axi_fsrc_rx
LIB_DEPS += axi_fsrc/axi_fsrc_tx
LIB_DEPS += axi_fsrc/axi_fsrc_sequencer
LIB_DEPS += axi_tdd
LIB_DEPS += data_offload
LIB_DEPS += jesd204/ad_ip_jesd204_tpl_dac
LIB_DEPS += jesd204/axi_jesd204_tx
LIB_DEPS += jesd204/jesd204_tx
LIB_DEPS += jesd204/ad_ip_jesd204_tpl_adc
LIB_DEPS += jesd204/axi_jesd204_rx
LIB_DEPS += jesd204/jesd204_rx
LIB_DEPS += util_adcfifo
LIB_DEPS += util_dacfifo
LIB_DEPS += util_do_ram
LIB_DEPS += util_pack/util_upack2
LIB_DEPS += util_pack/util_cpack2
LIB_DEPS += xilinx/axi_adxcvr
LIB_DEPS += xilinx/util_adxcvr

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
#       make CFG=<configuration_name> TST=<test_name> MODE=gui
#
# run all test from a configuration
#       make <configuration_name>

####################################################################################
####################################################################################
