## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/vip/vip_agent_typedef_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/adi_axis_agent.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/m_axis_sequencer.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/s_axis_sequencer.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/adi_axis_monitor.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/adi_axis_byte.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/adi_axis_transaction.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/adi_axis_packet.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/adi_axis_frame.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/axis_transaction_adapter.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/axis_transaction_to_byte_adapter.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/adi_axis_config.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/adi_axis_rand_config.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/adi_axis_rand_obj.sv
SV_DEPS += $(ADI_TB_DIR)/library/vip/amd/axis/axis_definitions.svh
SV_DEPS += $(ADI_TB_DIR)/library/utilities/pub_sub_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/utilities/adi_fifo_class_pkg.sv
