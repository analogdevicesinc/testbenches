####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_common.mk
include $(TB_LIBRARY_PATH)/includes/Makeinclude_dmac.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_adc_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_common_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_clkgen_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_pwm_gen_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/clk_gen_api_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/pwm_gen_api_pkg.sv

LIB_DEPS += axi_ad485x
LIB_DEPS += axi_dmac
LIB_DEPS += axi_clkgen
LIB_DEPS += axi_pwm_gen
LIB_DEPS += util_pack/util_cpack2

# default test program
#TP := test_program_cmos

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
#TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))
TESTS += cfg8_cmos:test_program_cmos
TESTS += cfg7_cmos:test_program_cmos
TESTS += cfg6_cmos:test_program_cmos
TESTS += cfg5_cmos:test_program_cmos
TESTS += cfg4_cmos:test_program_cmos
TESTS += cfg3_cmos:test_program_cmos
TESTS += cfg2_cmos:test_program_cmos
TESTS += cfg1_cmos:test_program_cmos

# LVDS interface configurations
TESTS += cfg8_lvds:test_program_lvds
TESTS += cfg7_lvds:test_program_lvds
TESTS += cfg6_lvds:test_program_lvds
TESTS += cfg5_lvds:test_program_lvds
TESTS += cfg4_lvds:test_program_lvds
TESTS += cfg3_lvds:test_program_lvds
TESTS += cfg2_lvds:test_program_lvds
TESTS += cfg1_lvds:test_program_lvds

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
