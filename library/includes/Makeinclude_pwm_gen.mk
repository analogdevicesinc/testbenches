## Copyright (C) 2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(TB_LIBRARY_PATH)/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/pwm_gen_api_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_pwm_gen_pkg.sv
