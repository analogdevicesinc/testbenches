####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

include ../../../scripts/make_tb_path.mk
include $(ADI_TB_DIR)/library/includes/Makeinclude_pwm_gen.mk

SV_DEPS += pwmgen_environment.sv

LIB_DEPS += axi_pwm_gen

TP := $(notdir $(basename $(wildcard tests/*.sv)))

CFG_FILES := $(notdir $(wildcard cfgs/cfg*.tcl))

TESTS := $(foreach cfg, $(basename $(CFG_FILES)), $(addprefix $(cfg):, $(TP)))

include $(ADI_TB_DIR)/scripts/project-sim.mk

####################################################################################
####################################################################################