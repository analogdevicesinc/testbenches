## Copyright (C) 2024 - 2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(TB_LIBRARY_PATH)/includes/Makeinclude_axi.mk

# All test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/utils.svh
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/logger_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/adi_common_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/adi_vip_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/adi_api_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/adi_environment_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/test_harness_env.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/irq_handler_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/common/watchdog.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/adi/io_vip/io_vip_if_base_pkg.sv

SV_DEPS += system_tb.sv

SIM_LIB_DEPS += io_vip

ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS += $(ADI_TB_DIR)/scripts/adi_sim.tcl
ENV_DEPS += $(ADI_TB_DIR)/scripts/run_sim.tcl
