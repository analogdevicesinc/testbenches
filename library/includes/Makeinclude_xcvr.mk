## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(ADI_TB_DIR)/library/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/drivers/xcvr/adi_xcvr_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_xcvr_pkg.sv
