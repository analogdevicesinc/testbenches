## Copyright (C) 2024-2025 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(TB_LIBRARY_PATH)/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/tdd_api_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_tdd_gen_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_tdd_trans_pkg.sv
