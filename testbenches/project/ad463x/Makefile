####################################################################################
####################################################################################
## Copyright 2018(c) Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += ../../../library/utilities/utils.svh
SV_DEPS += ../../../library/utilities/logger_pkg.sv
SV_DEPS += ../../../library/utilities/reg_accessor.sv
SV_DEPS += ../../../library/xilinx_vip/m_axis_sequencer.sv
SV_DEPS += ../../../library/xilinx_vip/s_axis_sequencer.sv
SV_DEPS += ../../../library/xilinx_vip/m_axi_sequencer.sv
SV_DEPS += ../../../library/xilinx_vip/s_axi_sequencer.sv
SV_DEPS += ../../../library/ips/dmac/dmac_api.sv
SV_DEPS += ../../../library/utilities/adi_regmap_pkg.sv
SV_DEPS += ../../../library/ips/adi_regmap_clkgen_pkg.sv
SV_DEPS += ../../../library/ips/dmac/adi_regmap_dmac_pkg.sv
SV_DEPS += ../../../library/ips/spi_engine/adi_regmap_spi_engine_pkg.sv
SV_DEPS += ../../../library/ips/adi_regmap_pwm_gen_pkg.sv
SV_DEPS += ../../../library/ips/dmac/dma_trans.sv
SV_DEPS += system_tb.sv

ENV_DEPS += ../../../../library/util_cdc/sync_bits.v
ENV_DEPS += ../../../../library/common/ad_edge_detect.v

ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS += ../../../scripts/adi_sim.tcl
ENV_DEPS += ../../../scripts/run_sim.tcl

LIB_DEPS += ad463x_data_capture
LIB_DEPS += axi_dmac
LIB_DEPS += util_pack/util_upack2
LIB_DEPS += util_pack/util_cpack2
LIB_DEPS += axi_sysid
LIB_DEPS += sysid_rom
LIB_DEPS += axi_clkgen
LIB_DEPS += axi_i2s_adi
LIB_DEPS += axi_pwm_gen
LIB_DEPS += axi_sysid
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

include ../../../scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg2_fsync TST=test_frame_delay MODE=gui
#
# run all test from a configuration
# 	make cfg1_mm2mm_default

####################################################################################
####################################################################################
