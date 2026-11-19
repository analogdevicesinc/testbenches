###############################################################################
## Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

global ad_project_params

# ---------------------------------------------------------------------------
# DUT: axi_ad9361 (wraps axi_ad9361_lvds_if internally)
# ---------------------------------------------------------------------------
# CMOS_OR_LVDS_N=0  — select the LVDS interface path
# USE_SSI_CLK=0     — bypass IBUFGDS/BUFG so l_clk_vip can drive clk directly
# MIMO_ENABLE=0     — maps to CLK_DESKEW=0 inside axi_ad9361_lvds_if
# IODELAY_CTRL=0    — disable IDELAYCTRL (not needed for functional simulation)
# MODE_1R1T         — set per configuration file
# ---------------------------------------------------------------------------

ad_ip_instance axi_ad9361 dut [list \
  CMOS_OR_LVDS_N          {0} \
  USE_SSI_CLK             {0} \
  MIMO_ENABLE             {0} \
  MODE_1R1T               $ad_project_params(MODE_1R1T) \
  IODELAY_CTRL            {0} \
]
adi_sim_add_define "DUT=dut"

# ---------------------------------------------------------------------------
# Dedicated L_CLK (DDR clock).  250 MHz chosen for convenience.
# Connected to dut/clk (the USE_SSI_CLK=0 bypass path).
# ---------------------------------------------------------------------------
ad_ip_instance clk_vip l_clk_vip [list \
  INTERFACE_MODE {MASTER} \
  FREQ_HZ 250000000 \
]
adi_sim_add_define "L_CLK=l_clk_vip"
ad_connect l_clk_vip/clk_out dut/clk

# ---------------------------------------------------------------------------
# AXI4-Lite — connect DUT register interface to the test harness AXI master.
# The test harness provides sys_cpu_clk and a standard AXI master at
# sys_ps8/M_AXI_HPM0_FPD (or equivalent).  Use ad_cpu_interconnect to map
# the DUT into the address space.
# ---------------------------------------------------------------------------
ad_cpu_interconnect 0x44A00000 dut

set AXI_AD9361_BA 0x44A00000
set_property offset $AXI_AD9361_BA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dut}]
adi_sim_add_define "AXI_AD9361_BA=[format "%d" ${AXI_AD9361_BA}]"

# s_axi_aclk and s_axi_aresetn are wired automatically by ad_cpu_interconnect

# ---------------------------------------------------------------------------
# Physical LVDS RX pins
# ---------------------------------------------------------------------------
# Each differential pair needs a NOT gate so IBUFDS sees a valid complement.

# rx_clk_in — IBUFGDS port (not used for clocking; USE_SSI_CLK=0)
ad_ip_instance io_vip rx_clk_vip [list MODE {1} WIDTH {1}]
adi_sim_add_define "RX_CLK=rx_clk_vip"
ad_connect rx_clk_vip/clk l_clk_vip/clk_out
ad_ip_instance util_vector_logic rx_clk_inv [list C_SIZE {1} C_OPERATION {not}]
ad_connect rx_clk_vip/o dut/rx_clk_in_p
ad_connect rx_clk_vip/o rx_clk_inv/Op1
ad_connect rx_clk_inv/Res dut/rx_clk_in_n

# rx_frame_in
ad_ip_instance io_vip rx_frame_vip [list MODE {1} WIDTH {1}]
adi_sim_add_define "RX_FRAME=rx_frame_vip"
ad_connect rx_frame_vip/clk l_clk_vip/clk_out
ad_ip_instance util_vector_logic rx_frame_inv [list C_SIZE {1} C_OPERATION {not}]
ad_connect rx_frame_vip/o dut/rx_frame_in_p
ad_connect rx_frame_vip/o rx_frame_inv/Op1
ad_connect rx_frame_inv/Res dut/rx_frame_in_n

# rx_data_in[5:0]
ad_ip_instance io_vip rx_data_vip [list MODE {1} WIDTH {6}]
adi_sim_add_define "RX_DATA=rx_data_vip"
ad_connect rx_data_vip/clk l_clk_vip/clk_out
ad_ip_instance util_vector_logic rx_data_inv [list C_SIZE {6} C_OPERATION {not}]
ad_connect rx_data_vip/o dut/rx_data_in_p
ad_connect rx_data_vip/o rx_data_inv/Op1
ad_connect rx_data_inv/Res dut/rx_data_in_n

# ---------------------------------------------------------------------------
# Physical LVDS TX pins — slave io_vip instances to observe outputs
# ---------------------------------------------------------------------------
ad_ip_instance io_vip tx_frame_vip [list MODE {0} WIDTH {1}]
adi_sim_add_define "TX_FRAME=tx_frame_vip"
ad_connect tx_frame_vip/clk l_clk_vip/clk_out
ad_connect dut/tx_frame_out_p tx_frame_vip/i
# tx_frame_out_n, tx_clk_out_p/n left unconnected

ad_ip_instance io_vip tx_data_vip [list MODE {0} WIDTH {6}]
adi_sim_add_define "TX_DATA=tx_data_vip"
ad_connect tx_data_vip/clk l_clk_vip/clk_out
ad_connect dut/tx_data_out_p tx_data_vip/i
# tx_data_out_n left unconnected

# ---------------------------------------------------------------------------
# ADC data outputs (DMA side) — slave io_vip to observe
# ---------------------------------------------------------------------------
ad_ip_instance io_vip adc_valid_i0_vip [list MODE {0} WIDTH {1}]
adi_sim_add_define "ADC_VALID_I0=adc_valid_i0_vip"
ad_connect adc_valid_i0_vip/clk l_clk_vip/clk_out
ad_connect dut/adc_valid_i0 adc_valid_i0_vip/i

ad_ip_instance io_vip adc_data_i0_vip [list MODE {0} WIDTH {16}]
adi_sim_add_define "ADC_DATA_I0=adc_data_i0_vip"
ad_connect adc_data_i0_vip/clk l_clk_vip/clk_out
ad_connect dut/adc_data_i0 adc_data_i0_vip/i

ad_ip_instance io_vip adc_valid_q0_vip [list MODE {0} WIDTH {1}]
adi_sim_add_define "ADC_VALID_Q0=adc_valid_q0_vip"
ad_connect adc_valid_q0_vip/clk l_clk_vip/clk_out
ad_connect dut/adc_valid_q0 adc_valid_q0_vip/i

ad_ip_instance io_vip adc_data_q0_vip [list MODE {0} WIDTH {16}]
adi_sim_add_define "ADC_DATA_Q0=adc_data_q0_vip"
ad_connect adc_data_q0_vip/clk l_clk_vip/clk_out
ad_connect dut/adc_data_q0 adc_data_q0_vip/i

# 1R1T mode uses only I0/Q0; in 2R2T also observe I1/Q1
ad_ip_instance io_vip adc_valid_i1_vip [list MODE {0} WIDTH {1}]
adi_sim_add_define "ADC_VALID_I1=adc_valid_i1_vip"
ad_connect adc_valid_i1_vip/clk l_clk_vip/clk_out
ad_connect dut/adc_valid_i1 adc_valid_i1_vip/i

ad_ip_instance io_vip adc_data_i1_vip [list MODE {0} WIDTH {16}]
adi_sim_add_define "ADC_DATA_I1=adc_data_i1_vip"
ad_connect adc_data_i1_vip/clk l_clk_vip/clk_out
ad_connect dut/adc_data_i1 adc_data_i1_vip/i

ad_ip_instance io_vip adc_valid_q1_vip [list MODE {0} WIDTH {1}]
adi_sim_add_define "ADC_VALID_Q1=adc_valid_q1_vip"
ad_connect adc_valid_q1_vip/clk l_clk_vip/clk_out
ad_connect dut/adc_valid_q1 adc_valid_q1_vip/i

ad_ip_instance io_vip adc_data_q1_vip [list MODE {0} WIDTH {16}]
adi_sim_add_define "ADC_DATA_Q1=adc_data_q1_vip"
ad_connect adc_data_q1_vip/clk l_clk_vip/clk_out
ad_connect dut/adc_data_q1 adc_data_q1_vip/i

# adc_status is internal to axi_ad9361 (not a top-level port).
# Frame error is visible via adc_r1_mode / register reads over AXI.

# ---------------------------------------------------------------------------
# DAC data inputs (DMA side) — master io_vip to drive
# ---------------------------------------------------------------------------
ad_ip_instance io_vip dac_data_i0_vip [list MODE {1} WIDTH {16}]
adi_sim_add_define "DAC_DATA_I0=dac_data_i0_vip"
ad_connect dac_data_i0_vip/clk l_clk_vip/clk_out
ad_connect dac_data_i0_vip/o dut/dac_data_i0

ad_ip_instance io_vip dac_data_q0_vip [list MODE {1} WIDTH {16}]
adi_sim_add_define "DAC_DATA_Q0=dac_data_q0_vip"
ad_connect dac_data_q0_vip/clk l_clk_vip/clk_out
ad_connect dac_data_q0_vip/o dut/dac_data_q0

ad_ip_instance io_vip dac_data_i1_vip [list MODE {1} WIDTH {16}]
adi_sim_add_define "DAC_DATA_I1=dac_data_i1_vip"
ad_connect dac_data_i1_vip/clk l_clk_vip/clk_out
ad_connect dac_data_i1_vip/o dut/dac_data_i1

ad_ip_instance io_vip dac_data_q1_vip [list MODE {1} WIDTH {16}]
adi_sim_add_define "DAC_DATA_Q1=dac_data_q1_vip"
ad_connect dac_data_q1_vip/clk l_clk_vip/clk_out
ad_connect dac_data_q1_vip/o dut/dac_data_q1

# Observe dac_valid outputs from DUT
ad_ip_instance io_vip dac_valid_i0_vip [list MODE {0} WIDTH {1}]
adi_sim_add_define "DAC_VALID_I0=dac_valid_i0_vip"
ad_connect dac_valid_i0_vip/clk l_clk_vip/clk_out
ad_connect dut/dac_valid_i0 dac_valid_i0_vip/i

ad_ip_instance io_vip dac_valid_q0_vip [list MODE {0} WIDTH {1}]
adi_sim_add_define "DAC_VALID_Q0=dac_valid_q0_vip"
ad_connect dac_valid_q0_vip/clk l_clk_vip/clk_out
ad_connect dut/dac_valid_q0 dac_valid_q0_vip/i

# ---------------------------------------------------------------------------
# Remaining DUT inputs tied to zero via GND_1 (pre-created by test harness)
# or dedicated xlconstant cells for wider ports.
# ---------------------------------------------------------------------------

ad_connect GND_1/dout dut/dac_sync_in
ad_connect GND_1/dout dut/tdd_sync
ad_connect GND_1/dout dut/gps_pps
ad_connect GND_1/dout dut/adc_dovf
ad_connect GND_1/dout dut/dac_dunf
ad_connect GND_1/dout dut/up_enable
ad_connect GND_1/dout dut/up_txnrx

# delay_clk must not be zero: ad_rst inside up_delay_cntrl is clocked by it;
# with delay_clk=0 delay_rst_s stays X and propagates through up_rdata.
# Reuse l_clk — frequency does not matter for functional simulation.
ad_connect l_clk_vip/clk_out dut/delay_clk

foreach {port width} {
  up_dac_gpio_in  32
  up_adc_gpio_in  32
} {
  set cell_name "gnd_${width}b_${port}"
  ad_ip_instance xlconstant $cell_name [list \
    CONST_WIDTH $width \
    CONST_VAL   0 \
  ]
  ad_connect ${cell_name}/dout dut/${port}
}
