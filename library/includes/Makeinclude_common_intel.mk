####################################################################################
####################################################################################
## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

include $(ADI_TB_DIR)/library/includes/Makeinclude_avmm.mk

SV_DEPS += $(ADI_TB_DIR)/library/utilities/utils.svh
SV_DEPS += $(ADI_TB_DIR)/library/utilities/logger_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/adi_common_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/adi_vip_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/adi_environment_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/test_harness_intel_env.sv
SV_DEPS += $(ADI_TB_DIR)/library/drivers/common/watchdog.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/adi_api_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/intel/clk_rst/adi_clk_rst_bfm_if_base_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/intel/clk_rst/adi_clock_source_bfm_if.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/intel/clk_rst/adi_reset_source_bfm_if.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/intel/adi_intel_vip_bind.sv

SV_DEPS += system_tb.sv

ENV_DEPS += system_project.tcl
ENV_DEPS += system_bd.tcl
ENV_DEPS += $(ADI_TB_DIR)/library/utilities/test_harness_system_qsys.tcl
ENV_DEPS += $(ADI_TB_DIR)/scripts/adi_sim_intel.tcl
ENV_DEPS += $(ADI_TB_DIR)/scripts/adi_sim_intel_qsys.tcl
ENV_DEPS += $(ADI_TB_DIR)/scripts/run_sim_intel.tcl
