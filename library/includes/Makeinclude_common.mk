## Copyright (C) 2024-2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(ADI_TB_DIR)/library/includes/Makeinclude_axi.mk

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/utilities/utils.svh
SV_DEPS += $(ADI_TB_DIR)/library/utilities/logger_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/adi_common_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/adi_vip_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/adi_environment_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/test_harness_env.sv
SV_DEPS += $(ADI_TB_DIR)/library/drivers/common/watchdog.sv

SV_DEPS += system_tb.sv

ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS += $(ADI_TB_DIR)/scripts/adi_sim.tcl
ENV_DEPS += $(ADI_TB_DIR)/scripts/run_sim.tcl
