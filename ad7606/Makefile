####################################################################################
####################################################################################
## Copyright 2022 (c) Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += ../common/sv/utils.svh
SV_DEPS += ../common/sv/logger_pkg.sv
SV_DEPS += ../common/sv/reg_accessor.sv
SV_DEPS += ../common/sv/m_axis_sequencer.sv
SV_DEPS += ../common/sv/s_axis_sequencer.sv
SV_DEPS += ../common/sv/m_axi_sequencer.sv
SV_DEPS += ../common/sv/s_axi_sequencer.sv
SV_DEPS += ../common/sv/dmac_api.sv
SV_DEPS += ../common/sv/adi_regmap_pkg.sv
SV_DEPS += ../common/sv/adi_regmap_dmac_pkg.sv
SV_DEPS += ../common/sv/dma_trans.sv
SV_DEPS += ../common/sv/axi_dmac_pkg.sv
SV_DEPS += system_tb.sv

ENV_DEPS +=../../library/util_cdc/sync_bits.v
ENV_DEPS +=../../library/common/ad_edge_detect.v
ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS +=../scripts/adi_sim.tcl
ENV_DEPS +=../scripts/run_sim.tcl

LIB_DEPS += axi_clkgen
#LIB_DEPS += axi_ad7606
LIB_DEPS += axi_pwm_gen
LIB_DEPS += axi_dmac
LIB_DEPS += axi_sysid
LIB_DEPS += spi_engine/axi_spi_engine
LIB_DEPS += spi_engine/spi_engine_execution
LIB_DEPS += spi_engine/spi_engine_interconnect
LIB_DEPS += spi_engine/spi_engine_offload
LIB_DEPS += sysid_rom

# default test program
TP := test_program

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))
#$(warning $(CFG_FILES))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(cfg):$(TP))

#TESTS += cfg:test_program

include ../scripts/project-sim.mk

# usage :
#
# run specific test on a specific configuration in gui mode
# 	make CFG=cfg_si TST=test_program_si MODE=gui
#
# run all test from a configuration
# 	make cfg_si

####################################################################################
####################################################################################
