## Copyright 2024(c) Analog Devices, Inc.
####################################################################################
####################################################################################

# Assumes this file is in <HDL>/testbenches/scripts/make_tb_path.mk
ADI_HDL_DIR := $(subst /testbenches/scripts/make_tb_path.mk,,$(abspath $(lastword $(MAKEFILE_LIST))))
HDL_LIBRARY_PATH := $(ADI_HDL_DIR)/library/
ADI_TB_DIR := $(ADI_HDL_DIR)/testbenches/
TB_LIBRARY_PATH := $(ADI_TB_DIR)/library/
