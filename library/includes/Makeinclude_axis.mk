## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/vip/vip_agent_typedef_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/adi_axis_agent.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/m_axis_sequencer.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/s_axis_sequencer.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/adi_axis_monitor.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/axis_definitions.svh
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/pub_sub_pkg.sv
