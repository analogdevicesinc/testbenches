## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/pub_sub_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/common/scoreboard.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/common/scoreboard_pack.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/common/scoreboard_object.sv
