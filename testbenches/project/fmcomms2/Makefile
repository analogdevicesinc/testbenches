####################################################################################
####################################################################################
## Copyright (C) 2018 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_common.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_dmac.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_dac_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_adc_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_common_pkg.sv

LIB_DEPS += axi_ad9361
LIB_DEPS += axi_dmac
LIB_DEPS += util_pack/util_cpack2
LIB_DEPS += util_pack/util_upack2
LIB_DEPS += util_rfifo
LIB_DEPS += util_tdd_sync
LIB_DEPS += util_wfifo
LIB_DEPS += xilinx/util_clkdiv

# default test program
TP := test_program

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))
#$(warning $(CFG_FILES))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(cfg):$(TP))
#TESTS += cfg1_mm2mm_default:directed_test
#TESTS += cfg1:test_program
#TESTS += cfg2_fsync:test_program
#TESTS += cfg2_fsync:test_frame_delay

include $(ADI_TB_DIR)/scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg2_fsync TST=test_frame_delay MODE=gui
#
# run all test from a configuration
# 	make cfg1_mm2mm_default

####################################################################################
####################################################################################
