## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(ADI_TB_DIR)/library/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_dac_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_adc_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_common_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/drivers/adc_api_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/drivers/dac_api_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/drivers/common_api_pkg.sv

SIM_LIB_DEPS := io_vip
