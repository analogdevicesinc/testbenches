## Copyright 2024(c) Analog Devices, Inc.
####################################################################################
####################################################################################

ifeq ($(ADI_HDL_DIR),)
$(error Environment variable ADI_HDL_DIR not set, please set it with the absolute path to the hdl repository.)
endif

ifeq ($(ADI_TB_DIR),)
$(error Environment variable ADI_TB_DIR not set, please set it with the absolute path to the testbenches repository.)
endif

# Assumes this file is in <HDL>/testbenches/scripts/make_tb_path.mk
HDL_LIBRARY_PATH := $(ADI_HDL_DIR)/library/
TB_LIBRARY_PATH := $(ADI_TB_DIR)/library/
