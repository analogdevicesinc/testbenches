## Copyright 2024(c) Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/adi_axis_agent.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/m_axis_sequencer.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/amd/s_axis_sequencer.sv
SV_DEPS += $(TB_LIBRARY_PATH)/vip/adi/base/pub_sub_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/common/x_monitor.sv
