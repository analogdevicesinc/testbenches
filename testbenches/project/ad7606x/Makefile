####################################################################################
####################################################################################
## Copyright (C) 2022 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_dmac.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_spi_engine.mk

# Remaining test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_adc_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_common_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_pwm_gen_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_clkgen_pkg.sv

ENV_DEPS += $(ADI_HDL_DIR)/library//util_cdc/sync_bits.v
ENV_DEPS += $(ADI_HDL_DIR)/library//common/ad_edge_detect.v

LIB_DEPS += axi_ad7606x
LIB_DEPS += axi_clkgen
LIB_DEPS += axi_dmac
LIB_DEPS += axi_hdmi_tx
LIB_DEPS += axi_i2s_adi
LIB_DEPS += axi_pwm_gen
LIB_DEPS += axi_spdif_tx
LIB_DEPS += util_i2c_mixer
LIB_DEPS += util_pack/util_cpack2
LIB_DEPS += util_cdc
LIB_DEPS += util_axis_fifo
LIB_DEPS += spi_engine/axi_spi_engine
LIB_DEPS += spi_engine/spi_engine_execution
LIB_DEPS += spi_engine/spi_engine_interconnect
LIB_DEPS += spi_engine/spi_engine_offload

# List of tests and configuration combinations that has to be run
# Format is: <configuration>:<test name>

# Parallel interface configurations
TESTS += cfg_p_16b:test_program_4ch
TESTS += cfg_p_16b:test_program_6ch
TESTS += cfg_p_16b:test_program_8ch
TESTS += cfg_p_18b_8ch:test_program_8ch

# Serial interface configurations
TESTS += cfg_s_sdi1:test_program_si
TESTS += cfg_s_sdi2:test_program_si
TESTS += cfg_s_sdi4:test_program_si
TESTS += cfg_s_sdi8:test_program_si

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
