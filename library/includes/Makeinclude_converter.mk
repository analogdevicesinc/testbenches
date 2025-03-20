## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(TB_LIBRARY_PATH)/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_dac_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_adc_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/regmaps/adi_regmap_common_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/adc_api_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/dac_api_pkg.sv
SV_DEPS += $(TB_LIBRARY_PATH)/drivers/common_api_pkg.sv

SIM_LIB_DEPS := io_vip
