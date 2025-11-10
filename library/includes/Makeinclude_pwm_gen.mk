## Copyright (C) 2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(ADI_TB_DIR)/library/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/drivers/pwm_gen_api_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_pwm_gen_pkg.sv
