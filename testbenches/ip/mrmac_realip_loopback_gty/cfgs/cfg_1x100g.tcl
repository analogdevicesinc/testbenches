global ad_project_params

# Target the VCK190 (Versal AI Core, xcvc1902, GTY) so the sim project does not
# fall back to the random board picker (which may choose a board whose part is
# not installed). FPGA_BOARD -> vck190 -> adi_part_decode ->
# xcvc1902-vsva2197-2MP-e-S (installed). This is the GTY sibling of the vpk180
# (GTM) cfg -- the whole reason for the pivot: GTY carries real data on its
# boolean serial p/n pins so the loopback closes with a plain wire alias.
set ad_project_params(FPGA_BOARD) "vck190"

# ---------------------------------------------------------------------------
# Milestone-2 REAL-IP 1x100G loopback configuration.
#
# This testbench drives 512b packets from an AXI-Stream master VIP through the
# BARE Corundum MAC shim (corundum/mrmac_gty_wrapper, MODE 1x100G) whose
# MRMAC-facing segmented bus is stitched to the REAL encrypted MRMAC + GT stack
# (mrmac_0 + gtwiz_versal + clk_wizard + mrmac_versal_glue, exactly as the
# island proc corundum_vck190_build_mac builds it -- the GTY sibling of the
# validate-rc=0 corundum_vpk180_build_mac), and closes the link over a GT serial
# loopback. A byte-exact scoreboard checks the RX byte stream against the TX byte
# stream. Built on the M1 gtwiz de-risk foundation (testbenches/ip/mrmac_realip_gt),
# which proved the encrypted GT elaborates and reaches reset-done under this xsim
# flow.
# ---------------------------------------------------------------------------
set ad_project_params(MODE) "1x100G"

# fpga_core-facing AXI-Stream geometry (matches mrmac_gty_wrapper.v):
#   tx_axis : 512b data, tuser = {tag[15:0], error}          -> 17 bits
#   rx_axis : 512b data, tuser = {ptp_ts[79:0], error}       -> 81 bits
set ad_project_params(DATA_WIDTH)     512
set ad_project_params(TX_TUSER_WIDTH)  17
set ad_project_params(RX_TUSER_WIDTH)  81

# GT reference-clock frequency in Hz. Unlike the behavioral loopback (a single
# standalone AXIS clk_vip), the AXIS client clock here is produced by the REAL
# clk_wizard (390.625 MHz off clk_out1) fed from the free-running clock; the only
# clock VIPs are the two GT clocks below. The test program pins both exactly at
# runtime via `TH.<VIP>.inst.IF.set_clk_frq() before start_clock() (the
# jesd_loopback REF_CLK idiom) so 1/156.25 MHz = 6.4 ns is represented exactly.
#
# 156.25 MHz is load-bearing: the GT PLL is configured for TX/RX_REFCLK_FREQUENCY
# 156.25 (GT_REF_CLK_FREQ_C0 of the island corundum_vck190_mac.tcl, GTY), so
# the refclk MUST be exactly 156.25 MHz or the PLL will not lock. NOT the
# 322.27 MHz of the standalone Xilinx exdes (a different GT config).
set ad_project_params(GT_REFCLK_HZ) 156250000

# GT-wizard free-running clock (GT reset FSM / MRMAC+GT register access /
# clk_wizard clk_in1), 100 MHz (user override, 2026-07-28).
#
# WARNING - KNOWN RISK, accepted by the user: this freerun was previously 200 MHz
# because the encrypted gtwiz reset controller
# (mrmac_0_gtwiz_versal_reset_ip.v:52) hardcodes `parameter real
# P_FREERUN_FREQUENCY = 200`, and its PLL-reset / CDR-timeout counters are scaled
# by that constant (P_CDR_TIMEOUT_FREERUN_CYC = 37000*P_FREERUN_FREQUENCY/
# P_RX_LINE_RATE, P_*_PLL_RESET_FREERUN_CYC = 2*P_FREERUN_FREQUENCY+2). The proven
# exdes gtwiz also declares APB3_CLK_FREQUENCY=200 on this same net. A prior 100
# MHz attempt made every reset-timer window count 2x the intended wall-time and
# skewed the CDR-lock guard, and gtpowergood stayed 0 past 1 ms of sim (the proven
# exdes reaches its full byte-exact PASS by 414 us). The IP still assumes 200 MHz
# internally, so this 100 MHz value may re-break gtpowergood / reset-done; the
# change is applied at the user's explicit request. This is the single source of
# truth for the freerun rate: system_bd.tcl derives PRIM_IN_FREQ and the boundary
# clock -freq_hz from it, and system_tb.sv's clock-generator half-period must be
# kept in lock-step (5 ns for 100 MHz).
set ad_project_params(FREERUN_HZ) 100000000
