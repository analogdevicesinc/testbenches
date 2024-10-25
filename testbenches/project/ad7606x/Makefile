####################################################################################
####################################################################################
## Copyright 2022 (c) Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += ../../../library/utilities/utils.svh
SV_DEPS += ../../../library/utilities/logger_pkg.sv
SV_DEPS += ../../../library/regmaps/reg_accessor.sv
SV_DEPS += ../../../library/vip/amd/m_axis_sequencer.sv
SV_DEPS += ../../../library/vip/amd/s_axis_sequencer.sv
SV_DEPS += ../../../library/vip/amd/m_axi_sequencer.sv
SV_DEPS += ../../../library/vip/amd/s_axi_sequencer.sv
SV_DEPS += ../../../library/drivers/dmac/dmac_api.sv
SV_DEPS += ../../../library/regmaps/adi_regmap_pkg.sv
SV_DEPS += ../../../library/regmaps/adi_regmap_adc_pkg.sv
SV_DEPS += ../../../library/regmaps/adi_regmap_clkgen_pkg.sv
SV_DEPS += ../../../library/regmaps/adi_regmap_common_pkg.sv
SV_DEPS += ../../../library/regmaps/adi_regmap_dmac_pkg.sv
SV_DEPS += ../../../library/regmaps/adi_regmap_pwm_gen_pkg.sv
SV_DEPS += ../../../library/drivers/dmac/dma_trans.sv
SV_DEPS += system_tb.sv

ENV_DEPS += ../../../../library/util_cdc/sync_bits.v
ENV_DEPS += ../../../../library/common/ad_edge_detect.v
ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS += ../../../scripts/adi_sim.tcl
ENV_DEPS += ../../../scripts/run_sim.tcl

LIB_DEPS += axi_ad7606x
LIB_DEPS += axi_clkgen
LIB_DEPS += axi_dmac
LIB_DEPS += axi_hdmi_tx
LIB_DEPS += axi_i2s_adi
LIB_DEPS += axi_pwm_gen
LIB_DEPS += axi_spdif_tx
LIB_DEPS += axi_sysid
LIB_DEPS += sysid_rom
LIB_DEPS += util_i2c_mixer
LIB_DEPS += util_pack/util_cpack2 
LIB_DEPS += util_cdc
LIB_DEPS += util_axis_fifo
LIB_DEPS += spi_engine/axi_spi_engine
LIB_DEPS += spi_engine/spi_engine_execution
LIB_DEPS += spi_engine/spi_engine_interconnect
LIB_DEPS += spi_engine/spi_engine_offload

# default test program
TP := test_program_si
#TP := test_program_4ch
#TP := test_program_6ch
#TP := test_program_8ch

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
#CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))
#$(warning $(CFG_FILES))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
#TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(cfg):$(TP))

# Parallel interface configurations
#TESTS += cfg_p_16b:test_program_4ch
#TESTS += cfg_p_16b:test_program_6ch
#TESTS += cfg_p_16b:test_program_8ch
#TESTS += cfg_p_18b:test_program_8ch

# Serial interface configurations
#TESTS += cfg_s_sdi1:test_program_si
#TESTS += cfg_s_sdi2:test_program_si
#TESTS += cfg_s_sdi4:test_program_si
#TESTS += cfg_s_sdi8:test_program_si

include ../../../scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg_p_18b TST=test_program_8ch MODE=gui
#

####################################################################################
####################################################################################
