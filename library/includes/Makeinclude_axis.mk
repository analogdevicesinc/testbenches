## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(TB_LIBRARY_PATH)/includes/Makeinclude_publisher.mk

# All test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/adi_axis_agent.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/m_axis_sequencer.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/s_axis_sequencer.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/adi_axis_monitor.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/axis/axis_definitions.svh
