####################################################################################
####################################################################################
## Copyright (C) 2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_common.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_dmac.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_clkgen_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_dac_pkg.sv

# Additional source files for AD9740
SV_DEPS += system_tb_ad9740.sv
SV_DEPS += test_harness_ad9740.sv

LIB_DEPS += axi_clkgen
LIB_DEPS += axi_dmac
LIB_DEPS += util_axis_fifo
LIB_DEPS += axi_ad9740

# Remove SPI VIP as it's not needed for parallel DAC
# SIM_LIB_DEPS += spi_vip

# default test programs
# Format is: <test name>
TP := test_program_ad9740
TP += test_program  # Keep original for backward compatibility

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))

# Add specific test targets
test_ad9740: cfg_ad9740

# Set default configuration for AD9740
DEFAULT_CFG := cfg_ad9740
DEFAULT_TST := test_program_ad9740

include $(ADI_TB_DIR)/scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg_ad9740 TST=test_program_ad9740 MODE=gui
#
# run all test from a configuration
# 	make cfg_ad9740
#
# run AD9740 test with waveforms
#	make test_ad9740 MODE=gui
#
# clean and rebuild
#	make clean
#	make CFG=cfg_ad9740 TST=test_program_ad9740

####################################################################################
####################################################################################