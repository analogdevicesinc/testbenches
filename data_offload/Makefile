####################################################################################
####################################################################################
## Copyright 2018(c) Analog Devices, Inc.
####################################################################################
####################################################################################

.INCLUDE : ../common/Makeinclude

# All test-bench dependencies except test programs
SV_DEPS += ../common/sv/m_axis_sequencer.sv
SV_DEPS += ../common/sv/s_axis_sequencer.sv
SV_DEPS += do_scoreboard.sv

#ENV_DEPS += cfgs/common_cfg.tcl

LIB_DEPS += util_cdc
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

include ../scripts/project-sim.mk

####################################################################################
####################################################################################
