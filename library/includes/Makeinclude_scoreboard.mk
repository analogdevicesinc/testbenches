## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# All test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/pub_sub_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/adi_fifo_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/adi_fifo_primitive_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/adi_fifo_class_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/scoreboard.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/scoreboard_primitive.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/scoreboard_class.sv
SV_DEPS += $(TB_LIBRARY_PATH)/utilities/scoreboard_pack.sv
