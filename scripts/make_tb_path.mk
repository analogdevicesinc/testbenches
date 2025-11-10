## Copyright (C) 2024 Analog Devices, Inc.
####################################################################################
####################################################################################

ifeq ($(ADI_HDL_DIR),)
$(error Environment variable ADI_HDL_DIR not set, please set it with the absolute path to the hdl repository.)
endif

ADI_TB_DIR := $(shell git rev-parse --show-toplevel)
