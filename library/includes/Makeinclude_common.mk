## Copyright (C) 2024-2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(ADI_TB_DIR)/library/includes/Makeinclude_axi.mk

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/utilities/utils.svh
SV_DEPS += $(ADI_TB_DIR)/library/utilities/logger_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/base_classes/adi_object_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/base_classes/adi_reporter_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/base_classes/adi_component_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/base_classes/adi_environment_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/base_classes/adi_agent_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/base_classes/adi_driver_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/base_classes/adi_monitor_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/base_classes/adi_sequencer_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/test_harness_env.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/watchdog.sv

SV_DEPS += system_tb.sv

ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS += $(ADI_TB_DIR)/scripts/adi_sim.tcl
ENV_DEPS += $(ADI_TB_DIR)/scripts/run_sim.tcl
