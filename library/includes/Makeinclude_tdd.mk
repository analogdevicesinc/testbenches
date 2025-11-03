## Copyright (C) 2024-2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(ADI_TB_DIR)/library/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/drivers/tdd_api_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_tdd_gen_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_tdd_trans_pkg.sv
