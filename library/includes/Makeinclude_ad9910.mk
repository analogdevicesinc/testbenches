## Copyright (C) 2026 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(ADI_TB_DIR)/library/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/drivers/ad9910_api_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_ad9910_pkg.sv
