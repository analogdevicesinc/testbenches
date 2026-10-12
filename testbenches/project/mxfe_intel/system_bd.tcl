###############################################################################
## Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

global ad_project_params

# The DMA tests stream 4096 16-bit samples (8 KB) through the offloads
set adc_fifo_samples_per_converter [expr 4096 / $ad_project_params(RX_JESD_M)]
set dac_fifo_samples_per_converter [expr 4096 / $ad_project_params(TX_JESD_M)]

set TRANSCEIVER_TYPE "GTS"
source $ad_hdl_dir/projects/ad9081_fmca_ebz/common/ad9081_fmca_ebz_qsys.tcl

adi_sim_add_define "JESD_MODE=\"$JESD_MODE\""

# The carrier side of the GTS PHY, the remaining glue of the a5e system_top is
# in system_tb
set jesd204_ref_clock [format {%.6f} $REF_CLK_RATE]
set syspll_freq [format {%.6f} [expr $RX_LANE_RATE / ($LINK_MODE == 1 ? 20 : 32)]]

ad_ip_instance intel_systemclk_gts gts_pll [list \
  syspll_mod_0 {User Configuration} \
  syspll_freq_mhz_0 $syspll_freq \
  refclk_xcvr_freq_mhz_0 $jesd204_ref_clock \
]

add_interface i_refclk_rdy conduit end
add_interface o_pll_lock   conduit end
add_interface refclk_xcvr  clock sink
add_interface o_syspll_c0  clock source

set_interface_property i_refclk_rdy EXPORT_OF gts_pll.i_refclk_rdy
set_interface_property o_pll_lock   EXPORT_OF gts_pll.o_pll_lock
set_interface_property refclk_xcvr  EXPORT_OF gts_pll.refclk_xcvr
set_interface_property o_syspll_c0  EXPORT_OF gts_pll.o_syspll_c0

ad_ip_instance altera_avalon_clock_source ref_clk_vip [list \
  CLOCK_RATE [expr int($REF_CLK_RATE * 1000000)] \
  CLOCK_UNIT 1 \
]
adi_sim_add_define "REF_CLK=ref_clk_vip"
add_interface ref_clk_out clock source
set_interface_property ref_clk_out EXPORT_OF ref_clk_vip.clk

ad_ip_instance altera_avalon_clock_source device_clk_vip [list \
  CLOCK_RATE [expr int($DEVICE_CLK_RATE)] \
  CLOCK_UNIT 1 \
]
adi_sim_add_define "DEVICE_CLK=device_clk_vip"
add_interface device_clk_out clock source
set_interface_property device_clk_out EXPORT_OF device_clk_vip.clk

# The clock source BFM is generated with a fixed rate, the one the link layer
# driver computes (calc_sysref_clk)
set LINK_CLK_RATE [expr $RX_LANE_RATE * 1000000 / ($LINK_MODE == 1 ? 40 : 66)]
set SYSREF_CLK_RATE [expr $LINK_CLK_RATE * $RX_DATA_PATH_WIDTH / \
  ($ad_project_params(RX_JESD_K) * $ad_project_params(RX_JESD_F))]
if {$SYSREF_CLK_RATE != int($SYSREF_CLK_RATE)} {
  send_message error "SYSREF rate $SYSREF_CLK_RATE Hz is not an integer"
}
ad_ip_instance altera_avalon_clock_source sysref_clk_vip [list \
  CLOCK_RATE [expr int($SYSREF_CLK_RATE)] \
  CLOCK_UNIT 1 \
]
adi_sim_add_define "SYSREF_CLK=sysref_clk_vip"
add_interface sysref_clk_out clock source
set_interface_property sysref_clk_out EXPORT_OF sysref_clk_vip.clk

foreach {name port} { \
  RX_DMA      mxfe_rx_dma.s_axi \
  TX_DMA      mxfe_tx_dma.s_axi \
  RX_XCVR     mxfe_rx_jesd204.link_management \
  TX_XCVR     mxfe_tx_jesd204.link_management \
  AXI_JESD_RX mxfe_rx_jesd204.link_reconfig \
  AXI_JESD_TX mxfe_tx_jesd204.link_reconfig \
  ADC_TPL     mxfe_rx_tpl.s_axi \
  DAC_TPL     mxfe_tx_tpl.s_axi \
  RX_OFFLOAD  mxfe_rx_data_offload.s_axi \
  TX_OFFLOAD  mxfe_tx_data_offload.s_axi \
} {
  set base [get_connection_parameter_value mng_avmm_vip.m0/$port baseAddress]
  adi_sim_add_define "${name}_BA=[format "%d" $base]"
}
