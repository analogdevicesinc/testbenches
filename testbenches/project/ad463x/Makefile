####################################################################################
####################################################################################
## Copyright (C) 2018 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_common.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_dmac.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_spi_engine.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_clkgen_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_pwm_gen_pkg.sv

ENV_DEPS += $(HDL_LIBRARY_PATH)/util_cdc/sync_bits.v
ENV_DEPS += $(HDL_LIBRARY_PATH)/common/ad_edge_detect.v

LIB_DEPS += ad463x_data_capture
LIB_DEPS += axi_dmac
LIB_DEPS += util_pack/util_upack2
LIB_DEPS += util_pack/util_cpack2
LIB_DEPS += axi_clkgen
LIB_DEPS += axi_i2s_adi
LIB_DEPS += axi_pwm_gen
LIB_DEPS += spi_engine/axi_spi_engine
LIB_DEPS += spi_engine/spi_axis_reorder
LIB_DEPS += spi_engine/spi_engine_execution
LIB_DEPS += spi_engine/spi_engine_interconnect
LIB_DEPS += spi_engine/spi_engine_offload

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
