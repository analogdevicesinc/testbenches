## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(ADI_TB_DIR)/library/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/drivers/dmac/dma_trans.sv
SV_DEPS += $(ADI_TB_DIR)/library/drivers/dmac/dmac_api.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_dmac_pkg.sv

SIM_LIB_DEPS := io_vip
