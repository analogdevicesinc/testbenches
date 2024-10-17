####################################################################################
####################################################################################
## Copyright 2021(c) Analog Devices, Inc.
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
SV_DEPS += do_scoreboard.sv
SV_DEPS += environment.sv
SV_DEPS += system_tb.sv
SV_DEPS += data_offload_pkg.sv

ENV_DEPS += cfgs/common_cfg.tcl
ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS += ../../../scripts/adi_sim.tcl
ENV_DEPS += ../../../scripts/run_sim.tcl

LIB_DEPS := util_cdc
LIB_DEPS += util_axis_fifo
LIB_DEPS += util_do_ram
LIB_DEPS += axi_dmac
LIB_DEPS += data_offload
LIB_DEPS += util_hbm

#util_hbm test program
TP := test_program

# config files should have the following format
#  cfg_<param1>_<param2>.tcl
CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))
$(warning $(CFG_FILES))

# List of tests and configuration combinations that has to be run
# Format is:  <configuration>:<test name>
TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(cfg):$(TP))
TESTS += cfg3:test_program_sync

include ../../../scripts/project-sim.mk

####################################################################################
####################################################################################
