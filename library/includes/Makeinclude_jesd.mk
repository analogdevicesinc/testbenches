## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

# Makeincludes
include $(ADI_TB_DIR)/library/includes/Makeinclude_regmap.mk

# All test-bench dependencies except test programs
SV_DEPS += $(ADI_TB_DIR)/library/drivers/jesd/adi_jesd204_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_jesd_rx_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_jesd_tx_pkg.sv
SV_DEPS += $(ADI_TB_DIR)/library/regmaps/adi_regmap_jesd_tpl_pkg.sv

ENV_DEPS += $(ADI_TB_DIR)/library/drivers/jesd/jesd_exerciser.tcl
