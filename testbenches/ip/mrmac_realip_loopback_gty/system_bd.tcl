# ***************************************************************************
# ***************************************************************************
# Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
#
# In this HDL repository, there are many different and unique modules, consisting
# of various HDL (Verilog or VHDL) components. The individual modules are
# developed independently, and may be accompanied by separate and unique license
# terms.
#
# The user should read each of these license terms, and understand the
# freedoms and responsibilities that he or she has by using this source/core.
#
# This core is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.
#
# Redistribution and use of source or resulting binaries, with or without modification
# of this file, are permitted under one of the following two license terms:
#
#   1. The GNU General Public License version 2 as published by the
#      Free Software Foundation, which can be found in the top level directory
#      of this repository (LICENSE_GPL2), and also online at:
#      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
#
# OR
#
#   2. An ADI specific BSD license, which can be found in the top level directory
#      of this repository (LICENSE_ADIBSD), and also on-line at:
#      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
#      This will allow to generate bit files and not release the source code,
#      as long as it attaches to an ADI device.
#
# ***************************************************************************
# ***************************************************************************

# ---------------------------------------------------------------------------
# Milestone-2 REAL-IP 1x100G loopback block design.
#
# This is the full real-encrypted-MRMAC counterpart of the behavioral
# mrmac_loopback TB. It instantiates:
#   * the BARE Corundum MAC shim  corundum/mrmac_gty_wrapper  as `mrmac_dut`
#     (fpga_core side 512b -> AXIS VIPs; MRMAC side 384b segmented -> the real MAC),
#   * the REAL MRMAC / GT stack  mrmac_0 + gtwiz_versal + clk_wizard +
#     mrmac_versal_glue,  wired EXACTLY as the island proc
#     corundum_vck190_build_mac (hdl/library/corundum/scripts/corundum_vck190_mac.tcl)
#     builds it -- the GTY sibling of the validate-rc=0 corundum_vpk180_build_mac.
#
# GTY vs the GTM original (mrmac_realip_loopback): GT_TYPE GTY on mrmac_0 +
# gtwiz_versal, the gtwiz GTY-Ethernet_25G_RAW preset, the glue CONFIG.GT_TYPE
# {GTY} (selects IBUFDS_GTE5 / VERSAL_AI_CORE / 80b-128b serdes widths), the GTY
# serdes pin names (tx_serdes_data/rx_serdes_data), and -- crucially -- the GT
# serial loopback in system_tb.sv is now a PLAIN WIRE ALIAS (GTY p/n pins carry
# real data) instead of the GTM two-step *_integer hierarchical force. This is
# the whole reason for the pivot: GTM's boolean p/n float Z and rx_reset_done
# never locked; GTY closes the loop on real data and reaches rx_reset_done.
#
# The structure mirrors that proc section-by-section (the section headers below
# match the proc's) so this file stays diffable against the validated original.
# THREE sections are adapted for the TB (everything else is verbatim from the
# proc, mrmac_0<->gtwiz<->glue only):
#   * sec 2  (board clocks/resets): the proc's board PORTS become TB clock VIPs
#            (156.25 MHz GT refclk diff pair + 100 MHz free-running) and a
#            proc_sys_reset (mac_resetn). mrmac_0/s_axi clock+reset are driven by
#            the harness management domain (see sec 9) so the register path is
#            single-clock through the interconnect.
#   * sec 4b (shim AXIS clock/reset): the proc's ethernet_core/mrmac_{tx,rx}_axi_clk
#            / mrmac_{tx,rx}_reset_in have NO `mrmac_` prefix on the bare wrapper
#            (tx_axi_clk / rx_axi_clk / tx_reset_in / rx_reset_in) -> hand-mapped.
#   * sec 6/6b/6c (glue<->shim AXIS/PTP/pause): pin names MATCH the bare wrapper
#            1:1, so it is a pure s/ethernet_core/mrmac_dut/.
#   * sec 9  (boundary): the proc's qsfp_serial / s_axi_mac / s_axi_gt boundary
#            connects become a TB GT serial breakout (closed in system_tb via a
#            plain wire alias -- GTY p/n carry real data, unlike GTM) + an
#            ad_cpu_interconnect mapping of mrmac_0/s_axi into the base management
#            VIP for the register bring-up (MRMAC has NO hardware tx/rx-enable pin).
#
# The fpga_core-facing datapath + byte-exact scoreboard wiring (AXIS master/slave
# VIPs on mrmac_dut) is taken from the behavioral mrmac_loopback/system_bd.tcl.
#
# See memory: [[mrmac-realip-loopback-m2-plan]], [[mrmac-gtwiz-framework-derisk]],
# [[mrmac-mac-enable-via-axi]], [[mrmac-100g-clocking-topology]],
# [[corundum-mac-wrapper-contract]].
# ---------------------------------------------------------------------------

global ad_project_params
global ad_hdl_dir
# NOTE: do NOT 'global sys_cpu_clk' / 'sys_cpu_resetn' here. This file is sourced
# INSIDE the adi_sim_project_xilinx proc, and test_harness_system_bd.tcl (sourced
# earlier in the same proc scope) already `set` them as LOCALS (lines 130-132:
# "set sys_cpu_clk sys_cpu_clk"). Declaring them global when a local of the same
# name exists throws 'variable "sys_cpu_clk" already exists'. They are already in
# scope as locals holding "sys_cpu_clk"/"sys_cpu_resetn" -- use $sys_cpu_clk /
# $sys_cpu_resetn directly (see s_axi pre-connect below).

set MODE           $ad_project_params(MODE)
set DATA_WIDTH     $ad_project_params(DATA_WIDTH)
set TX_TUSER_WIDTH $ad_project_params(TX_TUSER_WIDTH)
set RX_TUSER_WIDTH $ad_project_params(RX_TUSER_WIDTH)
set GT_REFCLK_HZ   $ad_project_params(GT_REFCLK_HZ)
set FREERUN_HZ     $ad_project_params(FREERUN_HZ)

set NUM_BYTES [expr {$DATA_WIDTH/8}]

##########################################################################
# 0. Register the glue RTL in the project source fileset (proc sec 0).
#    create_bd_cell -type module -reference mrmac_versal_glue needs the module's
#    RTL in the sources fileset or it resolves to an empty black box.
##########################################################################
set_property source_mgmt_mode All [current_project]
set glue_v "$ad_hdl_dir/library/corundum/versal/mrmac_versal_glue.v"
if {[lsearch -exact [get_files -quiet -of_objects [get_filesets sources_1]] $glue_v] < 0} {
  add_files -norecurse -fileset sources_1 $glue_v
  update_compile_order -fileset sources_1
}

##########################################################################
# 1. Companion-network BD cells (proc sec 1, VERBATIM config).
##########################################################################
create_bd_cell -type ip -vlnv xilinx.com:ip:mrmac mrmac_0
set_property -dict [list \
  CONFIG.MRMAC_PRESET_C0 {1x100GE CAUI-4 Wide} \
  CONFIG.MRMAC_MODE_C0 {MAC+PCS} \
  CONFIG.MRMAC_DATA_PATH_INTERFACE_PORT0_C0 {Independent 384b Segmented} \
  CONFIG.MAC_PORT0_RATE_C0 {100GE} \
  CONFIG.GT_TYPE_C0 {GTY} \
  CONFIG.GT_REF_CLK_FREQ_C0 {156.25} \
  CONFIG.MRMAC_IS_GT_WIZ_OLD {0} \
  CONFIG.INCLUDE_AUTO_NEG_LT_LOGIC_C0 {None} \
  CONFIG.MAC_PORT0_TX_FLOW_C0 {1} \
  CONFIG.MAC_PORT0_RX_FLOW_C0 {1} \
  CONFIG.MAC_PORT0_ENABLE_TIME_STAMPING_C0 {1} \
  CONFIG.PORT0_1588v2_Operation_MODE_C0 {2-step} \
  CONFIG.PORT0_1588v2_Clocking_C0 {Ordinary/Boundary Clock} \
  CONFIG.TIMESTAMP_CLK_PERIOD_NS {4.0} \
] [get_bd_cells mrmac_0]

# gtwiz_versal: SIM_SPEEDUP {false} -- REQUIRED for rx_reset_done.
# The user's VCK190/GTY reference example (mrmac_0_ex/.../mrmac_0_gtwiz_versal.xci)
# ships SIM_SPEEDUP=false and its exdes_tb reaches stat_mst_reset_done over a plain
# gt_txp<->gt_rxp wire loopback. Same rule that held on GTM: SIM_SPEEDUP=true
# shortcuts the GT power-up ramp; with the freerun fixed (200 MHz) + power-on-pulse
# reset it DOES reach gtpowergood + tx_reset_done, but rx_reset_done stays 0 -- the
# shortcut path does not sequence the RX datapath reset the way the full ramp does.
# With false the RX reset FSM completes its full ramp and the GTY sim model declares
# CDR lock on the loopback'd line (rx_reset_done asserts BEFORE any real data, as in
# the exdes). Costs ~1 hour wall-clock (full ramp) -- that is EXPECTED, not a hang.
# NOTE: the earlier "add back SIM_SPEEDUP=true" step was made during the 100 MHz
# freerun confound (P_FREERUN_FREQUENCY=200 made every timer count 2x, stalling
# powergood REGARDLESS of SIM_SPEEDUP); now that the freerun is 200 MHz that
# confound is gone and the true residual divergence from the proven refs is this
# knob. (MRMAC RX-align speedup is separate: the SIM_SPEED_UP +define below stays on.)
create_bd_cell -type ip -vlnv xilinx.com:ip:gtwiz_versal gtwiz_versal
set_property -dict [list \
  CONFIG.NO_OF_INTERFACE {1} \
  CONFIG.INTF0_NO_OF_LANES {4} \
  CONFIG.QUAD0_NO_PROT {1} \
  CONFIG.QUAD0_PROT0_LANES {4} \
  CONFIG.QUAD0_PROT0_TX1_EN {true} \
  CONFIG.QUAD0_PROT0_TX2_EN {true} \
  CONFIG.QUAD0_PROT0_TX3_EN {true} \
  CONFIG.QUAD0_PROT0_RX1_EN {true} \
  CONFIG.QUAD0_PROT0_RX2_EN {true} \
  CONFIG.QUAD0_PROT0_RX3_EN {true} \
  CONFIG.QUAD0_TX0_OUTCLK_EN {true} \
  CONFIG.QUAD0_RX0_OUTCLK_EN {true} \
  CONFIG.QUAD0_RX1_OUTCLK_EN {true} \
  CONFIG.QUAD0_RX2_OUTCLK_EN {true} \
  CONFIG.QUAD0_RX3_OUTCLK_EN {true} \
  CONFIG.QUAD0_PROT0_TXMSTCLK {TX0} \
  CONFIG.QUAD0_PROT0_RXMSTCLK {RX0} \
  CONFIG.ENABLE_REG_INTERFACE {true} \
  CONFIG.REG_CONF_INTF {AXI_LITE} \
  CONFIG.GT_TYPE {GTY} \
  CONFIG.SIM_SPEEDUP {false} \
  CONFIG.INTF0_GT_SETTINGS {LR0_SETTINGS {preset GTY-Ethernet_25G_RAW GT_TYPE GTY TX_DATA_ENCODING RAW RX_DATA_DECODING RAW TX_LINE_RATE 25.78125 RX_LINE_RATE 25.78125 TX_USER_DATA_WIDTH 80 RX_USER_DATA_WIDTH 80 TX_INT_DATA_WIDTH 80 RX_INT_DATA_WIDTH 80 TX_PLL_TYPE LCPLL TX_REFCLK_FREQUENCY 156.25 RX_REFCLK_FREQUENCY 156.25 TXPROGDIV_FREQ_VAL 644.531 RXPROGDIV_FREQ_VAL 644.531}} \
] [get_bd_cells gtwiz_versal]

create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clk_wizard
# PRIM_IN_FREQ is pinned to the freerun rate (200 MHz) so the MMCM re-solves its
# dividers for a 200 MHz clk_in1 and the AXIS (390.625) / ts (250) outputs stay
# fixed. If left unset the input frequency is *propagated* from the driving net
# (was 100 MHz) and the requested outputs would silently double when the freerun
# moved to 200 MHz. Kept in lock-step with cfg FREERUN_HZ (see cfg_1x100g.tcl).
set_property -dict [list \
  CONFIG.PRIM_IN_FREQ [expr {$FREERUN_HZ / 1000000.0}] \
  CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {390.625,250.000,100.000,100.000,100.000,100.000,100.000} \
  CONFIG.CLKOUT_USED {true,true,false,false,false,false,false} \
  CONFIG.PRIM_SOURCE {Global_buffer} \
] [get_bd_cells clk_wizard]

create_bd_cell -type module -reference mrmac_versal_glue mrmac_versal_glue
# GTY: select IBUFDS_GTE5 / BUFG_GT SIM_DEVICE VERSAL_AI_CORE / 80b-128b serdes
# widths. A -type module -reference cell auto-exposes the RTL params as CONFIG.*.
# Default GT_TYPE="GTM" would keep the vpk180 (IBUFDS_GTME5 / VERSAL_PREMIUM /
# 160b-256b) behavior, so this override is what makes the glue GTY on VCK190.
# RX_PER_LANE_CLK=1 selects the four per-lane RX MBUFG_GTs (see the QUAD0_RX*_OUTCLK_EN
# block above); set explicitly rather than left to derive from GT_TYPE, because
# falling back to the GTM default (0) would silently restore the lane-0 broadcast.
set_property -dict [list \
  CONFIG.GT_TYPE {GTY} \
  CONFIG.MRMAC_SERDES_W {80} \
  CONFIG.GT_CH_W {128} \
  CONFIG.RX_PER_LANE_CLK {1} \
] [get_bd_cells mrmac_versal_glue]

# MRMAC RX alignment-marker SIM speedup. SIM_SPEED_UP is a compile define
# consumed INSIDE the MRMAC IP RTL (mrmac_0_wrapper.v selects the RX VL length
# CTL_RX_VL_LENGTH_MINUS1_100GE_0 = 0x01FF vs 0x3FFF -> ~32x shorter align time).
# Pushed through the adi_sim +define+ pipeline (adi_sim.tcl:104 sets verilog_define
# on sim_1 -> xvlog).
#
# The earlier "OPEN RISK: does a sim_1 verilog_define reach the OOC-generated MRMAC
# sim sources?" is now RESOLVED = YES. Verified against the generated run:
#   * compile.sh:28 carries the define on the top-level xvlog line, and
#   * system_tb_vlog.prj:79 lists test_harness_mrmac_0_0_wrapper.v in that SAME
#     compilation unit -- so the MRMAC RTL is compiled WITH the define.
# (It cannot be passed at xsim time: xsim takes no -d, defines are resolved by
# xvlog at compile. simulate.sh therefore carries no define flags by design.)
#
# Written with an explicit =1 value. Every consumer is a bare `ifdef SIM_SPEED_UP
# (wrapper.v:389 for RX and :632 for TX VL length, exdes_tb.v:308,409) so the VALUE
# is never compared -- =1 and the previous valueless form (which Vivado renders as
# -d SIM_SPEED_UP=true) are functionally identical. =1 is the explicit/portable form.
adi_sim_add_define "SIM_SPEED_UP=1"

##########################################################################
# DUT: the BARE Corundum MRMAC MAC shim (behavioral mrmac_loopback:84-86).
##########################################################################
ad_ip_instance mrmac_gty_wrapper mrmac_dut [list \
  MODE $MODE \
]

##########################################################################
# 2. Board clocks / resets into the companion network  (ADAPTED for the TB:
#    the proc's board PORTS become clock VIPs + a proc_sys_reset).
##########################################################################
# --- GT reference clock, 156.25 MHz differential pair. The glue's IBUFDS_GTE5
#     (GTY; IBUFDS_GTME5 on GTM) consumes gt_ref_clk_p/n and drives gtwiz
#     QUAD0_GTREFCLK0.
#
#     NOT a clk_vip: clk_vip_if.set_clk_frq stores the period as an INTEGER number
#     of ns (set_clk_period(1000000000/user_frequency)), so 156.25 MHz = 6.4 ns
#     truncates to 6 ns = 166.67 MHz -- and the GTY PLL, configured for a 156.25
#     MHz refclk, mis-locks. Instead expose the differential pair as boundary
#     INPUT ports and generate the clock with a plain always-toggle in
#     system_tb.sv, where the 1ps timebase represents 3.2 ns (3200 ps) exactly.
create_bd_port -dir I gt_ref_clk_p
create_bd_port -dir I gt_ref_clk_n
ad_connect gt_ref_clk_p mrmac_versal_glue/gt_ref_clk_p
ad_connect gt_ref_clk_n mrmac_versal_glue/gt_ref_clk_n
connect_bd_net [get_bd_pins mrmac_versal_glue/gt_refclk_out] \
               [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK0]

# --- Free-running clock, 200 MHz: GT bring-up FSM + AXIS-clock MMCM input.
#     (Unlike the proc, mrmac_0/s_axi_aclk is NOT on this net -- the register
#     path is driven from the management domain in sec 9.)
#
#     200 MHz (NOT 100): the encrypted gtwiz reset controller scales its PLL-reset
#     / CDR-timeout counters by a hardcoded P_FREERUN_FREQUENCY=200 (proven exdes
#     gtwiz also uses APB3_CLK_FREQUENCY=200); a 100 MHz freerun made the reset
#     timers count 2x wall-time and gtpowergood never asserted. clk_wizard
#     PRIM_IN_FREQ is pinned to 200 MHz above so the AXIS/ts outputs are unchanged.
#
#     Like the refclk, NOT a clk_vip: generated by a plain always-toggle in
#     system_tb.sv so both GT-side clocks share one idiom and the GT plane has no
#     clk_vip dependency. 200 MHz = 5 ns = 2500 ps is exact. Exposed as a
#     single-ended boundary INPUT port fanned out to the three freerun sinks.
# Declare the port as a clock at 200 MHz (-freq_hz) so Vivado propagates the real
# frequency to the connected clock sinks (gtwiz_freerun_clk, clk_wizard/clk_in1)
# instead of inferring/defaulting it to 100 MHz. The creation-time -freq_hz form is
# the validated idiom for a ROOT bd_port (CONFIG.FREQ_HZ is read-only only on
# HIERARCHY pins). Kept in lock-step with cfg FREERUN_HZ (single source of truth).
create_bd_port -dir I -type clk -freq_hz $FREERUN_HZ gt_freerun_clk
connect_bd_net [get_bd_ports gt_freerun_clk] \
               [get_bd_pins gtwiz_versal/gtwiz_freerun_clk] \
               [get_bd_pins clk_wizard/clk_in1]

# --- AXIS client clock (390.625 MHz) + PTP timestamp clock (250 MHz) into glue.
ad_connect mrmac_versal_glue/axis_clk_in clk_wizard/clk_out1
ad_connect mrmac_versal_glue/ts_clk_in   clk_wizard/clk_out2

# --- Board reset (active-low). proc_sys_reset off the framework system reset VIP,
#     synchronized to the free-running clock. peripheral_aresetn (active-low) is
#     the mac_resetn the glue expects on pl_resetn (-> gt_rst_all=~pl_resetn,
#     shim_axi_reset=~pl_resetn) and gtwiz QUAD0_s_axi_lite_resetn.
ad_ip_instance proc_sys_reset mac_rstgen
ad_ip_parameter mac_rstgen CONFIG.C_EXT_RST_WIDTH 1
ad_connect sys_rst_vip/rst_out       mac_rstgen/ext_reset_in
ad_connect gt_freerun_clk            mac_rstgen/slowest_sync_clk

ad_connect mrmac_versal_glue/pl_resetn          mac_rstgen/peripheral_aresetn
ad_connect gtwiz_versal/QUAD0_s_axi_lite_resetn mac_rstgen/peripheral_aresetn

##########################################################################
# 3. glue <-> gtwiz_versal  (proc sec 3, VERBATIM).
##########################################################################
# TX: one shared master outclk. RX: all four lane outclks, one per glue RX MBUFG
# (each lane's CDR recovers its own RX clock - PG314 fig X21095-062118, and
# mrmac_0_exdes.sv:650-654). Requires QUAD0_RX{1,2,3}_OUTCLK_EN {true} above.
connect_bd_net [get_bd_pins gtwiz_versal/QUAD0_TX0_outclk] \
               [get_bd_pins mrmac_versal_glue/gt_tx_outclk]
connect_bd_net [get_bd_pins gtwiz_versal/QUAD0_RX0_outclk] \
               [get_bd_pins mrmac_versal_glue/gt_rx_outclk]
for {set ch 1} {$ch < 4} {incr ch} {
  connect_bd_net [get_bd_pins gtwiz_versal/QUAD0_RX${ch}_outclk] \
                 [get_bd_pins mrmac_versal_glue/gt_rx_outclk_${ch}]
}
for {set ch 0} {$ch < 4} {incr ch} {
  connect_bd_net [get_bd_pins mrmac_versal_glue/gt_tx_usrclk_${ch}] \
                 [get_bd_pins gtwiz_versal/QUAD0_TX${ch}_usrclk]
  connect_bd_net [get_bd_pins mrmac_versal_glue/gt_rx_usrclk_${ch}] \
                 [get_bd_pins gtwiz_versal/QUAD0_RX${ch}_usrclk]
}

connect_bd_net [get_bd_pins gtwiz_versal/INTF0_TX_clr_out]       [get_bd_pins mrmac_versal_glue/gt_tx_clr]
connect_bd_net [get_bd_pins gtwiz_versal/INTF0_TX_clrb_leaf_out] [get_bd_pins mrmac_versal_glue/gt_tx_clrb_leaf]
connect_bd_net [get_bd_pins gtwiz_versal/INTF0_RX_clr_out]       [get_bd_pins mrmac_versal_glue/gt_rx_clr]
connect_bd_net [get_bd_pins gtwiz_versal/INTF0_RX_clrb_leaf_out] [get_bd_pins mrmac_versal_glue/gt_rx_clrb_leaf]

connect_bd_net [get_bd_pins gtwiz_versal/INTF0_rst_tx_done_out] [get_bd_pins mrmac_versal_glue/gt_rst_tx_done]
connect_bd_net [get_bd_pins gtwiz_versal/INTF0_rst_rx_done_out] [get_bd_pins mrmac_versal_glue/gt_rst_rx_done]

# --- INTF0_rst_all_in = ~gtpowergood  (BD-internal inverter, mxfe-EXACT).
#     ROOT CAUSE CORRECTED (2026-07-27, proven against the mxfe GTM reference):
#     the "~gtpowergood deadlock" theory was WRONG. The ONLY proven Versal-GTM TB
#     that actually reaches rx_reset_done -- testbenches/project/mxfe -- drives
#     INTF0_rst_all_in DIRECTLY from ~gt_powergood (system_tb.sv:50
#     `logic gt_reset = ~gt_powergood;` -> wrapper passthrough
#     .gtreset_in(gt_reset) -> .INTF0_rst_all_in(gtreset_in), NO sequencer/inverter
#     in between -- verified in the generated wrapper test_harness.v:3010,1038),
#     and it powers up + locks RX by ~59 us with SIM_SPEEDUP=false + a 100 MHz
#     freerun. So ~gtpowergood does NOT deadlock; it holds rst_all asserted exactly
#     as long as the GTM power-up ramp needs and releases the instant powergood
#     rises. The earlier "deadlock, stuck 700 us" observation was CONFOUNDED with
#     SIM_SPEEDUP=true (which bypasses the PMA serial model so RX never gets data)
#     and/or the 100 MHz-freerun timer bug; the fixed-width TB power-on pulse that
#     replaced it then FAILED the other way -- with SIM_SPEEDUP=false the pulse
#     released rst_all long before the (now-full) GTM ramp finished, so gtpowergood
#     stayed 0 past 550 us. The self-sequencing ~gtpowergood is the correct idiom
#     for BOTH speedup settings. Mirror mxfe exactly with a 1-bit NOT
#     (util_vector_logic), same as the M1 de-risk BD. glue gt_rst_all stays open.
ad_ip_instance util_vector_logic rst_all_inv [list \
  C_SIZE {1} \
  C_OPERATION {not} \
]
ad_connect gtwiz_versal/gtpowergood rst_all_inv/Op1
ad_connect rst_all_inv/Res          gtwiz_versal/INTF0_rst_all_in

##########################################################################
# 3b. FLAT serdes-data connect (MRMAC <-> gtwiz) THROUGH the glue (proc sec 3b).
##########################################################################
# GTY MRMAC serdes pin names are tx_serdes_data${n}/rx_serdes_data${n} [79:0]
# (GTM renamed+doubled them to txdata_in_${n}/rxdata_out_${n} [159:0]). The glue-
# side pin names (mrmac_txdata_in/mrmac_rxdata_out) are family-agnostic; only their
# WIDTH changed (80 via CONFIG.MRMAC_SERDES_W above). gt_ch_* stays 128b on GTY.
for {set n 0} {$n < 4} {incr n} {
  connect_bd_net [get_bd_pins mrmac_0/tx_serdes_data${n}] \
                 [get_bd_pins mrmac_versal_glue/mrmac_txdata_in_${n}]
  connect_bd_net [get_bd_pins mrmac_versal_glue/gt_ch_txdata_${n}] \
                 [get_bd_pins gtwiz_versal/INTF0_TX${n}_ch_txdata]
  connect_bd_net [get_bd_pins gtwiz_versal/INTF0_RX${n}_ch_rxdata] \
                 [get_bd_pins mrmac_versal_glue/gt_ch_rxdata_${n}]
  connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rxdata_out_${n}] \
                 [get_bd_pins mrmac_0/rx_serdes_data${n}]
}

##########################################################################
# 4. glue <-> mrmac_0 clocks / resets  (proc sec 4, VERBATIM).
##########################################################################
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_core_clk]      [get_bd_pins mrmac_0/tx_core_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_core_clk]      [get_bd_pins mrmac_0/rx_core_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_serdes_clk]    [get_bd_pins mrmac_0/rx_serdes_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_alt_serdes_clk] [get_bd_pins mrmac_0/tx_alt_serdes_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_alt_serdes_clk] [get_bd_pins mrmac_0/rx_alt_serdes_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_axi_clk] \
               [get_bd_pins mrmac_0/tx_axi_clk] \
               [get_bd_pins mrmac_0/rx_axi_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ts_clk] \
               [get_bd_pins mrmac_0/tx_ts_clk] \
               [get_bd_pins mrmac_0/rx_ts_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_flexif_clk] \
               [get_bd_pins mrmac_0/tx_flexif_clk] \
               [get_bd_pins mrmac_0/rx_flexif_clk]

connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_core_reset]   [get_bd_pins mrmac_0/tx_core_reset]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_core_reset]   [get_bd_pins mrmac_0/rx_core_reset]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_serdes_reset] [get_bd_pins mrmac_0/tx_serdes_reset]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_serdes_reset] [get_bd_pins mrmac_0/rx_serdes_reset]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_flexif_reset]    [get_bd_pins mrmac_0/rx_flexif_reset]

##########################################################################
# 4b. shim AXIS-domain clock + reset  (ADAPTED: bare wrapper pin names have NO
#     `mrmac_` prefix -- hand-mapped from the proc's ethernet_core names).
#       proc: ethernet_core/mrmac_tx_axi_clk  -> mrmac_dut/tx_axi_clk
#             ethernet_core/mrmac_rx_axi_clk  -> mrmac_dut/rx_axi_clk
#             ethernet_core/mrmac_tx_reset_in -> mrmac_dut/tx_reset_in
#             ethernet_core/mrmac_rx_reset_in -> mrmac_dut/rx_reset_in
##########################################################################
connect_bd_net [get_bd_pins clk_wizard/clk_out1] \
               [get_bd_pins mrmac_dut/tx_axi_clk] \
               [get_bd_pins mrmac_dut/rx_axi_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_axi_reset] \
               [get_bd_pins mrmac_dut/tx_reset_in] \
               [get_bd_pins mrmac_dut/rx_reset_in]

# drp bus shares the AXIS clock / shim reset (behavioral mrmac_loopback:91,94).
connect_bd_net [get_bd_pins clk_wizard/clk_out1]         [get_bd_pins mrmac_dut/drp_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_axi_reset] [get_bd_pins mrmac_dut/drp_rst]

##########################################################################
# 5. glue <-> mrmac_0 segmented AXIS  (proc sec 5, VERBATIM).
##########################################################################
for {set s 0} {$s < 6} {incr s} {
  connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tdata${s}]      [get_bd_pins mrmac_0/tx_axis_tdata${s}]
  connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tkeep_user${s}] [get_bd_pins mrmac_0/tx_axis_tkeep_user${s}]
  connect_bd_net [get_bd_pins mrmac_0/rx_axis_tdata${s}]      [get_bd_pins mrmac_versal_glue/mrmac_rx_axis_tdata${s}]
  connect_bd_net [get_bd_pins mrmac_0/rx_axis_tkeep_user${s}] [get_bd_pins mrmac_versal_glue/mrmac_rx_axis_tkeep_user${s}]
}
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tvalid_0] [get_bd_pins mrmac_0/tx_axis_tvalid_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tlast_0]  [get_bd_pins mrmac_0/tx_axis_tlast_0]
connect_bd_net [get_bd_pins mrmac_0/tx_axis_tready_0]                 [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tready_0]

connect_bd_net [get_bd_pins mrmac_0/rx_axis_tvalid_0] [get_bd_pins mrmac_versal_glue/mrmac_rx_axis_tvalid_0]
connect_bd_net [get_bd_pins mrmac_0/rx_axis_tlast_0]  [get_bd_pins mrmac_versal_glue/mrmac_rx_axis_tlast_0]
connect_bd_net [get_bd_pins mrmac_0/stat_rx_status_0] [get_bd_pins mrmac_versal_glue/mrmac_stat_rx_status_0]

##########################################################################
# 5b. glue <-> mrmac_0 PTP  (proc sec 5b, VERBATIM).
##########################################################################
connect_bd_net [get_bd_pins mrmac_0/rx_ptp_tstamp_out_0]        [get_bd_pins mrmac_versal_glue/mrmac_rx_ptp_tstamp_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_ptp_1588op_0]     [get_bd_pins mrmac_0/tx_ptp_1588op_in_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_ptp_tag_field_0]  [get_bd_pins mrmac_0/tx_ptp_tag_field_in_0]
connect_bd_net [get_bd_pins mrmac_0/tx_ptp_tstamp_out_0]        [get_bd_pins mrmac_versal_glue/mrmac_tx_ptp_tstamp_0]
connect_bd_net [get_bd_pins mrmac_0/tx_ptp_tstamp_tag_out_0]    [get_bd_pins mrmac_versal_glue/mrmac_tx_ptp_tstamp_tag_0]
connect_bd_net [get_bd_pins mrmac_0/tx_ptp_tstamp_valid_out_0]  [get_bd_pins mrmac_versal_glue/mrmac_tx_ptp_tstamp_valid_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_tx_ptp_systemtimer_0]  [get_bd_pins mrmac_0/ctl_tx_ptp_systemtimer_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_tx_ptp_st_sync_0]      [get_bd_pins mrmac_0/ctl_tx_ptp_st_sync_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_tx_ptp_st_overwrite_0] [get_bd_pins mrmac_0/ctl_tx_ptp_st_overwrite_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_rx_ptp_systemtimer_0]  [get_bd_pins mrmac_0/ctl_rx_ptp_systemtimer_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_rx_ptp_st_sync_0]      [get_bd_pins mrmac_0/ctl_rx_ptp_st_sync_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_rx_ptp_st_overwrite_0] [get_bd_pins mrmac_0/ctl_rx_ptp_st_overwrite_0]

##########################################################################
# 5c. glue <-> mrmac_0 flow control (pause)  (proc sec 5c, VERBATIM).
##########################################################################
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_tx_pause_enable_0] [get_bd_pins mrmac_0/ctl_tx_pause_enable_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_tx_pause_req_0]    [get_bd_pins mrmac_0/ctl_tx_pause_req_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_rx_pause_enable_0] [get_bd_pins mrmac_0/ctl_rx_pause_enable_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ctl_rx_pause_ack_0]    [get_bd_pins mrmac_0/ctl_rx_pause_ack_0]
connect_bd_net [get_bd_pins mrmac_0/stat_rx_pause_req_0]                   [get_bd_pins mrmac_versal_glue/mrmac_stat_rx_pause_req_0]

##########################################################################
# 6. glue <-> mrmac_dut (shim) segmented AXIS  (proc sec 6, s/ethernet_core/mrmac_dut/).
##########################################################################
connect_bd_net [get_bd_pins mrmac_dut/mrmac_tx_axis_tdata]      [get_bd_pins mrmac_versal_glue/shim_tx_axis_tdata]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_tx_axis_tkeep_user] [get_bd_pins mrmac_versal_glue/shim_tx_axis_tkeep_user]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_tx_axis_tvalid]     [get_bd_pins mrmac_versal_glue/shim_tx_axis_tvalid]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_tx_axis_tlast]      [get_bd_pins mrmac_versal_glue/shim_tx_axis_tlast]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_tx_axis_tready]  [get_bd_pins mrmac_dut/mrmac_tx_axis_tready]

connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_axis_tdata]      [get_bd_pins mrmac_dut/mrmac_rx_axis_tdata]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_axis_tkeep_user] [get_bd_pins mrmac_dut/mrmac_rx_axis_tkeep_user]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_axis_tvalid]     [get_bd_pins mrmac_dut/mrmac_rx_axis_tvalid]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_axis_tlast]      [get_bd_pins mrmac_dut/mrmac_rx_axis_tlast]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_stat_rx_status]     [get_bd_pins mrmac_dut/mrmac_stat_rx_status]

##########################################################################
# 6b. glue <-> mrmac_dut PTP  (proc sec 6b, s/ethernet_core/mrmac_dut/).
##########################################################################
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_ptp_tstamp]        [get_bd_pins mrmac_dut/mrmac_rx_ptp_tstamp]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_tx_ptp_1588op]           [get_bd_pins mrmac_versal_glue/shim_tx_ptp_1588op]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_tx_ptp_tag_field]        [get_bd_pins mrmac_versal_glue/shim_tx_ptp_tag_field]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_tx_ptp_tstamp]        [get_bd_pins mrmac_dut/mrmac_tx_ptp_tstamp]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_tx_ptp_tstamp_tag]    [get_bd_pins mrmac_dut/mrmac_tx_ptp_tstamp_tag]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_tx_ptp_tstamp_valid]  [get_bd_pins mrmac_dut/mrmac_tx_ptp_tstamp_valid]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_tx_ptp_systemtimer]      [get_bd_pins mrmac_versal_glue/shim_tx_ptp_systemtimer]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_tx_ptp_st_sync]          [get_bd_pins mrmac_versal_glue/shim_tx_ptp_st_sync]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_tx_ptp_st_overwrite]     [get_bd_pins mrmac_versal_glue/shim_tx_ptp_st_overwrite]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_rx_ptp_systemtimer]      [get_bd_pins mrmac_versal_glue/shim_rx_ptp_systemtimer]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_rx_ptp_st_sync]          [get_bd_pins mrmac_versal_glue/shim_rx_ptp_st_sync]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_rx_ptp_st_overwrite]     [get_bd_pins mrmac_versal_glue/shim_rx_ptp_st_overwrite]

##########################################################################
# 6c. glue <-> mrmac_dut flow control (pause)  (proc sec 6c, s/ethernet_core/mrmac_dut/).
##########################################################################
connect_bd_net [get_bd_pins mrmac_dut/mrmac_ctl_tx_pause_enable] [get_bd_pins mrmac_versal_glue/shim_ctl_tx_pause_enable]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_ctl_tx_pause_req]    [get_bd_pins mrmac_versal_glue/shim_ctl_tx_pause_req]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_ctl_rx_pause_enable] [get_bd_pins mrmac_versal_glue/shim_ctl_rx_pause_enable]
connect_bd_net [get_bd_pins mrmac_dut/mrmac_ctl_rx_pause_ack]    [get_bd_pins mrmac_versal_glue/shim_ctl_rx_pause_ack]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_stat_rx_pause_req] [get_bd_pins mrmac_dut/mrmac_stat_rx_pause_req]

# mrmac_dut/ctl_tx_enable, ctl_rx_enable, rx_fifo_overflow are shim OUTPUTS with
# no MRMAC sink (MRMAC has no hardware enable pin -> s_axi bring-up). Left open.

##########################################################################
# 7. Tie every UNUSED mrmac_0 input to 0  (proc sec 7, VERBATIM).
##########################################################################
# Pre-connect s_axi clock+reset BEFORE the sweep. s_axi_aclk/s_axi_aresetn are
# scalar pins, NOT members of the s_axi interface bus, so the exclusion dict
# below (built from get_bd_intf_pins mrmac_0/s_axi) does NOT cover them -- if left
# unconnected here the sweep would tie them to GND, and the ad_cpu_interconnect in
# section 9 would then fail with 'already connected to net GND_1_dout'. Driving
# them from the harness management domain first also makes ad_cpu_interconnect
# skip re-driving the clock and just attach the AXI interface + address segment
# (single-clock register path).
ad_connect $sys_cpu_clk    mrmac_0/s_axi_aclk
ad_connect $sys_cpu_resetn mrmac_0/s_axi_aresetn

set _excl [dict create]
foreach _mp [get_bd_pins -quiet -of [get_bd_intf_pins -quiet mrmac_0/s_axi]] {
  dict set _excl $_mp 1
}
foreach _p [lsort [get_bd_pins -quiet -of [get_bd_cells mrmac_0]]] {
  if {[get_property DIR $_p] ne "I"} continue
  if {[dict exists $_excl $_p]} continue
  if {[llength [get_bd_nets -quiet -of $_p]]} continue
  set _nm [lindex [split $_p /] end]
  ad_connect mrmac_0/$_nm GND
}

##########################################################################
# 8. GT (gtwiz) secondary inputs -> constants  (proc sec 8, VERBATIM).
##########################################################################
ad_ip_instance xlconstant gt_line_rate [list \
  CONST_WIDTH 8 \
  CONST_VAL 2 \
]
for {set ch 0} {$ch < 4} {incr ch} {
  connect_bd_net [get_bd_pins gt_line_rate/dout] [get_bd_pins gtwiz_versal/INTF0_TX${ch}_ch_txrate]
  connect_bd_net [get_bd_pins gt_line_rate/dout] [get_bd_pins gtwiz_versal/INTF0_RX${ch}_ch_rxrate]
}
ad_connect gtwiz_versal/INTF0_rst_tx_datapath_in          GND
ad_connect gtwiz_versal/INTF0_rst_rx_datapath_in          GND
ad_connect gtwiz_versal/INTF0_rst_tx_pll_and_datapath_in  GND
ad_connect gtwiz_versal/INTF0_rst_rx_pll_and_datapath_in  GND
ad_connect gtwiz_versal/QUAD0_gpi GND

##########################################################################
# 9. Boundary + register bring-up  (ADAPTED for the TB).
##########################################################################
# --- (a) GT serial breakout ports (M1 idiom). The gt_rtl master interface
#     Quad0_GT_Serial breaks out to discrete per-lane QUAD0_{txp,txn,rxp,rxn}[3:0]
#     pins; bring them to BD ports so system_tb.sv closes the loop. For GTY the
#     boolean p/n pins carry REAL data (the whole point of the GTM->GTY pivot), so
#     system_tb.sv closes the loop with a PLAIN WIRE ALIAS (gt_txp->gt_rxp,
#     gt_txn->gt_rxn) -- no hierarchical *_integer force. Matches the user's
#     VCK190/GTY exdes_tb, which loops gt_txp_out<->gt_rxp_in on a shared wire.
create_bd_port -dir O -from 3 -to 0 gt_txp
create_bd_port -dir O -from 3 -to 0 gt_txn
create_bd_port -dir I -from 3 -to 0 gt_rxp
create_bd_port -dir I -from 3 -to 0 gt_rxn
ad_connect gt_txp gtwiz_versal/QUAD0_txp
ad_connect gt_txn gtwiz_versal/QUAD0_txn
ad_connect gt_rxp gtwiz_versal/QUAD0_rxp
ad_connect gt_rxn gtwiz_versal/QUAD0_rxn

# --- (b) GT reset-done / powergood status ports (observed by the test program
#     to gate the s_axi bring-up until the transceiver is up).
create_bd_port -dir O rx_reset_done
create_bd_port -dir O tx_reset_done
create_bd_port -dir O gtpowergood
ad_connect rx_reset_done gtwiz_versal/INTF0_rst_rx_done_out
ad_connect tx_reset_done gtwiz_versal/INTF0_rst_tx_done_out
ad_connect gtpowergood   gtwiz_versal/gtpowergood

# --- (c) mrmac_0/s_axi into the base management VIP (MRMAC MAC bring-up).
#     s_axi_aclk/s_axi_aresetn were pre-connected to the harness management domain
#     in section 7 (before the GND-sweep), so ad_cpu_interconnect here finds the
#     clock already-connected and only attaches the AXI interface + creates the
#     address segment (single-clock register path). The absolute base address is
#     exported as MRMAC_BA (decimal) for the test program:
#     RegWrite32(`MRMAC_BA + offset, data).
set MRMAC 0x44A00000
ad_cpu_interconnect $MRMAC mrmac_0
adi_sim_add_define "MRMAC_BA=[format "%d" ${MRMAC}]"

# gtwiz Quad0_AXI_LITE (GT register plane) is left open, exactly as the M1
# gtwiz de-risk TB did (validate rc=0); the loopback needs no GT register writes.

##########################################################################
# fpga_core-facing datapath: AXIS master/slave VIPs + byte scoreboard
# (behavioral mrmac_loopback/system_bd.tcl:96-144). The AXIS clock is the REAL
# clk_wizard/clk_out1 (390.625 MHz) via mrmac_dut/tx_clk|rx_clk OUTPUTS -- NOT a
# standalone clk_vip -- so there is no axis_clk_vip to start/stop (see environment.sv).
##########################################################################
# TX stimulus: AXI4-Stream master VIP -> DUT axis_eth_tx (slave). tuser=17.
ad_ip_instance axi4stream_vip eth_tx_axis [list \
  INTERFACE_MODE {MASTER} \
  HAS_TREADY {1} \
  HAS_TLAST {1} \
  HAS_TKEEP {1} \
  TDEST_WIDTH {0} \
  TID_WIDTH {0} \
  TUSER_WIDTH $TX_TUSER_WIDTH \
  TDATA_NUM_BYTES $NUM_BYTES \
]
adi_sim_add_define "ETH_TX_AXIS=eth_tx_axis"

# aresetn (active-LOW) = mac_rstgen/peripheral_aresetn = pl_resetn. The glue's
# shim reset is shim_axi_reset = ~pl_resetn (active-high), so peripheral_aresetn
# deasserts at the EXACT sim instant the shim's tx_reset_in/rx_reset_in release
# -- VIP and shim leave reset together. (The glue has no active-low shim reset
# output.) proc_sys_reset outputs fan out, so reusing this net is fine.
ad_connect mrmac_dut/tx_clk eth_tx_axis/aclk
ad_connect mac_rstgen/peripheral_aresetn eth_tx_axis/aresetn
ad_connect mrmac_dut/axis_eth_tx eth_tx_axis/m_axis

# RX sink: DUT axis_eth_rx (master) -> AXI4-Stream slave VIP. NO TREADY. tuser=81.
ad_ip_instance axi4stream_vip eth_rx_axis [list \
  INTERFACE_MODE {SLAVE} \
  HAS_TREADY {0} \
  HAS_TLAST {1} \
  HAS_TKEEP {1} \
  TDEST_WIDTH {0} \
  TID_WIDTH {0} \
  TUSER_WIDTH $RX_TUSER_WIDTH \
  TDATA_NUM_BYTES $NUM_BYTES \
]
adi_sim_add_define "ETH_RX_AXIS=eth_rx_axis"

ad_connect mrmac_dut/rx_clk eth_rx_axis/aclk
ad_connect mac_rstgen/peripheral_aresetn eth_rx_axis/aresetn
ad_connect mrmac_dut/axis_eth_rx eth_rx_axis/s_axis

# fpga_core-side datapath enables held asserted (MRMAC enable itself is via s_axi;
# these are decorative for MRMAC, matching the behavioral loopback).
ad_connect mrmac_dut/tx_enable  VCC
ad_connect mrmac_dut/rx_enable  VCC

# fpga_core-side pause (flow-control) inputs: M2 does not exercise flow control,
# so tie every request/enable/ack to GND (pause disabled). These are members of
# the flow_control_tx / flow_control_rx analog.com interfaces, so the DUT
# GND-sweep below EXCLUDES them (interface-member trap) -- they must be tied
# explicitly here or they float. rx_lfc_req / rx_pfc_req are OUTPUTS -> left open.
ad_connect mrmac_dut/tx_lfc_en  GND
ad_connect mrmac_dut/tx_lfc_req GND
ad_connect mrmac_dut/tx_pfc_en  GND
ad_connect mrmac_dut/tx_pfc_req GND
ad_connect mrmac_dut/rx_lfc_en  GND
ad_connect mrmac_dut/rx_lfc_ack GND
ad_connect mrmac_dut/rx_pfc_en  GND
ad_connect mrmac_dut/rx_pfc_ack GND

##########################################################################
# Tie off every remaining undriven mrmac_dut (shim) fpga_core-side input to GND
# (behavioral mrmac_loopback:216-245). The MRMAC-facing inputs are driven by the
# glue (carry nets -> skipped); interface members (axis_eth_tx/rx) are excluded.
##########################################################################
set _dut [get_bd_cells mrmac_dut]
set _dexcl [dict create]
foreach _if [get_bd_intf_pins -quiet -of $_dut] {
  foreach _mp [get_bd_pins -quiet -of $_if] { dict set _dexcl $_mp 1 }
}
foreach _pin [get_bd_pins -of $_dut -filter {DIR == I}] {
  set _nm [file tail $_pin]
  if {[regexp {clk$|_clk$|clk_|reset_in$|_rst$|^drp_rst$} $_nm]} { continue }
  if {[dict exists $_dexcl $_pin]} { continue }
  if {[llength [get_bd_nets -quiet -of $_pin]] > 0} { continue }
  ad_connect $_pin GND
}

##########################################################################
# Sweep any remaining undriven scalar gtwiz inputs to GND (M1 idiom). Skip
# clocks, resets/pins already driven, and interface-member pins.
##########################################################################
set _gt [get_bd_cells gtwiz_versal]
set _gexcl [dict create]
foreach _if [get_bd_intf_pins -quiet -of $_gt] {
  foreach _mp [get_bd_pins -quiet -of $_if] { dict set _gexcl $_mp 1 }
}
foreach _pin [get_bd_pins -of $_gt -filter {DIR == I}] {
  set _nm [file tail $_pin]
  if {[regexp {clk$|_clk$|clk_|usrclk$|refclk} $_nm]}      { continue }
  if {[dict exists $_gexcl $_pin]}                         { continue }
  if {[llength [get_bd_nets -quiet -of $_pin]] > 0}        { continue }
  ad_connect $_pin GND
}
