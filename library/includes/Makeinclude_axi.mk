## Copyright (C) 2024-2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/vip/vip_agent_typedef_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axi/adi_axi_agent.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axi/m_axi_sequencer.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axi/s_axi_sequencer.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axi/adi_axi_monitor.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axi/axi_definitions.svh
SV_DEPS += $(ADI_TB_DIR)/library/utilities/pub_sub_pkg.sv
