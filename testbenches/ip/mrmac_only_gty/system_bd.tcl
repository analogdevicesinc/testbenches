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
# MRMAC-ONLY 1x100G loopback block design (VCK190 / GTY).
#
# This started as mrmac_realip_loopback_gty/system_bd.tcl with everything of OURS
# removed from the datapath and the register path, so that a pass/fail here would
# partition the bug: MRMAC/GT/glue plane vs Corundum shim + interconnect. That
# stripped baseline PASSED byte-exact (16/16 packets, all four MRMAC statistics
# counter pairs matching, Core_Version=1) and is frozen at baseline_pass/ with the
# evidence log and checksums. See cfgs/cfg_1x100g.tcl for the original rationale and
# baseline_pass/README.md for what the pass proves.
#
# The Corundum layer is now being re-introduced ONE PIECE AT A TIME on top of that
# baseline, each increment tested before the next is added, so a failure is
# attributable to the piece just added rather than to the stack as a whole.
#
#   INCREMENT 1: mrmac_tx_adapt + mrmac_rx_adapt, and with them the glue's AXIS
#   pack/unpack path -- unavoidably, since a BD net cannot slice the adapters'
#   packed 384b/66b bus down to mrmac_0's six segment pins.
#
#   INCREMENT 2 (this file): the shim's two axis_fifo instances and its three
#   sync_reset instances. Real Corundum library RTL, with the shim's own parameter
#   sets; the FIFOs go through thin local wrappers (mrmac_shim_fifo.v) for BD
#   elaboration reasons only. See section 5.
#
# WHAT IS INSTANTIATED (the MRMAC/GT/clocking cells are all REAL; nothing behavioral):
#   mrmac_0          - the encrypted MRMAC, config matched to the PASSING exdes
#   gtwiz_versal     - the encrypted GTY quad
#   clk_wizard       - AXIS client clock (390.625 MHz) + PTP ts clock (250 MHz)
#   mrmac_versal_glue- GT clock/reset plane (refclk IBUFDS, MBUFG_GTs, serdes width
#                      adaptation) AND, as of increment 1, its segmented-AXIS
#                      pack/unpack. Its PTP and pause/ctl inputs are still GND-swept:
#                      the shim modules that would drive them are not back yet
#                      (see section 6).
#   mrmac_tx_adapt / mrmac_rx_adapt - the first two Corundum shim modules, back in
#                      the datapath as of increment 1. Library RTL, unmodified.
#   axis_fifo x2       - the shim's TX store-and-forward frame FIFO (DEPTH 16384) and
#                      RX elastic dropping FIFO (DEPTH 4096), back as of increment 2.
#                      Unmodified Corundum library RTL with the shim's parameters;
#                      instantiated via mrmac_shim_fifo.v wrappers, which only fix
#                      the port widths as numerals and tie the ID/DEST/pause inputs
#                      this bench has no producer for. One deliberate parameter
#                      deviation: USER_WIDTH 1, not the shim's PTP-carrying 17/81.
#   sync_reset x3      - the shim's tx_rst / rx_rst / rx_ptp_rst synchronizers
#                      (N=4, async-set/sync-release), back as of increment 2.
#                      Unmodified library RTL, instantiated directly as BD cells.
#   mrmac_flat_pkt_gen / mrmac_flat_pkt_chk - thin flat-AXIS wrappers around the
#                      baseline's mrmac_seg_pkt_gen / mrmac_seg_pkt_chk (which are
#                      byte-identical to the frozen copies). Pure re-slicing: the
#                      adapters need a flat client bus, the segmented pair expose
#                      per-segment pins, and a BD net bridges neither.
#
# CONFIG DELTAS vs the sibling, each mirroring the PASSING reference exdes. Every
# one of these was found by diffing the exdes .xci / exdes.sv against ours; they are
# NOT guesses:
#
#   (1) MRMAC_DATA_PATH_INTERFACE_PORT0_C0: "Independent 384b Segmented"
#       -> "Independent 384b Non-Segmented"                       *** THE BIG ONE ***
#       Diffing the two GENERATED wrappers' parameters yields exactly one delta:
#         exdes:  parameter [2:0] CTL_AXIS_CFG_0 = 3'h5
#         ours:   parameter [2:0] CTL_AXIS_CFG_0 = 3'h7
#       mrmac_0.xml:10927 defines CTL_AXIS_CFG_0 as "Port 0 AXI4-Stream Mode" at
#       bitOffset 9, bitWidth 3 -> MODE_REG_0[11:9]. Both the exdes AND our own test
#       program write MODE_REG_0 = 0x40000A64, and (0x40000A64 >> 9) & 0x7 = 5.
#       So the register write has ALWAYS selected Non-Segmented while the IP was
#       GENERATED Segmented -- and mrmac_tx_adapt.v's header states outright that it
#       targets the non-segmented interface. Two-against-one: the generate-time
#       setting was the odd one out. The pin surface is byte-IDENTICAL between the
#       two settings (same 29 tx_axis_*/rx_axis_* port names, verified by grep), so
#       this changes an internal parameter only -- no rewiring on account of it. (The
#       datapath in section 5 has since changed for increment 1, but for an unrelated
#       reason: re-inserting the adapters.)
#
#   (2) MAC_PORT0_ENABLE_TIME_STAMPING_C0 1 -> 0, and
#       PORT0_1588v2_Operation_MODE_C0 "2-step" -> "No operation".
#       The exdes has timestamping OFF. Consistent with (4): it drives the ts clocks
#       to zero because it has no PTP logic to clock.
#       *** REVERSED BY INCREMENT 5 *** -- both are back ON. The PTP cells this
#       increment adds need mrmac_0's PTP pins, which only exist when timestamping is
#       enabled. Delta (4) is reversed with it. See the note at the config dict.
#
#   (3) MAC_PORT0_RX_FLOW_C0 1 -> 0 (TX_FLOW stays 1, as in the exdes).
#       This bench does not exercise flow control at all.
#
#   (4) mrmac_0 tx_ts_clk / rx_ts_clk: the glue's mrmac_ts_clk (250 MHz)
#       -> GND (4'b0000), matching exdes.sv:656-657 verbatim
#       (assign tx_ts_clk=4'b0000; assign rx_ts_clk=4'b0000;). Follows from (2):
#       with timestamping off there is no ts domain to clock. Achieved by simply NOT
#       connecting them, letting the section-7 GND sweep catch them.
#       *** REVERSED BY INCREMENT 5 *** -- both are now driven from the glue's
#       mrmac_ts_clk (= clk_wizard/clk_out2, 250 MHz) in section 5b, which is what
#       delta (2) being back on requires. A clocked-but-unused ts domain would be
#       harmless; an unclocked-but-enabled one would not sample anything.
#
#   (5) mrmac_0 tx_flexif_clk / rx_flexif_clk: the glue's mrmac_flexif_clk
#       -> GND (4'b0000), matching exdes.sv:616-617 verbatim. In the sibling these
#       were driven from axis_clk purely to dodge [BD 41-758] ("no clock source");
#       the exdes proves zero is acceptable to the IP. If 41-758 fires here as an
#       ERROR (not a warning) this is the one delta to revert -- but note the exdes
#       is the authority on what the IP tolerates.
#
#   (6) gt_line_rate: 8'h02 -> 8'h00.  The passing exdes runs with ZERO:
#       exdes_tb.v:351 sets gt_line_rate=8'h00 and line 416's `gt_line_rate=8'h02;`
#       is COMMENTED OUT. exdes.sv:1081 fans it to all four ch_{tx,rx}rate. Our
#       sibling's xlconstant CONST_VAL 2 was therefore a divergence from the only
#       known-good value.
#
#   (7) QUAD0_ch*_loopback: GND (3'b000) = EXTERNAL loopback, matching
#       exdes_tb.v:324 .gt_loopback(3'b000) -> exdes.sv:1367-1370. Same as the
#       sibling's GND sweep, so no change -- recorded here only to note it was
#       verified rather than assumed.
#
# DELIBERATELY UNCHANGED (do not "fix" these):
#   * gtwiz SIM_SPEEDUP {false} -- the reference ships false; true shortcuts the GT
#     power-up ramp and rx_reset_done never asserts. Costs ~1 h wall clock.
#   * INTF0_rst_all_in = ~gtpowergood via util_vector_logic -- mxfe-exact,
#     self-sequences the reset release off the power-up ramp. Note the exdes instead
#     drives it from a TB reg (gt_reset_all_in); the ~gtpowergood idiom is the one
#     PROVEN to reach rx_reset_done in an ADI framework TB, and the TB still applies
#     the exdes DOUBLE reset on top of it via pl_resetn (see tests/test_program.sv).
#   * The +define+ SIM_SPEED_UP=1 (shortens MRMAC RX alignment-marker time inside
#     the IP RTL; verified to reach the OOC-generated MRMAC sources).
#
# See memory: [[mrmac-double-reset-requirement]], [[mrmac-100g-clocking-topology]],
# [[mrmac-gtwiz-framework-derisk]], [[mrmac-mac-enable-via-axi]],
# [[mrmac-versal-bd-wiring-gotchas]], [[mrmac-segmented-axis-contract]].
# ---------------------------------------------------------------------------

global ad_project_params
global ad_hdl_dir

##########################################################################
# Helper: tie a bd_pin OBJECT to a zero constant, bypassing ad_connect.
#
# WHY THIS EXISTS. ad_connect resolves its arguments BY NAME, and it tries
# get_bd_intf_pins FIRST (hdl/projects/scripts/adi_board.tcl:71). Vivado's automatic
# interface inference on mrmac_versal_glue creates bd_intf_pins whose full path
# STRING is identical to a leaf pin's path -- e.g. the inferred 55-bit PTP interface
# and the real pin are both '/mrmac_versal_glue/mrmac_tx_ptp_tstamp_0'. Passing that
# name to ad_connect therefore resolves to the bd_intf_pin and dies with
#   ERROR: ad_connect: Cannot connect non-interface to interface: ... (bd_intf_pin)
# even though a bd_pin of that exact name exists and is perfectly connectable.
#
# The sweeps below already hold the pin OBJECT (from get_bd_pins), so the fix is to
# never round-trip it through a name. This replicates what ad_connect does after its
# switch (adi_board.tcl:251-255): size a shared ilconstant to the pin width and
# connect_bd_net it -- but against the object, so no name lookup can go astray.
# Constant cells are named GND_<width> and reused, exactly as
# ad_connect_int_get_const does, so this shares cells with ordinary ad_connect GND
# calls elsewhere in the file instead of littering the BD with duplicates.
proc gnd_pin_obj {pin} {
  set left  [get_property -quiet LEFT $pin]
  set right [get_property -quiet RIGHT $pin]
  if {($left eq "") || ($right eq "")} {
    set width 1
  } else {
    set width [expr {1 + max($left,$right) - min($left,$right)}]
  }

  set cell_name "GND_$width"
  set cell [get_bd_cells -quiet $cell_name]
  if {$cell eq ""} {
    ad_ip_instance ilconstant $cell_name
    set cell [get_bd_cells -quiet $cell_name]
    set_property CONFIG.CONST_WIDTH $width $cell
    set_property CONFIG.CONST_VAL   0      $cell
  }

  connect_bd_net [get_bd_pins $cell/dout] $pin
  puts "gnd_pin_obj: connect_bd_net $cell_name/dout $pin (width $width)"
}

# Helper: the all-ONES counterpart, same object-not-name discipline.
#
# WHY A SECOND HELPER RATHER THAN ad_connect VCC. Increment 6 is the first section that
# needs pins tied HIGH, and the ones that do are on port_map -- a cell whose port names
# (m_axis_rx_*, s_axis_tx_*, m_axis_tx_ptp_ts_*) are exactly the patterns Vivado
# auto-infers interfaces from. So the ad_connect name-resolution trap documented above
# applies here in full, and the fix is the same: never round-trip the pin through a name.
#
# Getting HIGH vs LOW right matters more than usual on this cell. port_map's RX path is
# gated by m_axis_rx_tready and its TX-stamp path by m_axis_tx_ptp_ts_ready; both have no
# producer in this bench. GND-sweeping them would stall those paths permanently while
# every other signal in the waveform looked correct -- a silent, hard-to-attribute
# failure. The sweep at the end of section 5c therefore ties these explicitly FIRST and
# relies on the "already driven" test to keep the blanket GND pass off them.
proc vcc_pin_obj {pin} {
  set left  [get_property -quiet LEFT $pin]
  set right [get_property -quiet RIGHT $pin]
  if {($left eq "") || ($right eq "")} {
    set width 1
  } else {
    set width [expr {1 + max($left,$right) - min($left,$right)}]
  }

  set cell_name "VCC_$width"
  set cell [get_bd_cells -quiet $cell_name]
  if {$cell eq ""} {
    ad_ip_instance ilconstant $cell_name
    set cell [get_bd_cells -quiet $cell_name]
    set_property CONFIG.CONST_WIDTH $width $cell
    # CONST_VAL for a multi-bit ilconstant is a plain integer, so all-ones is 2^w - 1.
    set_property CONFIG.CONST_VAL   [expr {(1 << $width) - 1}] $cell
  }

  connect_bd_net [get_bd_pins $cell/dout] $pin
  puts "vcc_pin_obj: connect_bd_net $cell_name/dout $pin (width $width)"
}

set MODE           $ad_project_params(MODE)
set GT_REFCLK_HZ   $ad_project_params(GT_REFCLK_HZ)
set FREERUN_HZ     $ad_project_params(FREERUN_HZ)
set NUM_PKTS       $ad_project_params(NUM_PKTS)
set PKT_BYTES      $ad_project_params(PKT_BYTES)
set IFG_BEATS      $ad_project_params(IFG_BEATS)
set STRIP_FCS      $ad_project_params(STRIP_FCS)

##########################################################################
# 0. Register the RTL modules in the project source fileset.
#    create_bd_cell -type module -reference <name> needs the module's RTL in the
#    sources fileset or it resolves to an empty black box (all outputs Z).
#    The shared glue, the two Corundum shim adapters (INCREMENT 1), and this
#    bench's generator/checker plus its flat-AXIS wrappers (local to this
#    directory -- they are test fixtures, not library RTL).
#
#    INCREMENT 2 adds the two Corundum generic modules the shim uses -- axis_fifo and
#    sync_reset -- from their CANONICAL paths, the same two files
#    mrmac_gty_wrapper_ip.tcl:54-55 packages. (Do not substitute one of the many
#    duplicate copies under corundum/fpga/mqnic/*/ or fpga/lib/pcie/example/*/.)
#    sync_reset is instantiated DIRECTLY as a BD cell -- three scalar ports and one
#    integer parameter, nothing for the elaborator to get wrong. axis_fifo is not:
#    it goes through mrmac_shim_fifo.v, for the reasons documented in that file's
#    header (expression-valued port widths + a dozen pins this bench has no
#    producer/consumer for, which no GND sweep here would cover).
##########################################################################
set_property source_mgmt_mode All [current_project]
#    Increments 3/4/5 add five more library files and three more bench files. The same
#    split applies: mrmac_ptp_ts_cvt is instantiated DIRECTLY (four ports, no clock, no
#    derived width -- it passes the same test sync_reset did), while cmac_pad,
#    axis_adapter, mac_ts_insert and mrmac_ptp_sync go through wrappers
#    (mrmac_shim_widthconv.v, mrmac_shim_ptp.v).
foreach _rtl [list \
  "$ad_hdl_dir/library/corundum/versal/mrmac_versal_glue.v" \
  "$ad_hdl_dir/library/corundum/versal/mrmac_tx_adapt.v" \
  "$ad_hdl_dir/library/corundum/versal/mrmac_rx_adapt.v" \
  "$ad_hdl_dir/library/corundum/versal/mrmac_ptp_ts_cvt.v" \
  "$ad_hdl_dir/library/corundum/versal/mrmac_ptp_sync.v" \
  "$ad_hdl_dir/../corundum/fpga/lib/axis/rtl/axis_fifo.v" \
  "$ad_hdl_dir/../corundum/fpga/lib/eth/lib/axis/rtl/sync_reset.v" \
  "$ad_hdl_dir/../corundum/fpga/lib/eth/lib/axis/rtl/axis_adapter.v" \
  "$ad_hdl_dir/../corundum/fpga/common/rtl/cmac_pad.v" \
  "$ad_hdl_dir/../corundum/fpga/common/rtl/mac_ts_insert.v" \
  "$ad_hdl_dir/../corundum/fpga/common/rtl/mqnic_port_map_mac_axis.v" \
  "[pwd]/mrmac_seg_pkt_gen_chk.v" \
  "[pwd]/mrmac_flat_pkt_gen_chk.v" \
  "[pwd]/mrmac_flat512_pkt_gen_chk.v" \
  "[pwd]/mrmac_shim_fifo.v" \
  "[pwd]/mrmac_shim_widthconv.v" \
  "[pwd]/mrmac_shim_ptp.v" \
] {
  if {[lsearch -exact [get_files -quiet -of_objects [get_filesets sources_1]] $_rtl] < 0} {
    add_files -norecurse -fileset sources_1 $_rtl
  }
}
update_compile_order -fileset sources_1

##########################################################################
# 1. The real MRMAC / GT / clocking cells.
##########################################################################
# mrmac_0 config: matched to the PASSING exdes. The four deltas from the sibling
# bench are marked *** EXDES *** below; see the header for the evidence behind each.
create_bd_cell -type ip -vlnv xilinx.com:ip:mrmac mrmac_0
set_property -dict [list \
  CONFIG.MRMAC_PRESET_C0 {1x100GE CAUI-4 Wide} \
  CONFIG.MRMAC_MODE_C0 {MAC+PCS} \
  CONFIG.MRMAC_DATA_PATH_INTERFACE_PORT0_C0 {Independent 384b Non-Segmented} \
  CONFIG.MAC_PORT0_RATE_C0 {100GE} \
  CONFIG.GT_TYPE_C0 {GTY} \
  CONFIG.GT_REF_CLK_FREQ_C0 {156.25} \
  CONFIG.MRMAC_IS_GT_WIZ_OLD {0} \
  CONFIG.INCLUDE_AUTO_NEG_LT_LOGIC_C0 {None} \
  CONFIG.MAC_PORT0_TX_FLOW_C0 {1} \
  CONFIG.MAC_PORT0_RX_FLOW_C0 {0} \
  CONFIG.MAC_PORT0_ENABLE_TIME_STAMPING_C0 {1} \
  CONFIG.PORT0_1588v2_Operation_MODE_C0 {2-step} \
  CONFIG.PORT0_1588v2_Clocking_C0 {Ordinary/Boundary Clock} \
  CONFIG.TIMESTAMP_CLK_PERIOD_NS {4.0} \
] [get_bd_cells mrmac_0]
#  ^ CONFIG.MRMAC_DATA_PATH_INTERFACE_PORT0_C0    *** EXDES *** (was Segmented)
#  ^ CONFIG.MAC_PORT0_RX_FLOW_C0 {0}              *** EXDES *** (was 1)
#
#  ^ CONFIG.MAC_PORT0_ENABLE_TIME_STAMPING_C0 {1} -- *** EXDES DELTA (2) REVERSED BY
#    INCREMENT 5 ***, together with PORT0_1588v2_Operation_MODE_C0 {2-step}. Both were
#    {0}/{No operation} for the baseline PASS and for increments 1-4, matching the
#    passing exdes. They have to go back on now: with timestamping off the generated
#    mrmac_0 has NO PTP pins at all (its only timestamp-adjacent ports are the ts
#    clocks), so the PTP cells this increment adds would have nothing to connect to.
#
#    Be clear about what this costs. Of the seven deltas the baseline PASS was built
#    on, this is the first one increment 5 gives up, and it is not cosmetic: it
#    changes the generated IP, not just a register write. Delta (4) below goes with it
#    (the ts clocks stop being GND). If this build regresses and the previous one
#    passed, THESE ARE THE FIRST LINES TO REVERT -- reverting them plus the ts-clock
#    connect and the section-5b PTP block returns the bench to the increment-4 shape.

# gtwiz_versal: VERBATIM from the sibling (which itself matches the reference's
# .xci electrically). SIM_SPEEDUP {false} is REQUIRED for rx_reset_done -- the
# reference ships false, and with true the RX datapath reset never sequences.
# Costs ~1 hour wall clock for the full power-up ramp: EXPECTED, not a hang.
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

# clk_wizard: PRIM_IN_FREQ pinned to the freerun rate so the MMCM re-solves its
# dividers for THIS clk_in1 and the outputs stay fixed. If left unset, the input
# frequency is PROPAGATED from the driving net and the requested outputs silently
# scale.
#
# clk_out2 (250 MHz) was kept enabled but UNUSED through increments 1-4 (the ts
# clocks were GND per the exdes) purely so the MMCM solution stayed identical to the
# sibling's -- one less variable between the two benches. Increment 5 finally consumes
# it: it is the MRMAC PTP timestamp clock. 250 MHz is not arbitrary -- MRMAC caps the
# ts clock at 50-350 MHz (PG314), so the 390.625 MHz AXIS clock is NOT a legal choice,
# and 250 MHz is what the reference and the sibling bench both use. It also matches
# CONFIG.TIMESTAMP_CLK_PERIOD_NS {4.0} above, which the IP uses to scale its internal
# counter -- the two must agree or every timestamp is wrong by that ratio.
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard clk_wizard
set_property -dict [list \
  CONFIG.PRIM_IN_FREQ [expr {$FREERUN_HZ / 1000000.0}] \
  CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {390.625,250.000,100.000,100.000,100.000,100.000,100.000} \
  CONFIG.CLKOUT_USED {true,true,false,false,false,false,false} \
  CONFIG.PRIM_SOURCE {Global_buffer} \
] [get_bd_cells clk_wizard]

# The glue, GTY-configured. Here it is the GT CLOCK/RESET PLANE ONLY: refclk
# IBUFDS_GTE5, the two bonded MBUFG_GT trees (TX0/RX0 masters -> core/usrclk/
# alt_serdes), the reset derivations (mrmac_{tx,rx}_{core,serdes}_reset from
# gt_rst_{tx,rx}_done), and the 80b<->128b serdes width adaptation. Its AXIS/PTP/
# pause pack/unpack path is NOT used by this bench (the generator drives mrmac_0's
# segment pins directly), so its shim_* inputs are GND-swept in section 6 and its
# mrmac_*_axis_* outputs are left dangling.
create_bd_cell -type module -reference mrmac_versal_glue mrmac_versal_glue
set_property -dict [list \
  CONFIG.GT_TYPE {GTY} \
  CONFIG.MRMAC_SERDES_W {80} \
  CONFIG.GT_CH_W {128} \
  CONFIG.RX_PER_LANE_CLK {1} \
] [get_bd_cells mrmac_versal_glue]

# MRMAC RX alignment-marker SIM speedup: a compile define consumed INSIDE the MRMAC
# IP RTL (mrmac_0_wrapper.v:389 RX / :632 TX select CTL_RX_VL_LENGTH_MINUS1 =
# 0x01FF vs 0x3FFF -> ~32x shorter align time). Verified to reach the OOC-generated
# MRMAC sources: compile.sh carries the define on the top-level xvlog line and
# system_tb_vlog.prj lists test_harness_mrmac_0_0_wrapper.v in that SAME compilation
# unit. Every consumer is a bare `ifdef so the VALUE is never compared.
adi_sim_add_define "SIM_SPEED_UP=1"

##########################################################################
# 2. Board clocks / resets. Both GT clocks are TB-generated boundary PORTS (not
#    clk_vips): clk_vip_if.set_clk_frq stores the period as an INTEGER ns, so
#    156.25 MHz = 6.4 ns truncates to 6 ns = 166.67 MHz and the GTY PLL mis-locks.
#    At the TB's 1ps timebase a plain always-toggle is exact.
##########################################################################
# --- GT reference clock, 156.25 MHz differential pair -> glue IBUFDS_GTE5 -> gtwiz.
create_bd_port -dir I gt_ref_clk_p
create_bd_port -dir I gt_ref_clk_n
ad_connect gt_ref_clk_p mrmac_versal_glue/gt_ref_clk_p
ad_connect gt_ref_clk_n mrmac_versal_glue/gt_ref_clk_n
connect_bd_net [get_bd_pins mrmac_versal_glue/gt_refclk_out] \
               [get_bd_pins gtwiz_versal/QUAD0_GTREFCLK0]

# --- Free-running clock (100 MHz, matching the reference -- see the cfg): GT
#     bring-up FSM + clk_wizard input + MRMAC s_axi + reset-gen sync clock.
#     Declared -type clk -freq_hz at creation so Vivado propagates the REAL
#     frequency to the sinks instead of defaulting to 100 MHz by inference (the
#     creation-time form is the validated idiom for a ROOT bd_port; CONFIG.FREQ_HZ
#     is read-only on hierarchy pins). Kept in lock-step with cfg FREERUN_HZ, which
#     is the single source of truth (system_tb.sv's half-period must match).
create_bd_port -dir I -type clk -freq_hz $FREERUN_HZ gt_freerun_clk
connect_bd_net [get_bd_ports gt_freerun_clk] \
               [get_bd_pins gtwiz_versal/gtwiz_freerun_clk] \
               [get_bd_pins clk_wizard/clk_in1]

# --- AXIS client clock (390.625 MHz) into the glue, and the PTP timestamp clock
#     (250 MHz). ts_clk_in was GND'd through increments 1-4 because timestamping was
#     off in the IP config and the glue's ts path was dead; increment 5 turns
#     timestamping on, so it is driven for real. The glue fans it to all four lanes
#     (assign mrmac_ts_clk = {4{ts_clk_in}}), and section 5b takes mrmac_ts_clk to
#     mrmac_0's tx_ts_clk / rx_ts_clk.
ad_connect mrmac_versal_glue/axis_clk_in clk_wizard/clk_out1
ad_connect mrmac_versal_glue/ts_clk_in   clk_wizard/clk_out2

# --- Board reset, active-low. In the sibling this came from proc_sys_reset off the
#     framework's sys_rst_vip -- which does not exist here (CUSTOM_HARNESS=1). It is
#     now a plain TB-driven boundary port, which also makes the exdes DOUBLE RESET
#     directly expressible: the test program drives pl_resetn low/high exactly as
#     exdes_tb.v:419-425 does (pl_resetn=0 -> 400 clks -> pl_resetn=1).
#
#     Fan-out matches the exdes: pl_resetn drives the glue (which derives
#     gt_rst_all / shim_axi_reset / mrmac_flexif_reset from it), the gtwiz register
#     interface reset, and mrmac_0/s_axi_aresetn (exdes.sv:1173,1322 both take
#     s_axi_aresetn from the same board reset).
create_bd_port -dir I -type rst pl_resetn
set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports pl_resetn]
ad_connect pl_resetn mrmac_versal_glue/pl_resetn
ad_connect pl_resetn gtwiz_versal/QUAD0_s_axi_lite_resetn

##########################################################################
# 3. glue <-> gtwiz_versal  (VERBATIM from the sibling / the validated island).
##########################################################################
# TX: one shared master outclk. RX: all four lane outclks, one per glue RX MBUFG
# (each lane's CDR recovers its own RX clock -- PG314 fig X21095-062118 and
# exdes.sv:650-654). Requires QUAD0_RX{1,2,3}_OUTCLK_EN {true} above.
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
#     Kept as-is rather than switched to the exdes's TB-driven gt_reset_all_in: this
#     is the ONLY idiom PROVEN to reach rx_reset_done in an ADI framework TB
#     (testbenches/project/mxfe drives INTF0_rst_all_in directly from ~gt_powergood
#     with no sequencer and locks RX by ~59 us with SIM_SPEEDUP=false). It
#     self-sequences: rst_all stays asserted exactly as long as the power-up ramp
#     needs, and releases the instant powergood rises. A fixed-width TB pulse fails
#     the other way -- it releases rst_all before the full ramp finishes, so
#     gtpowergood stalls at 0. The exdes's DOUBLE RESET is still applied, via
#     pl_resetn (-> glue gt_rst_all) from the test program.
ad_ip_instance util_vector_logic rst_all_inv [list \
  C_SIZE {1} \
  C_OPERATION {not} \
]
ad_connect gtwiz_versal/gtpowergood rst_all_inv/Op1
ad_connect rst_all_inv/Res          gtwiz_versal/INTF0_rst_all_in

##########################################################################
# 3b. FLAT serdes-data connect (MRMAC <-> gtwiz) THROUGH the glue (VERBATIM).
##########################################################################
# GTY MRMAC serdes pins are tx_serdes_data${n}/rx_serdes_data${n} [79:0]; gtwiz
# channel data is 128b. The glue zero-extends 80->128 on TX (driving ALL gtwiz input
# bits, which is exactly why this cannot be a partial connect_bd_net) and takes the
# low 80 on RX.
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
# 4. glue <-> mrmac_0 clocks / resets.
##########################################################################
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_core_clk]      [get_bd_pins mrmac_0/tx_core_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_core_clk]      [get_bd_pins mrmac_0/rx_core_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_serdes_clk]    [get_bd_pins mrmac_0/rx_serdes_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_alt_serdes_clk] [get_bd_pins mrmac_0/tx_alt_serdes_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_alt_serdes_clk] [get_bd_pins mrmac_0/rx_alt_serdes_clk]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_axi_clk] \
               [get_bd_pins mrmac_0/tx_axi_clk] \
               [get_bd_pins mrmac_0/rx_axi_clk]

# *** EXDES *** tx_flexif_clk / rx_flexif_clk are DELIBERATELY NOT CONNECTED here.
# The passing reference drives them to zero (exdes.sv:616-617). Leaving them undriven
# lets the section-7 GND sweep tie them -- which yields exactly the 4'b0000 the exdes
# uses.
#
# tx_ts_clk / rx_ts_clk USED to be in that same list (exdes.sv:656-657 ties them to
# zero too) and are NOT any more: increment 5 turns timestamping on, so they are driven
# from the glue's mrmac_ts_clk in section 5b, ahead of the sweep. That is one of the two
# *** EXDES *** deltas increment 5 gives up; see the config-dict note in section 1.
#
# This ONLY works because section 7's exclusion dict is narrow (s_axi only). Each of
# these pins is the sole member of its own bus interface (tx_flexif_clk ->
# 'tx_flexif_clk_port' etc. in mrmac_0.xml), so a dict built from ALL of mrmac_0's
# interfaces would shadow them and leave them floating. See the note in section 7.
#
# RISK, stated plainly: in the sibling, mrmac_flexif_clk was driven from axis_clk
# SPECIFICALLY to dodge [BD 41-758] ("no clock source for clock pin"). If that fires
# as an ERROR (not a warning) during validate_bd_design, this is the delta to
# revert -- but the exdes is the authority on what the IP itself tolerates, and
# matching it is the entire point of this bench.

connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_core_reset]   [get_bd_pins mrmac_0/tx_core_reset]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_core_reset]   [get_bd_pins mrmac_0/rx_core_reset]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_serdes_reset] [get_bd_pins mrmac_0/tx_serdes_reset]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_rx_serdes_reset] [get_bd_pins mrmac_0/rx_serdes_reset]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_flexif_reset]    [get_bd_pins mrmac_0/rx_flexif_reset]

##########################################################################
# 5. Datapath, 512-bit client end to 512-bit client end:
#
#      pkt_gen512 -> port_map -> tx_pad -> tx_512_neck -> tx_neck_384 -> tx_fifo
#          -> tx_adapt -> glue (pack) -> mrmac_0 -> [GT serial loopback] -> mrmac_0
#          -> glue (unpack) -> rx_adapt -> ts_insert -> rx_fifo
#          -> rx_384_neck -> rx_neck_512 -> port_map -> pkt_chk512
#
#    *** INCREMENTS 1, 2, 3, 4, 5 and 6 of the Corundum re-introduction. ***
#
#    INCREMENT 6 puts the Corundum port map at BOTH 512-bit ends, in the position
#    fpga_core occupies in the real design: the fixtures now talk to the map's datapath
#    side and the shim to its MAC side. It is instantiated directly from the library (no
#    wrapper) and configured PTP_TS_WIDTH=80 so every tuser crosses whole -- see the cell
#    itself for why that parameter is what makes this a pure rewire, and why it differs
#    from ethernet_vck190.v. Its clocks/resets and its ~20 loose pins are section 5c.
#
#    NO mac_rstgen, AND THAT IS DELIBERATE. The ladder's rung 6 was written as "port map
#    + mac_rstgen", copying the sibling mrmac_realip_loopback_gty (system_bd.tcl:286-292),
#    where an ad_ip_instance proc_sys_reset converts the framework's sys_rst_vip/rst_out
#    into the active-low peripheral_aresetn the glue wants on pl_resetn. This bench has
#    NO sys_rst_vip (CUSTOM_HARNESS=1) -- pl_resetn is already a TB-driven active-low
#    boundary port (section 2). Inserting a proc_sys_reset would not just be redundant,
#    it would be HARMFUL: proc_sys_reset stretches and re-synchronizes its output, which
#    is exactly what would blur the exdes DOUBLE RESET the test program drives through
#    pl_resetn -- the sequence that was the root-cause fix for Core_Version=0
#    ([[mrmac-double-reset-requirement]]). The port map needs no reset of its own; the two
#    *_rst inputs it does have are forwarding-only and are driven in 5c.
#
#    WITH THIS BUILD THE ENTIRE mrmac_gty_wrapper DATAPATH IS PRESENT. Every module
#    the shim instantiates between fpga_core and mrmac_0 is now in the bench, at the
#    shim's own widths and parameters. What is still absent is everything ABOVE the
#    wrapper (fpga_core, mqnic, PCIe) and everything AROUND it (the VIP register path,
#    the framework scoreboard) -- those are later rungs of the ladder.
#
#    INCREMENTS 3 and 4 add the 512-bit client boundary: cmac_pad plus the four
#    axis_adapter instances that convert 512 <-> 1536 <-> 384. They land together
#    because they cannot be separated -- cmac_pad.v asserts DATA_WIDTH == 512 and
#    $finish'es otherwise, so it can only sit at a 512-bit interface, and reaching 512
#    bits from MRMAC's 384-bit client bus IS the adapter chain. See
#    mrmac_shim_widthconv.v for the wrapper rationale and mrmac_flat512_pkt_gen_chk.v
#    for why a new 512-bit generator/checker pair was needed (the 384-bit pair is
#    segment-native and cannot be re-sliced upward).
#
#    Two things worth knowing about what these two increments do and do not prove:
#
#      * cmac_pad is a FUNCTIONAL NO-OP at PKT_BYTES=256. It only acts on frames
#        shorter than Ethernet's 60-byte minimum, and 256 bytes is 4 full 512-bit
#        beats. So this increment proves it is TRANSPARENT to a well-formed stream --
#        worth proving, since it sits in the path of every frame -- but exercising the
#        padding itself needs PKT_BYTES < 60, a separate experiment.
#
#      * the partial-beat paths ARE exercised, just downstream: 256 bytes is 5 whole
#        384-bit beats plus a 16-byte remainder, so tx_neck_384, the frame FIFO, the
#        adapters and MRMAC all see a short final beat on every frame.
#
#    Increment 3 also changes the RX FIFO from a pass-through into the thing it exists
#    to be. Through increments 1-4 its m_axis_tready was tied 1 (the checker consumed
#    every beat), so it could never fill. rx_384_neck back-pressures, so from here on the
#    FIFO is genuinely absorbing a valid-only MRMAC RX stream against a stalling sink,
#    and its DROP_WHEN_FULL path is reachable for the first time. Increment 2 put it in
#    ahead of this converter deliberately, so the converter arrives with its shock
#    absorber already proven not to disturb the byte-exact stream.
#
#    INCREMENT 5 adds the PTP set: mrmac_ptp_ts_cvt x4, mrmac_ptp_sync x2, and
#    mac_ts_insert x1, plus the glue's PTP pass-through and mrmac_0's PTP pins. It is
#    the increment with a REAL COST attached, and section 1 states it at the config
#    dict: enabling MRMAC timestamping REVERSES two of the seven *** EXDES *** deltas
#    the baseline PASS was built on. It also widens tuser from 1 bit to the shim's own
#    17 (TX, {tag,err}) and 81 (RX, {ptp_ts,err}) -- see mrmac_shim_fifo.v.
#
#    Where Corundum's PTP time comes from here: nowhere real. The shim takes
#    tx_ptp_time / rx_ptp_time from Corundum's ptp_clock inside fpga_core, which this
#    bench does not have, so a local free-running counter (ptp_timegen) stands in. That
#    substitution exercises every STRUCTURAL element -- the 80<->55 format conversion,
#    mrmac_ptp_sync's PG314 st_sync handshake, the AXIS->ts_clk crossing, MRMAC
#    accepting the load and returning both RX and TX timestamps, mac_ts_insert
#    threading a stamp through 81-bit tuser -- but it cannot test time ACCURACY, since
#    a local timebase has nothing to be accurate against. The verdict stays
#    byte-exactness; the timestamps ride along uncompared. mrmac_shim_ptp.v's header
#    argues this at length.
#
#    INCREMENT 2 adds the shim's two axis_fifo instances and its three sync_reset
#    instances -- the pieces this section's cell list and wiring grew for. Both are
#    real, unmodified Corundum library RTL:
#
#      * tx_fifo: FRAME_FIFO store-and-forward, DEPTH 16384, no dropping. Its effect
#        on the traffic is real, not cosmetic: m_axis_tvalid cannot drop mid-frame, so
#        MRMAC sees whole committed frames regardless of how the source stalls. It can
#        also swallow the generator's IFG_BEATS gap -- MEASURED standalone as gap=4
#        beats when the sink is always ready, gap=0 for frames that queued during a
#        stall. Self-limiting, though: the FIFO can only accumulate while MRMAC is
#        de-asserting tx_axis_tready_0, and a MAC pacing the stream is a MAC managing
#        its own IPG. See mrmac_shim_fifo.v's header for the full argument.
#
#      * rx_fifo: FRAME_FIFO with DROP_OVERSIZE_FRAME + DROP_WHEN_FULL, DEPTH 4096.
#        At increment 2 it could not actually fill (nothing downstream back-pressured),
#        so it was an elastic pass-through; increment 3's rx_384_neck changes that. Its
#        status_overflow is $display'd inside the wrapper because a drop costs a WHOLE
#        FRAME silently, which would otherwise look identical to frames never arriving.
#
#      * three sync_reset (N=4): tx_rst / rx_rst / rx_ptp_rst, exactly as
#        mrmac_gty_wrapper.v:216-235. The FIFOs take their reset from the
#        synchronizers instead of directly from the glue's ~pl_resetn, which is the
#        point of adding them. Increments 3/4/5 add many more sinks to tx_rst and
#        rx_rst: the width converters, the pad, ts_insert and both ptp_sync cells.
#        rx_ptp_rst stays a boundary port with no internal consumer, and that is
#        FAITHFUL, not a gap -- in the shim it is an OUTPUT of the wrapper
#        (mrmac_gty_wrapper.v:108), destined for Corundum's ptp_clock inside fpga_core,
#        which this bench does not have. The wrapper resets both ptp_sync instances
#        from tx_rst / rx_rst, and so does this bench.
#        pkt_gen/pkt_chk deliberately keep the RAW reset -- they are test fixtures with
#        no counterpart in the shim, and leaving them alone keeps their behaviour
#        identical to the passing run.
#
#    The baseline this bench passed with wired pkt_gen/pkt_chk DIRECTLY to mrmac_0's
#    six segment pins, with the glue's AXIS pack/unpack path unused. Increment 1 put
#    the first two shim modules back in: mrmac_tx_adapt and mrmac_rx_adapt.
#
#    That necessarily brings the glue's AXIS path back with them, and it is not a
#    free choice -- it is forced. The adapters speak a PACKED bus on their MRMAC side
#    (384b tdata, 66b tkeep_user) while mrmac_0 exposes six separate 64b/11b pins,
#    and a BD net can neither slice nor concatenate a vector. mrmac_versal_glue's
#    pack/unpack (glue:710-746) is the only thing that bridges the two, which is the
#    very reason that module exists. So increment 1 is really "adapters + the glue
#    AXIS path" -- the smallest addition that is wireable at all.
#
#    On the client side the adapters speak flat plain AXIS (tkeep[47:0] + tuser),
#    which the segmented generator/checker deliberately do NOT (they expose six
#    ports to mirror mrmac_0). Hence mrmac_flat_pkt_gen / mrmac_flat_pkt_chk: thin
#    re-slicing wrappers that instantiate the BYTE-IDENTICAL baseline generator and
#    checker. No FSM or comparison logic is duplicated or changed, so the stimulus
#    reaching the MRMAC pins is bit-exact with the passing run and a failure here is
#    attributable to the adapters or the glue's pack/unpack -- which is the point of
#    adding one piece at a time. The wrappers keep the baseline's clk/rst/enable and
#    four status port names, so the TB boundary ports and test program are unchanged.
#
#    Verified before wiring (iverilog, gen -> tx_adapt -> the glue's exact segment
#    split/rejoin assigns -> rx_adapt -> chk, with tready de-asserted periodically to
#    exercise back-pressure): sent=16 matched=16 mismatched=0. Increment 2's chain was
#    re-verified the same way with both FIFOs spliced in. So the datapath round-trips
#    every byte on its own; this build tests it through the real MAC.
##########################################################################
# The traffic fixtures, now at the 512-bit fpga_core client width (increments 3/4).
# mrmac_flat_pkt_gen / _chk (the 384-bit pair used by increments 1 and 2) are no longer
# instantiated: cmac_pad forces a 512-bit client boundary, so the fixtures move there
# with it. Their FILES stay registered in section 0 and unmodified on disk, so reverting
# to the increment-2 shape is a matter of swapping these two -reference names back.
#
# The BYTE STREAM is unchanged. mrmac_flat512_pkt_gen's frame_byte function is
# character-for-character the one in mrmac_seg_pkt_gen_chk.v, so the frames entering the
# datapath are bit-identical to the passing baseline run; only the beat granularity
# differs (64 bytes/beat instead of 48), which is exactly what the new adapter chain
# exists to reconcile.
create_bd_cell -type module -reference mrmac_flat512_pkt_gen pkt_gen
set_property -dict [list \
  CONFIG.NUM_PKTS  $NUM_PKTS \
  CONFIG.PKT_BYTES $PKT_BYTES \
  CONFIG.IFG_BEATS $IFG_BEATS \
] [get_bd_cells pkt_gen]

create_bd_cell -type module -reference mrmac_flat512_pkt_chk pkt_chk
set_property -dict [list \
  CONFIG.NUM_PKTS  $NUM_PKTS \
  CONFIG.PKT_BYTES $PKT_BYTES \
  CONFIG.STRIP_FCS $STRIP_FCS \
] [get_bd_cells pkt_chk]

# The two shim adapters. Both are pure combinational relabelers (no clock, no
# reset, no state), so they need no clock connection -- MODE is their only config.
# Leave SEG_COUNT and the derived widths alone: MODE is the single source of truth
# for the geometry (both modules' headers say so explicitly).
create_bd_cell -type module -reference mrmac_tx_adapt tx_adapt
set_property CONFIG.MODE {1x100G} [get_bd_cells tx_adapt]

create_bd_cell -type module -reference mrmac_rx_adapt rx_adapt
set_property CONFIG.MODE {1x100G} [get_bd_cells rx_adapt]

# INCREMENT 2: the two Corundum store-and-forward FIFOs, as thin wrappers around the
# real axis_fifo (see mrmac_shim_fifo.v for why they are wrapped rather than
# module-ref'd directly, and for the one deliberate parameter deviation: USER_WIDTH=1
# instead of the shim's PTP-carrying 17/81, since timestamping is off in this bench).
#
# DEPTH values are the shim's own localparams -- TX_FIFO_DEPTH 16384,
# RX_FIFO_DEPTH 4096 (mrmac_gty_wrapper.v).
create_bd_cell -type module -reference mrmac_shim_tx_fifo tx_fifo
set_property CONFIG.DEPTH 16384 [get_bd_cells tx_fifo]

create_bd_cell -type module -reference mrmac_shim_rx_fifo rx_fifo
set_property CONFIG.DEPTH 4096 [get_bd_cells rx_fifo]

# INCREMENT 2: the shim's three reset synchronizers, instantiated as the REAL
# sync_reset (async-set / sync-release, N=4) exactly as mrmac_gty_wrapper.v:216-235
# does. All three take the same raw reset and differ only in clock domain and
# consumer:
#   tx_rst_sync  -> tx_rst      (TX datapath: tx_fifo)
#   rx_rst_sync  -> rx_rst      (RX datapath: rx_fifo)
#   rx_ptp_rst_sync -> rx_ptp_rst (PTP domain; instantiated for fidelity with the
#                      shim, but this bench has no PTP logic so its output is only
#                      observed at a boundary port -- see below)
#
# In this bench TX and RX are ONE clock domain (the single 390.625 MHz clk_wizard
# output that the glue fans to both mrmac_0/tx_axi_clk and rx_axi_clk), so all three
# get the same clock. Keeping three separate cells rather than collapsing them is
# deliberate: it is the shim's actual structure, and the next increments (the width
# adapters, then PTP) attach to these specific resets.
foreach _sr {tx_rst_sync rx_rst_sync rx_ptp_rst_sync} {
  create_bd_cell -type module -reference sync_reset $_sr
  set_property CONFIG.N 4 [get_bd_cells $_sr]
}

# INCREMENTS 3 and 4: the 512-bit runt padder and the four width converters, as thin
# wrappers around the real cmac_pad / axis_adapter (see mrmac_shim_widthconv.v for why
# they are wrapped and why there are four separate modules rather than one
# parameterized one -- the short answer is that a module-ref cell would surface the
# widths as CONFIG.* and let the BD elaborator infer them, and these widths must be
# fixed numerals at the BD boundary).
#
# No CONFIG.* on any of them: every parameter is baked into the wrapper. That is the
# point.
create_bd_cell -type module -reference mrmac_shim_tx_pad      tx_pad
create_bd_cell -type module -reference mrmac_shim_axis_512_1536 tx_512_neck
create_bd_cell -type module -reference mrmac_shim_axis_1536_384 tx_neck_384
create_bd_cell -type module -reference mrmac_shim_axis_384_1536 rx_384_neck
create_bd_cell -type module -reference mrmac_shim_axis_1536_512 rx_neck_512

# INCREMENT 5: the PTP set.
#
# ptp_timegen is the ONE cell here with no counterpart in mrmac_gty_wrapper -- it stands
# in for Corundum's ptp_clock (inside fpga_core), which this bench does not have. Its
# INC_FNS default (167772) is 2.56 ns per clock in Corundum's 2^-16 ns units, i.e. the
# 390.625 MHz AXIS period, so the counter advances at roughly real time. Roughly is
# enough: nothing here measures the rate (see the section header).
create_bd_cell -type module -reference mrmac_shim_ptp_timegen ptp_timegen

# *** INCREMENT 6 ***: the Corundum port map, instantiated DIRECTLY from the library.
#
# NO WRAPPER, ON PURPOSE. mqnic_port_map_mac_axis passes the same test sync_reset and
# mrmac_ptp_ts_cvt passed: no body-derived widths, no clock pin, no state. Its entire
# body is a `generate for` of continuous assigns behind an IND lookup table -- a pure
# permutation network. Everything the BD needs to know is a parameter, and every port
# width is a plain expression over those parameters, so the elaborator has nothing to
# get wrong. (Contrast axis_fifo, whose ADDR_WIDTH is derived inside the body -- that
# is what forces mrmac_shim_fifo.v to exist.)
#
# *** THE PARAMETER THAT MAKES THIS A PURE REWIRE: PTP_TS_WIDTH = 80. ***
# The module derives AXIS_TX_USER_WIDTH = PTP_TAG_WIDTH+1 and AXIS_RX_USER_WIDTH =
# PTP_TS_WIDTH+1. At PTP_TS_WIDTH=80 those come out 17 and 81 -- EXACTLY the widths this
# bench's TX and RX tuser already carry (mrmac_gty_wrapper.v's TX_USER_WIDTH = 16+1 and
# RX_USER_WIDTH = PTP_TS_WIDTH+1, with MRMAC's stamp in Corundum's 80-bit format). So
# every net below is width-matched with no slicing anywhere, which matters here because
# a BD net can neither slice nor concatenate.
#
# This DIVERGES from ethernet_vck190.v deliberately. That file sets PTP_TS_WIDTH to 96
# or 48 (Corundum's PTP_TS_FMT_TOD choice) and therefore needs its `recon` generate
# block (ethernet_vck190.v:444-454) to bridge 80 <-> PTP_TS_WIDTH and 81 <->
# AXIS_RX_USER_WIDTH. That reconciliation exists because the CORE fixes the format.
# There is no core in this bench yet, so the map is set to the MAC's native width and
# the recon logic is simply not needed. When mqnic_core_axi lands (the next rung) the
# core will impose its format and that bridging comes back -- expected, not a regression.
#
# MASK / INDEX, and why the module's own assertions are the safety net here:
# MAC_COUNT = PORT_COUNT = 1 and PORT_MASK = 0 (auto), so calcMask sets bit 0 and
# calcIndices yields IND = 8'h00 -- the single MAC maps to the single port and the
# generate's zero-stuffing `else` branch is not taken. The module has two `initial`
# blocks that $error+$finish, on PORT_COUNT > MAC_COUNT and on &IND (an invalid mask).
# Both are satisfied, and both are LOUD if a later change breaks it, which is most of
# why this rung is cheap: a mis-parameterization cannot pass silently.
#
# Verified before this BD edit: standalone/tb_port_map.v splices this cell into BOTH
# ends of the increment-3/4/5 chain under iverilog and reports
#   RESULT sent=4096 matched=4096 mismatched=0 rx_bytes=1048576
#   PTP    tx_st_sync_edges=1281 rx_st_sync_edges=1281 stamped_frames=4096
#   PORT MAP PASS
# byte-identical and cycle-identical to tb_full_chain.v without it -- i.e. the map is
# transparent, which for a permutation network is the whole claim.
create_bd_cell -type module -reference mqnic_port_map_mac_axis port_map
set_property -dict [list \
  CONFIG.MAC_COUNT          {1} \
  CONFIG.PORT_MASK          {0} \
  CONFIG.PORT_GROUP_SIZE    {1} \
  CONFIG.IF_COUNT           {1} \
  CONFIG.PORTS_PER_IF       {1} \
  CONFIG.PORT_COUNT         {1} \
  CONFIG.PTP_TS_WIDTH       {80} \
  CONFIG.PTP_TAG_WIDTH      {16} \
  CONFIG.AXIS_DATA_WIDTH    {512} \
  CONFIG.AXIS_KEEP_WIDTH    {64} \
  CONFIG.AXIS_TX_USER_WIDTH {17} \
  CONFIG.AXIS_RX_USER_WIDTH {81} \
] [get_bd_cells port_map]

# The four format converters, instantiated DIRECTLY as the real mrmac_ptp_ts_cvt -- no
# wrapper. It passes the same test sync_reset did: four ports, no clock, no reset, and
# no body localparam that affects a port width (FRAC_SHIFT affects only an internal
# wire). Every default is already what the wrapper uses (COR_TS_WIDTH 80,
# COR_FNS_WIDTH 16, MRMAC_TS_WIDTH 55, MRMAC_FNS_WIDTH 8), so no CONFIG.* either.
#
# Each is a BIDIRECTIONAL pair of shifts, and each instance uses exactly ONE direction;
# the unused input is GND'd and the unused output left open, matching the wrapper:
#   tx_ts_cvt   mrmac_ts_in  -> cor_ts_out : the TX completion timestamp MRMAC returns
#   rx_ts_cvt   mrmac_ts_in  -> cor_ts_out : the RX capture timestamp, into mac_ts_insert
#   tx_time_cvt cor_ts_in    -> mrmac_ts_out : Corundum time down to MRMAC units, TX
#   rx_time_cvt cor_ts_in    -> mrmac_ts_out : ditto, RX
foreach _cvt {tx_ts_cvt rx_ts_cvt tx_time_cvt rx_time_cvt} {
  create_bd_cell -type module -reference mrmac_ptp_ts_cvt $_cvt
}

# The two system-timer discipline FSMs, wrapped (expression-valued port widths + a
# $clog2 body localparam). SYNC_CYCLES stays a CONFIG.* because it is an integer that
# affects no port width -- the same reason sync_reset's N could be.
#
# 32 is the wrapper's PTP_SYNC_CYCLES. PG314 requires >= 10 ts_clk cycles between
# st_sync edges and mrmac_ptp_sync counts in AXIS clocks, so the margin is the clock
# ratio: 32 AXIS clocks at 390.625 MHz = 81.9 ns = ~20 ts_clk cycles at 250 MHz, twice
# what the IP asks for. mrmac_ptp_sync.v itself $error's below 10.
foreach _ps {tx_ptp_sync rx_ptp_sync} {
  create_bd_cell -type module -reference mrmac_shim_ptp_sync $_ps
  set_property CONFIG.SYNC_CYCLES 32 [get_bd_cells $_ps]
}

# RX timestamp insertion into tuser, at 384 bits -- the MRMAC side of the frame FIFO,
# not the 512-bit client side. That placement is the shim's and is deliberate: the
# stamp rides with the frame through the FIFO and the width conversion, so a frame the
# FIFO drops takes its stamp with it rather than the two desynchronizing. This is also
# the cell that creates the RX chain's 81-bit tuser (1 bit in, 81 out), and therefore
# what forces rx_fifo / rx_384_neck / rx_neck_512 to USER_WIDTH=81.
create_bd_cell -type module -reference mrmac_shim_ts_insert ts_insert

# EVERY clocked cell in this section runs on clk_out1 -- the MRMAC AXIS client domain
# (the same 390.625 MHz output the glue broadcasts to mrmac_0/tx_axi_clk|rx_axi_clk).
# So there is no CDC anywhere in the datapath: one clock from the generator to the MAC
# and back, which is the shim's own arrangement (its tx_axi_clk and rx_axi_clk are the
# same net in the wrapper's 1x100G branch).
#
# The two PTP sync FSMs are on this clock too, exactly as in the wrapper -- they are
# AXIS-domain logic whose OUTPUT crosses into MRMAC's ts_clk domain by held-stable
# handshake, not by being clocked there. The ts_clk (250 MHz, clk_out2) reaches only
# mrmac_0's tx_ts_clk/rx_ts_clk, via the glue. See mrmac_shim_ptp.v's header.
#
# One connect_bd_net, every sink listed. Cells with no clk pin are absent by nature:
# the four mrmac_ptp_ts_cvt are combinational.
connect_bd_net [get_bd_pins clk_wizard/clk_out1] \
               [get_bd_pins pkt_gen/clk] \
               [get_bd_pins pkt_chk/clk] \
               [get_bd_pins tx_pad/clk] \
               [get_bd_pins tx_512_neck/clk] \
               [get_bd_pins tx_neck_384/clk] \
               [get_bd_pins tx_fifo/clk] \
               [get_bd_pins rx_fifo/clk] \
               [get_bd_pins rx_384_neck/clk] \
               [get_bd_pins rx_neck_512/clk] \
               [get_bd_pins ts_insert/clk] \
               [get_bd_pins ptp_timegen/clk] \
               [get_bd_pins tx_ptp_sync/clk] \
               [get_bd_pins rx_ptp_sync/clk] \
               [get_bd_pins tx_rst_sync/clk] \
               [get_bd_pins rx_rst_sync/clk] \
               [get_bd_pins rx_ptp_rst_sync/clk]

# The RAW reset: the glue's shim_axi_reset (= ~pl_resetn), active-HIGH. This is the
# signal the shim feeds to sync_reset as tx_reset_in / rx_reset_in -- the glue drives
# the shim's mrmac_{tx,rx}_reset_in from exactly this pin (mrmac_versal_glue.v:268).
#
# ONE connect_bd_net with every sink listed, not several calls off the same source pin:
# the first call creates the net and later ones would have to be resolved onto it by
# name, which is the class of thing that goes wrong quietly in this BD. The three
# synchronizers plus pkt_gen/pkt_chk are all the raw-reset sinks there are.
#
# pkt_gen / pkt_chk stay on the RAW reset, unchanged from increment 1 and the frozen
# baseline. Not an oversight: they are this bench's test fixtures, not shim logic, and
# leaving them alone keeps their behaviour bit-identical to the passing run. The shim
# has no counterpart to them, so there is nothing to be faithful to.
#
# ptp_timegen joins them for the same reason: it is the other pure fixture here,
# standing in for Corundum's ptp_clock (which in the real design lives in fpga_core and
# is reset by fpga_core's own reset, not by anything the shim owns). Releasing it early
# is harmless and mildly desirable -- the timebase is already counting by the time the
# discipline FSMs come out of reset and start loading MRMAC.
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_axi_reset] \
               [get_bd_pins tx_rst_sync/rst] \
               [get_bd_pins rx_rst_sync/rst] \
               [get_bd_pins rx_ptp_rst_sync/rst] \
               [get_bd_pins pkt_gen/rst] \
               [get_bd_pins pkt_chk/rst] \
               [get_bd_pins ptp_timegen/rst]

# The SYNCHRONIZED resets -- every piece of SHIM logic, TX side and RX side, exactly as
# the wrapper resets them (tx_rst / rx_rst, its two sync_reset outputs).
#
# The split follows the wrapper's, module for module: the pad, the two TX width
# converters, the TX FIFO and the TX PTP sync are on tx_rst; the two RX width
# converters, the RX FIFO, mac_ts_insert and the RX PTP sync are on rx_rst. This bench
# happens to drive both synchronizers from the same raw reset and the same clock, so
# the two releases coincide -- but keeping the two trees distinct is what makes the
# section reviewable against mrmac_gty_wrapper.v rather than merely correct.
connect_bd_net [get_bd_pins tx_rst_sync/out] \
               [get_bd_pins tx_pad/rst] \
               [get_bd_pins tx_512_neck/rst] \
               [get_bd_pins tx_neck_384/rst] \
               [get_bd_pins tx_fifo/rst] \
               [get_bd_pins tx_ptp_sync/rst]

connect_bd_net [get_bd_pins rx_rst_sync/out] \
               [get_bd_pins rx_fifo/rst] \
               [get_bd_pins rx_384_neck/rst] \
               [get_bd_pins rx_neck_512/rst] \
               [get_bd_pins ts_insert/rst] \
               [get_bd_pins rx_ptp_sync/rst]

# rx_ptp_rst_sync's output stays a boundary port with no internal consumer, and with
# increment 5 in place that is now demonstrably FAITHFUL rather than a placeholder: in
# the shim, rx_ptp_rst is an OUTPUT of the wrapper (mrmac_gty_wrapper.v:108) destined
# for Corundum's ptp_clock in fpga_core -- which this bench does not have. The wrapper
# resets its own two mrmac_ptp_sync instances from tx_rst / rx_rst, and so does the
# reset fan-out above. So this third synchronizer has no local load by design, exactly
# as in the real thing.
#
# Exported rather than left dangling so the log shows it elaborated. system_tb.sv is
# deliberately NOT changed for this: omitting an OUTPUT from a named port map is legal,
# so the file stays byte-identical to the frozen baseline.
create_bd_port -dir O rx_ptp_rst
ad_connect rx_ptp_rst rx_ptp_rst_sync/out

# ---- TX: pkt_gen(512) -> tx_pad -> 512/64 -> 64/384 -> tx_fifo -> tx_adapt ---------
#             -> glue (packed) -> mrmac_0 (per segment)
#
# This is now the wrapper's whole TX chain, in the wrapper's order, at the wrapper's
# widths. Every hop below is a straight 1:1 net set -- the widths match on both sides
# of every one of them, because that is what the four separate width-specific adapter
# wrappers buy (mrmac_shim_widthconv.v). tready runs backwards along the same chain
# from mrmac_0 all the way to pkt_gen, unbroken.
#
# Stage 1 (INCREMENT 4): generator -> the 512-bit runt padder. Functionally a no-op at
# PKT_BYTES=256 (every beat is a full 64 bytes, and cmac_pad only acts below 60); what
# this proves is that it is TRANSPARENT, which is the thing that has to be true before
# anyone ever runs short frames through it.
# *** INCREMENT 6 *** inserts port_map between pkt_gen and tx_pad. pkt_gen now drives
# the map's DATAPATH side (where fpga_core sits in the real design) and the map's MAC
# side drives tx_pad (where the shim sits). Both sides are 512-bit with tuser 17, so
# this is a pure rewire -- the same three-connect shape as before, just via the map.
connect_bd_net [get_bd_pins pkt_gen/m_axis_tdata]  [get_bd_pins port_map/s_axis_tx_tdata]
connect_bd_net [get_bd_pins pkt_gen/m_axis_tkeep]  [get_bd_pins port_map/s_axis_tx_tkeep]
connect_bd_net [get_bd_pins pkt_gen/m_axis_tvalid] [get_bd_pins port_map/s_axis_tx_tvalid]
connect_bd_net [get_bd_pins pkt_gen/m_axis_tlast]  [get_bd_pins port_map/s_axis_tx_tlast]
connect_bd_net [get_bd_pins pkt_gen/m_axis_tuser]  [get_bd_pins port_map/s_axis_tx_tuser]
connect_bd_net [get_bd_pins port_map/s_axis_tx_tready] [get_bd_pins pkt_gen/m_axis_tready]

connect_bd_net [get_bd_pins port_map/m_axis_mac_tx_tdata]  [get_bd_pins tx_pad/s_axis_tdata]
connect_bd_net [get_bd_pins port_map/m_axis_mac_tx_tkeep]  [get_bd_pins tx_pad/s_axis_tkeep]
connect_bd_net [get_bd_pins port_map/m_axis_mac_tx_tvalid] [get_bd_pins tx_pad/s_axis_tvalid]
connect_bd_net [get_bd_pins port_map/m_axis_mac_tx_tlast]  [get_bd_pins tx_pad/s_axis_tlast]
connect_bd_net [get_bd_pins port_map/m_axis_mac_tx_tuser]  [get_bd_pins tx_pad/s_axis_tuser]
connect_bd_net [get_bd_pins tx_pad/s_axis_tready]  [get_bd_pins port_map/m_axis_mac_tx_tready]

# Stage 2 (INCREMENT 3): 512 -> 1536, the up-leg of the width conversion. 512 and 384
# have no integral ratio, so the wrapper goes through a 1536-bit neck; this is the first
# half of that, and it is reproduced rather than collapsed because the shim as it ships
# is what is under test.
#
# The neck width is NECK in mrmac_gty_wrapper.v and must be a common multiple of 512 and
# 384 (lcm = 1536, gcd = 128). It is not a free number: axis_adapter derives SEG_COUNT
# with a truncating integer divide and asserts nothing about the S/M ratio, so a
# non-multiple neck elaborates clean and passes a byte-exact test while silently wasting
# a fraction of the bus. 1536 is the only value that clears 100G line rate; the earlier
# 64 capped this datapath at 25 Gb/s. Measured table at mrmac_gty_wrapper.v g_tx_100g.
connect_bd_net [get_bd_pins tx_pad/m_axis_tdata]     [get_bd_pins tx_512_neck/s_axis_tdata]
connect_bd_net [get_bd_pins tx_pad/m_axis_tkeep]     [get_bd_pins tx_512_neck/s_axis_tkeep]
connect_bd_net [get_bd_pins tx_pad/m_axis_tvalid]    [get_bd_pins tx_512_neck/s_axis_tvalid]
connect_bd_net [get_bd_pins tx_pad/m_axis_tlast]     [get_bd_pins tx_512_neck/s_axis_tlast]
connect_bd_net [get_bd_pins tx_pad/m_axis_tuser]     [get_bd_pins tx_512_neck/s_axis_tuser]
connect_bd_net [get_bd_pins tx_512_neck/s_axis_tready] [get_bd_pins tx_pad/m_axis_tready]

# Stage 3 (INCREMENT 3): 1536 -> 384, the down-leg. Its output is the first place in the TX
# chain where a PARTIAL final beat appears: 256 bytes is five whole 48-byte beats plus a
# 16-byte remainder, where on the 512-bit side every beat was full. So the partial-beat
# handling in the FIFO, in mrmac_tx_adapt's tkeep_user encoding and in MRMAC itself is
# exercised on every single frame from here on.
connect_bd_net [get_bd_pins tx_512_neck/m_axis_tdata]  [get_bd_pins tx_neck_384/s_axis_tdata]
connect_bd_net [get_bd_pins tx_512_neck/m_axis_tkeep]  [get_bd_pins tx_neck_384/s_axis_tkeep]
connect_bd_net [get_bd_pins tx_512_neck/m_axis_tvalid] [get_bd_pins tx_neck_384/s_axis_tvalid]
connect_bd_net [get_bd_pins tx_512_neck/m_axis_tlast]  [get_bd_pins tx_neck_384/s_axis_tlast]
connect_bd_net [get_bd_pins tx_512_neck/m_axis_tuser]  [get_bd_pins tx_neck_384/s_axis_tuser]
connect_bd_net [get_bd_pins tx_neck_384/s_axis_tready] [get_bd_pins tx_512_neck/m_axis_tready]

# Stage 4 (INCREMENT 2): -> the store-and-forward frame FIFO, at 384 bits.
connect_bd_net [get_bd_pins tx_neck_384/m_axis_tdata]  [get_bd_pins tx_fifo/s_axis_tdata]
connect_bd_net [get_bd_pins tx_neck_384/m_axis_tkeep]  [get_bd_pins tx_fifo/s_axis_tkeep]
connect_bd_net [get_bd_pins tx_neck_384/m_axis_tvalid] [get_bd_pins tx_fifo/s_axis_tvalid]
connect_bd_net [get_bd_pins tx_neck_384/m_axis_tlast]  [get_bd_pins tx_fifo/s_axis_tlast]
connect_bd_net [get_bd_pins tx_neck_384/m_axis_tuser]  [get_bd_pins tx_fifo/s_axis_tuser]
connect_bd_net [get_bd_pins tx_fifo/s_axis_tready]   [get_bd_pins tx_neck_384/m_axis_tready]

# Stage 5 (INCREMENT 2): FIFO -> adapter. This is where the FIFO earns its place in
# the shim: with FRAME_FIFO=1 the adapter (and therefore MRMAC) never sees a mid-frame
# tvalid drop, no matter how the source stalls. Note the tready direction: the adapter
# back-pressures the FIFO's master side, and the FIFO -- not the generator -- is what
# absorbs MRMAC's inter-packet-gap stalls.
#
# tuser SPLITS HERE, and this is the one place in the chain where a hop is not 1:1.
# mrmac_tx_adapt takes ONLY the error bit (its USER_WIDTH is 1; it reads s_axis_tuser[0]
# and nothing else), while the 16-bit 1588 tag goes somewhere else entirely -- the
# glue's shim_tx_ptp_tag_field, from which MRMAC returns it alongside the TX timestamp.
# A BD net cannot slice a vector, so the split is done in RTL inside the FIFO wrapper,
# which exposes the two halves as separate pins (mrmac_shim_fifo.v: m_axis_tuser_err and
# m_axis_tuser_tag). Same constraint that forced mrmac_versal_glue to exist.
connect_bd_net [get_bd_pins tx_fifo/m_axis_tdata]  [get_bd_pins tx_adapt/s_axis_tdata]
connect_bd_net [get_bd_pins tx_fifo/m_axis_tkeep]  [get_bd_pins tx_adapt/s_axis_tkeep]
connect_bd_net [get_bd_pins tx_fifo/m_axis_tvalid] [get_bd_pins tx_adapt/s_axis_tvalid]
connect_bd_net [get_bd_pins tx_fifo/m_axis_tlast]  [get_bd_pins tx_adapt/s_axis_tlast]
connect_bd_net [get_bd_pins tx_fifo/m_axis_tuser_err] [get_bd_pins tx_adapt/s_axis_tuser]
connect_bd_net [get_bd_pins tx_adapt/s_axis_tready] [get_bd_pins tx_fifo/m_axis_tready]

# The tag half -> the glue -> mrmac_0/tx_ptp_tag_field_0. Wired HERE rather than in
# section 5b with the rest of the PTP plumbing because it is a tuser field and belongs
# with the stream it rides on; the glue-side pass-through is in 5b either way.
connect_bd_net [get_bd_pins tx_fifo/m_axis_tuser_tag] \
               [get_bd_pins mrmac_versal_glue/shim_tx_ptp_tag_field]

# Stage 6: packed 384b/66b bus, adapter -> the glue's shim-facing TX port.
connect_bd_net [get_bd_pins tx_adapt/tx_axis_tdata]      [get_bd_pins mrmac_versal_glue/shim_tx_axis_tdata]
connect_bd_net [get_bd_pins tx_adapt/tx_axis_tkeep_user] [get_bd_pins mrmac_versal_glue/shim_tx_axis_tkeep_user]
connect_bd_net [get_bd_pins tx_adapt/tx_axis_tvalid]     [get_bd_pins mrmac_versal_glue/shim_tx_axis_tvalid]
connect_bd_net [get_bd_pins tx_adapt/tx_axis_tlast]      [get_bd_pins mrmac_versal_glue/shim_tx_axis_tlast]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_tx_axis_tready] [get_bd_pins tx_adapt/tx_axis_tready]

# Stage 7: the glue's six segment outputs -> mrmac_0's segment pins.
#
# NOTE ON THE GND SWEEPS (section 6 and section 7). This section runs BEFORE both,
# and both skip any pin that already carries a bd_net -- so wiring the path here is
# what keeps it out of the sweeps. In the baseline the glue's shim_tx_axis_* inputs
# and mrmac_tx_axis_tready_0 were tied to GND because nothing drove them; now they
# are load-bearing and must not be. Ordering, not a special case, is what handles it.
for {set s 0} {$s < 6} {incr s} {
  connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tdata${s}]      [get_bd_pins mrmac_0/tx_axis_tdata${s}]
  connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tkeep_user${s}] [get_bd_pins mrmac_0/tx_axis_tkeep_user${s}]
}
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tvalid_0] [get_bd_pins mrmac_0/tx_axis_tvalid_0]
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tlast_0]  [get_bd_pins mrmac_0/tx_axis_tlast_0]
connect_bd_net [get_bd_pins mrmac_0/tx_axis_tready_0] [get_bd_pins mrmac_versal_glue/mrmac_tx_axis_tready_0]

# ---- RX: mrmac_0 -> glue (packed) -> rx_adapt -> ts_insert -> rx_fifo --------------
#             -> 384/64 -> 64/512 -> pkt_chk(512)
#
# THE RX FIFO STOPS BEING A PASS-THROUGH IN THIS INCREMENT. Through increments 1-4 it
# sat between two interfaces that could not stall (MRMAC RX has no back-pressure, and
# the checker consumed every beat), so its m_axis_tready was tied 1 inside the wrapper
# and DROP_WHEN_FULL was unreachable. Increment 3 puts the back-pressuring 384->64
# down-converter downstream of it, which is the thing the FIFO exists to absorb -- so
# m_axis_tready is now a real port carrying the converter's, and a drop is now possible.
# That is the intended order: the absorber went in first (increment 2), proven not to
# disturb the byte-exact stream, and the thing it absorbs arrives now.
#
# The FIFO's own s_axis_tready is still left open, all the way up the chain: MRMAC RX
# cannot be back-pressured, mrmac_rx_adapt has no tready port at all, and mac_ts_insert
# drives s_axis_tready = m_axis_tready which its wrapper ties high. So no tready net
# exists between mrmac_0 and the FIFO, exactly as in the wrapper.
for {set s 0} {$s < 6} {incr s} {
  connect_bd_net [get_bd_pins mrmac_0/rx_axis_tdata${s}]      [get_bd_pins mrmac_versal_glue/mrmac_rx_axis_tdata${s}]
  connect_bd_net [get_bd_pins mrmac_0/rx_axis_tkeep_user${s}] [get_bd_pins mrmac_versal_glue/mrmac_rx_axis_tkeep_user${s}]
}
connect_bd_net [get_bd_pins mrmac_0/rx_axis_tvalid_0] [get_bd_pins mrmac_versal_glue/mrmac_rx_axis_tvalid_0]
connect_bd_net [get_bd_pins mrmac_0/rx_axis_tlast_0]  [get_bd_pins mrmac_versal_glue/mrmac_rx_axis_tlast_0]

connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_axis_tdata]      [get_bd_pins rx_adapt/rx_axis_tdata]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_axis_tkeep_user] [get_bd_pins rx_adapt/rx_axis_tkeep_user]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_axis_tvalid]     [get_bd_pins rx_adapt/rx_axis_tvalid]
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_axis_tlast]      [get_bd_pins rx_adapt/rx_axis_tlast]

# RX stage 1 (INCREMENT 5): the adapter's flat 384-bit output -> mac_ts_insert, which is
# where tuser WIDENS from 1 bit (rx_adapt's error bit) to 81 ({ptp_ts[79:0], err}). This
# is what forces USER_WIDTH=81 on the FIFO and both RX converters downstream.
#
# Placed at 384 bits, on the MRMAC side of the FIFO -- the wrapper's own choice, and a
# deliberate one: the stamp rides WITH the frame through the FIFO and the width
# conversion, so a frame the FIFO drops takes its stamp with it, rather than the stream
# and the timestamps desynchronizing by one frame from then on.
connect_bd_net [get_bd_pins rx_adapt/m_axis_tdata]  [get_bd_pins ts_insert/s_axis_tdata]
connect_bd_net [get_bd_pins rx_adapt/m_axis_tkeep]  [get_bd_pins ts_insert/s_axis_tkeep]
connect_bd_net [get_bd_pins rx_adapt/m_axis_tvalid] [get_bd_pins ts_insert/s_axis_tvalid]
connect_bd_net [get_bd_pins rx_adapt/m_axis_tlast]  [get_bd_pins ts_insert/s_axis_tlast]
connect_bd_net [get_bd_pins rx_adapt/m_axis_tuser]  [get_bd_pins ts_insert/s_axis_tuser]

# RX stage 2 (INCREMENT 2): -> the dropping elastic frame FIFO, still at 384 bits.
connect_bd_net [get_bd_pins ts_insert/m_axis_tdata]  [get_bd_pins rx_fifo/s_axis_tdata]
connect_bd_net [get_bd_pins ts_insert/m_axis_tkeep]  [get_bd_pins rx_fifo/s_axis_tkeep]
connect_bd_net [get_bd_pins ts_insert/m_axis_tvalid] [get_bd_pins rx_fifo/s_axis_tvalid]
connect_bd_net [get_bd_pins ts_insert/m_axis_tlast]  [get_bd_pins rx_fifo/s_axis_tlast]
connect_bd_net [get_bd_pins ts_insert/m_axis_tuser]  [get_bd_pins rx_fifo/s_axis_tuser]

# RX stage 3 (INCREMENT 3): 384 -> 1536, the up-leg. THE tready HERE IS THE POINT of
# this increment on the RX side -- it is the first real back-pressure the RX FIFO has
# ever seen in this bench.
connect_bd_net [get_bd_pins rx_fifo/m_axis_tdata]  [get_bd_pins rx_384_neck/s_axis_tdata]
connect_bd_net [get_bd_pins rx_fifo/m_axis_tkeep]  [get_bd_pins rx_384_neck/s_axis_tkeep]
connect_bd_net [get_bd_pins rx_fifo/m_axis_tvalid] [get_bd_pins rx_384_neck/s_axis_tvalid]
connect_bd_net [get_bd_pins rx_fifo/m_axis_tlast]  [get_bd_pins rx_384_neck/s_axis_tlast]
connect_bd_net [get_bd_pins rx_fifo/m_axis_tuser]  [get_bd_pins rx_384_neck/s_axis_tuser]
connect_bd_net [get_bd_pins rx_384_neck/s_axis_tready] [get_bd_pins rx_fifo/m_axis_tready]

# RX stage 4 (INCREMENT 3): 1536 -> 512, the down-leg, whose master side is the fpga_core
# boundary in the shim and the 512-bit checker here. No m_axis_tready net: the wrapper
# ties it to 1 ("fpga_core RX has no tready") and so does the wrapper module, which
# omits the port entirely.
connect_bd_net [get_bd_pins rx_384_neck/m_axis_tdata]  [get_bd_pins rx_neck_512/s_axis_tdata]
connect_bd_net [get_bd_pins rx_384_neck/m_axis_tkeep]  [get_bd_pins rx_neck_512/s_axis_tkeep]
connect_bd_net [get_bd_pins rx_384_neck/m_axis_tvalid] [get_bd_pins rx_neck_512/s_axis_tvalid]
connect_bd_net [get_bd_pins rx_384_neck/m_axis_tlast]  [get_bd_pins rx_neck_512/s_axis_tlast]
connect_bd_net [get_bd_pins rx_384_neck/m_axis_tuser]  [get_bd_pins rx_neck_512/s_axis_tuser]
connect_bd_net [get_bd_pins rx_neck_512/s_axis_tready] [get_bd_pins rx_384_neck/m_axis_tready]

# RX stage 5: -> the 512-bit checker. tuser arrives whole (81 bits); the checker uses
# bit 0 (the MAC error bit) and ignores the timestamp -- see mrmac_flat512_pkt_gen_chk.v
# on why time accuracy is not this bench's verdict.
# *** INCREMENT 6 *** inserts port_map between rx_neck_512 and pkt_chk, mirroring the TX
# head: the shim's 512-bit output enters the map's MAC side and the checker reads the
# map's DATAPATH side. tuser is 81 on both, so it crosses whole -- which is required,
# not merely tidy, since a BD net cannot slice (the reason the checker takes all 81 bits
# in the first place -- see mrmac_flat512_pkt_gen_chk.v).
#
# NO TREADY ON THIS HOP. mrmac_shim_axis_1536_512 has no m_axis_tready PORT (it ties the
# adapter's master ready to 1'b1 internally -- mrmac_shim_widthconv.v:335-338, matching
# mrmac_gty_wrapper.v:659 "fpga_core RX has no tready"), and pkt_chk likewise has no
# tready. So the map's s_axis_mac_rx_tready OUTPUT has no consumer and its
# m_axis_rx_tready INPUT has no producer. The former is left dangling; the latter must be
# tied HIGH, not GND -- see the VCC tie in the increment-6 sweep below. Tying it low
# would silently stall the map's RX path while every other signal looked correct.
connect_bd_net [get_bd_pins rx_neck_512/m_axis_tdata]  [get_bd_pins port_map/s_axis_mac_rx_tdata]
connect_bd_net [get_bd_pins rx_neck_512/m_axis_tkeep]  [get_bd_pins port_map/s_axis_mac_rx_tkeep]
connect_bd_net [get_bd_pins rx_neck_512/m_axis_tvalid] [get_bd_pins port_map/s_axis_mac_rx_tvalid]
connect_bd_net [get_bd_pins rx_neck_512/m_axis_tlast]  [get_bd_pins port_map/s_axis_mac_rx_tlast]
connect_bd_net [get_bd_pins rx_neck_512/m_axis_tuser]  [get_bd_pins port_map/s_axis_mac_rx_tuser]

connect_bd_net [get_bd_pins port_map/m_axis_rx_tdata]  [get_bd_pins pkt_chk/s_axis_tdata]
connect_bd_net [get_bd_pins port_map/m_axis_rx_tkeep]  [get_bd_pins pkt_chk/s_axis_tkeep]
connect_bd_net [get_bd_pins port_map/m_axis_rx_tvalid] [get_bd_pins pkt_chk/s_axis_tvalid]
connect_bd_net [get_bd_pins port_map/m_axis_rx_tlast]  [get_bd_pins pkt_chk/s_axis_tlast]
connect_bd_net [get_bd_pins port_map/m_axis_rx_tuser]  [get_bd_pins pkt_chk/s_axis_tuser]

# Generator enable + status/results out to TB boundary ports. `enable` is what the
# test program raises once RX has aligned, so no frame is launched into an
# unaligned link (the exdes gates its generator on the same condition via
# c0_trig_in). The four status ports let the test program report the internal
# verdict alongside the MRMAC statistics counters -- two independent measures of
# the same round trip.
create_bd_port -dir I  gen_enable
create_bd_port -dir O -from 31 -to 0 gen_sent_pkts
create_bd_port -dir O  gen_done
create_bd_port -dir O -from 31 -to 0 chk_matched_pkts
create_bd_port -dir O -from 31 -to 0 chk_mismatched_pkts
create_bd_port -dir O -from 31 -to 0 chk_rx_bytes
create_bd_port -dir O  chk_all_done
ad_connect gen_enable          pkt_gen/enable
ad_connect gen_sent_pkts       pkt_gen/sent_pkts
ad_connect gen_done            pkt_gen/done
ad_connect chk_matched_pkts    pkt_chk/matched_pkts
ad_connect chk_mismatched_pkts pkt_chk/mismatched_pkts
ad_connect chk_rx_bytes        pkt_chk/rx_bytes
ad_connect chk_all_done        pkt_chk/all_done

# The AXIS client clock (390.625 MHz, clk_wizard/clk_out1) out to a TB port. Needed
# because tx_ptp_ts_valid is a ONE-CYCLE pulse per completion in this domain: the TB
# must sample it on a real clock edge, and a test program that polled it would miss
# every pulse. Exporting the clock keeps the TB collector off a hierarchical reference
# into the BD, which would break whenever the clocking is rearranged (as it just was
# in the consumer project).
create_bd_port -dir O -type clk axis_clk_out
ad_connect axis_clk_out clk_wizard/clk_out1

# RX PTP observation. The checker latches the timestamp mac_ts_insert wrote into
# tuser[80:1] at each frame's SOP; these carry it out so the test program can decide
# whether the RX PTP path is alive. Deliberately NOT part of the byte-exact verdict --
# the timebase is local (ptp_timegen), so absolute values mean nothing; what is
# checkable is liveness (non-zero) and progress (last > first, not stuck).
create_bd_port -dir O -from 79 -to 0 chk_rx_ptp_ts_first
create_bd_port -dir O -from 79 -to 0 chk_rx_ptp_ts_last
create_bd_port -dir O -from 31 -to 0 chk_rx_ptp_nonzero_pkts
create_bd_port -dir O -from 31 -to 0 chk_rx_ptp_stuck_pkts
ad_connect chk_rx_ptp_ts_first     pkt_chk/rx_ptp_ts_first
ad_connect chk_rx_ptp_ts_last      pkt_chk/rx_ptp_ts_last
ad_connect chk_rx_ptp_nonzero_pkts pkt_chk/rx_ptp_ts_nonzero_pkts
ad_connect chk_rx_ptp_stuck_pkts   pkt_chk/rx_ptp_ts_stuck_pkts

##########################################################################
# 5b. PTP -- *** INCREMENT 5 ***.
#
#     Three distinct plumbing jobs, and they are easier to check if kept apart:
#
#       (i)   the ts CLOCK, glue -> mrmac_0. 250 MHz, not the AXIS clock: PG314 caps
#             this input at 50-350 MHz.
#       (ii)  glue <-> mrmac_0, the twelve MRMAC-facing PTP nets. Copied VERBATIM from
#             the sibling framework bench (mrmac_realip_loopback_gty/system_bd.tcl,
#             section 5b), which in turn takes them verbatim from the island proc. Pin
#             names on both sides are therefore not guessed.
#       (iii) glue <-> the new PTP cells, the shim-facing side. This is what the
#             sibling wires to mrmac_dut (the packaged shim) in its section 6b; here
#             the individual cells stand in for the shim's internals, so each of those
#             twelve nets terminates on a specific cell instead.
#
#     RUNS BEFORE THE GND SWEEPS (sections 6 and 7), like section 5, and for the same
#     reason: both sweeps skip any pin that already carries a bd_net. Every glue and
#     mrmac_0 PTP pin touched here was GND'd in the baseline and must not be now.
#     Ordering is the whole mechanism.
##########################################################################

# (i) The timestamp clock. glue/mrmac_ts_clk is `{4{ts_clk_in}}` -- a 4-bit fan-out of
# clk_wizard/clk_out2 (250 MHz), connected in section 2. mrmac_0's tx_ts_clk and
# rx_ts_clk are both [3:0], one per lane, so this is a straight 4-bit net.
#
# This is *** EXDES *** DELTA (4) BEING GIVEN UP. The passing reference ties both to
# zero (exdes.sv:656-657) because it does not use timestamping; increment 5 does, so
# they must be clocked. 250 MHz must also agree with the IP's
# CONFIG.TIMESTAMP_CLK_PERIOD_NS {4.0} -- the IP scales its internal ns increment by
# that value, so a mismatch makes every timestamp wrong by the ratio.
connect_bd_net [get_bd_pins mrmac_versal_glue/mrmac_ts_clk] \
               [get_bd_pins mrmac_0/tx_ts_clk] \
               [get_bd_pins mrmac_0/rx_ts_clk]

# (ii) glue <-> mrmac_0. VERBATIM from the sibling's section 5b.
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

# (iii) glue <-> the PTP cells. Two independent flows, TIME OUT and STAMPS BACK.
#
# TIME OUT -- disciplining MRMAC's two internal PTP timers to Corundum's PHC:
#
#   ptp_timegen (80b Corundum) -> {tx,rx}_time_cvt (80 -> 55) -> {tx,rx}_ptp_sync
#     -> glue shim_*_ptp_{systemtimer,st_sync,st_overwrite} -> mrmac_0 ctl_*_ptp_*
#
# STAMPS BACK -- what MRMAC reports:
#
#   RX: mrmac_0 rx_ptp_tstamp_out_0 -> glue shim_rx_ptp_tstamp (55b)
#         -> rx_ts_cvt (55 -> 80) -> ts_insert/ptp_ts -> tuser[80:1] -> pkt_chk
#   TX: mrmac_0 tx_ptp_tstamp_out_0 -> glue shim_tx_ptp_tstamp (55b) -> tx_ts_cvt
#         -> boundary port (nothing in this bench consumes a TX completion stamp;
#            in the shim it goes to fpga_core's TX timestamp FIFO)
#
# The 16-bit TX tag is NOT here -- it is a tuser field and is wired with the stream it
# rides on, at the TX FIFO's master side in section 5.

# ptp_timegen -> both discipline converters. One counter for both, as in the shim:
# Corundum has a single PHC and both MRMAC timers are disciplined to it.
connect_bd_net [get_bd_pins ptp_timegen/ptp_time] \
               [get_bd_pins tx_time_cvt/cor_ts_in] \
               [get_bd_pins rx_time_cvt/cor_ts_in]

connect_bd_net [get_bd_pins tx_time_cvt/mrmac_ts_out] [get_bd_pins tx_ptp_sync/systemtime_in]
connect_bd_net [get_bd_pins rx_time_cvt/mrmac_ts_out] [get_bd_pins rx_ptp_sync/systemtime_in]

connect_bd_net [get_bd_pins tx_ptp_sync/systemtimer]  [get_bd_pins mrmac_versal_glue/shim_tx_ptp_systemtimer]
connect_bd_net [get_bd_pins tx_ptp_sync/st_sync]      [get_bd_pins mrmac_versal_glue/shim_tx_ptp_st_sync]
connect_bd_net [get_bd_pins tx_ptp_sync/st_overwrite] [get_bd_pins mrmac_versal_glue/shim_tx_ptp_st_overwrite]
connect_bd_net [get_bd_pins rx_ptp_sync/systemtimer]  [get_bd_pins mrmac_versal_glue/shim_rx_ptp_systemtimer]
connect_bd_net [get_bd_pins rx_ptp_sync/st_sync]      [get_bd_pins mrmac_versal_glue/shim_rx_ptp_st_sync]
connect_bd_net [get_bd_pins rx_ptp_sync/st_overwrite] [get_bd_pins mrmac_versal_glue/shim_rx_ptp_st_overwrite]

# RX stamp back into the frame's tuser. This closes the RX PTP loop: MRMAC captures a
# timestamp on the received frame, and mac_ts_insert writes it into tuser[80:1] at that
# frame's SOP.
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_rx_ptp_tstamp] [get_bd_pins rx_ts_cvt/mrmac_ts_in]
connect_bd_net [get_bd_pins rx_ts_cvt/cor_ts_out]                 [get_bd_pins ts_insert/ptp_ts]

# TX completion stamp. In the shim this returns to fpga_core; here it goes to boundary
# ports so the test program can SEE the TX PTP path produce something, which is the only
# available evidence that it works at all -- there is no consumer and no reference value
# to compare against. Exported: the converted 80-bit stamp, and MRMAC's own tag and
# valid straight from the glue.
#
# The TAG is the interesting one. pkt_gen sets tuser[16:1] = the packet index, so a
# stamp coming back tagged N is provably MRMAC's response to frame N -- the TX 1588
# request/response round trip, end to end, observable at the TB boundary.
connect_bd_net [get_bd_pins mrmac_versal_glue/shim_tx_ptp_tstamp] [get_bd_pins tx_ts_cvt/mrmac_ts_in]

create_bd_port -dir O -from 79 -to 0 tx_ptp_ts
create_bd_port -dir O -from 15 -to 0 tx_ptp_ts_tag
create_bd_port -dir O tx_ptp_ts_valid
ad_connect tx_ptp_ts       tx_ts_cvt/cor_ts_out
ad_connect tx_ptp_ts_tag   mrmac_versal_glue/shim_tx_ptp_tstamp_tag
ad_connect tx_ptp_ts_valid mrmac_versal_glue/shim_tx_ptp_tstamp_valid

# 1588 OPERATION MODE = 2'b10, the 2-step timestamp request. The wrapper supplies this
# as a hard constant (mrmac_gty_wrapper.v:444 `assign mrmac_tx_ptp_1588op = 2'b10;`)
# because Corundum always wants a stamp back and never uses 1-step insertion -- exactly
# what CMAC does. In a block design a constant needs a cell, so: xlconstant, matching
# the gt_line_rate pattern in section 8.
#
# glue/shim_tx_ptp_1588op is a 2-bit INPUT that the baseline GND-swept (nothing drove
# it). It is load-bearing now, and section 6 skipping already-driven pins is what keeps
# the sweep off it.
ad_ip_instance xlconstant tx_ptp_1588op [list \
  CONST_WIDTH 2 \
  CONST_VAL 2 \
]
connect_bd_net [get_bd_pins tx_ptp_1588op/dout] \
               [get_bd_pins mrmac_versal_glue/shim_tx_ptp_1588op]

# THE UNUSED DIRECTIONS. Each mrmac_ptp_ts_cvt is a bidirectional pair of shifts and
# each instance uses exactly one direction, so three inputs across the four cells have
# no producer. They are NOT covered by any GND sweep -- sections 6 and 7 walk
# mrmac_versal_glue, mrmac_0 and gtwiz_versal only, never a cell added here -- so they
# would float to X and, because the converters are combinational, propagate that X onto
# the unused OUTPUT of each cell. Harmless in principle; loud and confusing in a
# waveform. Tie them.
#
# gnd_pin_obj, not ad_connect: these are plain scalar-name pins on a module cell with no
# inferred interface, so ad_connect would work -- but gnd_pin_obj shares the same GND_*
# ilconstant cells and cannot be tripped by name resolution, which is the failure this
# bench has already been bitten by twice.
gnd_pin_obj [get_bd_pins tx_ts_cvt/cor_ts_in]
gnd_pin_obj [get_bd_pins tx_time_cvt/mrmac_ts_in]
gnd_pin_obj [get_bd_pins rx_time_cvt/mrmac_ts_in]
# rx_ts_cvt/cor_ts_in is the fourth: also unused, also tied.
gnd_pin_obj [get_bd_pins rx_ts_cvt/cor_ts_in]

##########################################################################
# 5c. INCREMENT 6: the port map's clocks, resets, and unused pins.
#
#     THE MAP HAS NO CLOCK OF ITS OWN. mac_tx_clk / mac_rx_clk are INPUTS that it merely
#     forwards to tx_clk / rx_clk (assign tx_clk[IND] = mac_tx_clk[n]) for fpga_core's
#     benefit -- there is no register in this module. Same for the four *_rst and the
#     four *_ptp_clk/*_ptp_rst. So they are driven for FIDELITY with the real design, and
#     the forwarded outputs are left dangling because this bench's fixtures take their
#     clock and reset directly from clk_wizard / the glue, exactly as they did before.
#
#     The MAC-side clock/reset pair is the shim's domain (clk_out1 + the synchronized
#     resets), matching what the wrapper hands the map in mrmac_gty_wrapper.v.
##########################################################################
#     ALL FOUR CLOCK PINS GET A REAL CLOCK, INCLUDING THE PTP PAIR. mac_tx_ptp_clk and
#     mac_rx_ptp_clk cannot be tied off:
#
#       ERROR: [BD 41-758] The following clock pins are not connected to a valid clock
#       source: /port_map/mac_tx_ptp_clk /port_map/mac_rx_ptp_clk
#
#     Vivado INFERS CONFIG.TYPE=clk from the pin NAME (this RTL has no X_INTERFACE_INFO
#     at all), and a clk-typed pin demands a clock SOURCE -- an ilconstant does not
#     qualify, so GND-sweeping them does not silence 41-758, it just moves the error.
#     ethernet_vck190.v gets away with `.mac_tx_ptp_clk({PORT_COUNT{1'b0}})` because that
#     is plain RTL, where no such inference exists; a block design is stricter. This is
#     the same clock-TYPE-inference trap already recorded for this BD.
#
#     clk_out1 is also the HONEST value, not just the one that validates: this bench's
#     PTP timebase (ptp_timegen, section 5b) runs on clk_out1, so that genuinely IS the
#     PTP domain here. The pins are forwarding-only regardless -- the map copies them
#     straight to tx_ptp_clk / rx_ptp_clk, which have no consumer in this bench.
connect_bd_net [get_bd_pins clk_wizard/clk_out1] \
               [get_bd_pins port_map/mac_tx_clk] \
               [get_bd_pins port_map/mac_rx_clk] \
               [get_bd_pins port_map/mac_tx_ptp_clk] \
               [get_bd_pins port_map/mac_rx_ptp_clk]

# TX and RX take their own synchronized reset, keeping the two trees distinct for the
# same reason section 5 does: it makes this readable against mrmac_gty_wrapper.v.
#
# The PTP resets are driven too, and for a less obvious reason than the clocks: the sweep
# below skips anything whose name ends in _rst, so mac_{tx,rx}_ptp_rst would be neither
# swept nor connected -- a floating input going to X. No error, just X propagating onto
# the map's tx_ptp_rst / rx_ptp_rst outputs. Pair each with its own side's reset, matching
# the clock pairing above.
connect_bd_net [get_bd_pins tx_rst_sync/out] \
               [get_bd_pins port_map/mac_tx_rst] \
               [get_bd_pins port_map/mac_tx_ptp_rst]
connect_bd_net [get_bd_pins rx_rst_sync/out] \
               [get_bd_pins port_map/mac_rx_rst] \
               [get_bd_pins port_map/mac_rx_ptp_rst]

# THE TWO READY INPUTS THAT MUST BE HIGH, NOT GND. Tied before the sweep so the
# already-driven test keeps the blanket GND pass off them. See vcc_pin_obj's header for
# why a low tie here would be a silent stall rather than a loud error.
vcc_pin_obj [get_bd_pins port_map/m_axis_rx_tready]
vcc_pin_obj [get_bd_pins port_map/m_axis_tx_ptp_ts_ready]

# tx_enable / rx_enable: held asserted. These reach the map's mac_{tx,rx}_enable outputs,
# which in the real design gate the MAC. For MRMAC they are DECORATIVE -- MRMAC has no
# ctl_tx_enable/ctl_rx_enable pin at all and is enabled by s_axi register writes (see
# [[mrmac-mac-enable-via-axi]]), which is exactly what this bench's test program does.
# Driven high anyway so the map's forwarding is exercised rather than left at X.
vcc_pin_obj [get_bd_pins port_map/tx_enable]
vcc_pin_obj [get_bd_pins port_map/rx_enable]

# mac_tx_status / mac_rx_status: the MAC reporting link-up back to the datapath. MRMAC
# reports through STAT_RX_STATUS over s_axi, not a pin, and the test program already
# polls that before raising gen_enable -- so there is nothing to wire here and a
# hard 1 is the honest value, matching ethernet_vck190.v's own
# .mac_tx_status({PORT_COUNT{1'b1}}).
vcc_pin_obj [get_bd_pins port_map/mac_tx_status]
vcc_pin_obj [get_bd_pins port_map/mac_rx_status]

# Everything else on the map with no producer -> GND. That is the whole flow-control
# group (tx/rx lfc + pfc, both directions), the PTP time/step inputs (this bench
# disciplines MRMAC directly from ptp_timegen through the glue in section 5b -- the map
# is not in that path), and the TX-completion-stamp slave port (nothing loops a TX stamp
# back here; section 5b exports it to a boundary port instead).
#
# A DEDICATED SWEEP, not an extension of section 6/7/10: those three walk
# mrmac_versal_glue, mrmac_0 and gtwiz_versal only and never touch a cell added by the
# increments. That is why every previous increment tied its own new cells' loose inputs by
# hand (see the four mrmac_ptp_ts_cvt ties at the end of 5b). The map has ~20 such pins,
# so a sweep is warranted -- but it uses the SAME two guards those sections do:
#
#   - skip clocks and resets by name (already connected above, but explicit);
#   - skip anything with a bd_net already, which is what protects the AXIS pins wired in
#     section 5 and the six VCC ties above;
#   - skip interface members that carry a bd_intf_net, the get_bd_nets-is-blind-to-
#     bd_intf_nets trap that was the root cause fix in the behavioral loopback.
#
# gnd_pin_obj rather than ad_connect, for the name-collision reason at the top of this
# file -- and it applies with particular force here: port_map's m_axis_*/s_axis_* names
# are precisely the patterns Vivado auto-infers interfaces from.
set _pm [get_bd_cells port_map]
set _pmexcl [dict create]
foreach _if [get_bd_intf_pins -quiet -of $_pm] {
  if {[llength [get_bd_intf_nets -quiet -of $_if]] == 0} { continue }
  foreach _mp [get_bd_pins -quiet -of $_if] { dict set _pmexcl $_mp 1 }
}
foreach _pin [get_bd_pins -of $_pm -filter {DIR == I}] {
  set _nm [file tail $_pin]
  if {[regexp {clk$|_clk$|clk_|rst$|_rst$|resetn$} $_nm]}   { continue }
  if {[dict exists $_pmexcl $_pin]}                          { continue }
  if {[llength [get_bd_nets -quiet -of $_pin]] > 0}          { continue }
  gnd_pin_obj $_pin
}

##########################################################################
# 6. GND-sweep the glue's still-unused shim-facing inputs.
#
#    WHAT IS LEFT TO SWEEP SHRANK AGAIN WITH INCREMENT 5. Section 5 drives the whole
#    AXIS path (shim_tx_axis_* and mrmac_rx_axis_*), and section 5b now drives the
#    whole PTP group too -- shim_tx_ptp_1588op, shim_tx_ptp_tag_field, and all six
#    shim_{tx,rx}_ptp_{systemtimer,st_sync,st_overwrite}. What remains genuinely
#    undriven is the pause/flow-control group (shim_ctl_{tx,rx}_pause_*), whose driver
#    in the real design is mqnic_port_map_mac_axis -- a later rung of the ladder. Those
#    inputs would float, so tie them to GND. Their downstream mrmac_ctl_* glue OUTPUTS
#    are left dangling; mrmac_0's corresponding inputs are GND-swept in section 7, so
#    no MRMAC pin ends up with two drivers.
#
#    Excluded from the sweep: clocks, resets, and anything already driven above --
#    which now includes the whole AXIS path AND the whole PTP path, and that is exactly
#    what keeps those newly load-bearing pins out of it. The "already driven" test
#    below is the mechanism; sections 5 and 5b running first is why it fires. (In the
#    baseline every one of those pins was legitimately GND'd.)
#    Interface-member pins are excluded via the get_bd_intf_pins dict -- get_bd_nets
#    is BLIND to bd_intf_nets, so without this a member of an already-connected
#    interface looks undriven and gets a second driver (the root-cause trap fixed in
#    the behavioral mrmac_loopback -- see [[mrmac-loopback-testbench]]).
##########################################################################
set _glue [get_bd_cells mrmac_versal_glue]

# PRECISE rule (differs from the sibling's blanket "all interface members"): protect
# a member ONLY if its interface actually carries a bd_intf_net. Vivado AUTO-INFERS
# interfaces from name patterns (_tdata/_tvalid/_tlast, and the PTP tstamp group)
# even though this RTL has no X_INTERFACE_INFO at all (grep: 0 hits; the 36
# attributes present are X_INTERFACE_IGNORE, which suppress CONFIG.TYPE=clk
# inference, not bus grouping). So a blanket dict here would shadow
# shim_tx_axis_{tdata,tvalid,tlast} -- pins that MUST be GND'd now that the shim is
# gone -- and leave them floating.
#
# The pin's OWN net is the authority on whether it is already driven, and it is
# checked below. An interface-level net additionally protects members that were
# connected AS an interface (get_bd_nets is blind to bd_intf_nets -- the original
# trap). Both checks are needed: keying on the interface net ALONE wrongly GND'd
# mrmac_tx_axis_tready_0, which has a real bd_net from mrmac_0 while its inferred
# mrmac_tx_axis_0 interface has no bd_intf_net -- producing
#   WARNING: [BD 41-1306] the connection to interface pin ... is being overridden
#            by the user with net /GND_1_dout
# i.e. a silent second driver on an already-connected pin.
set _glexcl [dict create]
foreach _if [get_bd_intf_pins -quiet -of $_glue] {
  if {[llength [get_bd_intf_nets -quiet -of $_if]] == 0} { continue }
  foreach _mp [get_bd_pins -quiet -of $_if] { dict set _glexcl $_mp 1 }
}
foreach _pin [get_bd_pins -of $_glue -filter {DIR == I}] {
  set _nm [file tail $_pin]
  if {[regexp {clk$|_clk$|clk_|resetn$} $_nm]}      { continue }
  if {[dict exists $_glexcl $_pin]}                 { continue }
  if {[llength [get_bd_nets -quiet -of $_pin]] > 0} { continue }
  # gnd_pin_obj, NOT ad_connect: several of these pin paths are name-identical to an
  # inferred bd_intf_pin, which ad_connect's name resolution picks first. See the
  # helper's comment at the top of this file.
  gnd_pin_obj $_pin
}

##########################################################################
# 7. mrmac_0: s_axi to TB boundary ports, then GND-sweep every remaining input.
#
#    *** THE OTHER BIG STRIP ***  In the sibling, s_axi went through
#    ad_cpu_interconnect into the framework's management VIP -- an AXI interconnect,
#    a crossbar, an address decode and a clock-domain story, all in the path of
#    every register access, and the place where reads were observed returning
#    rresp=SLVERR and stale/zero payload. Here s_axi is driven by PLAIN TB WIRES
#    with the exdes's own axi_write/axi_read tasks, exactly as the passing reference
#    does. MRMAC's s_axi has NO wstrb and NO awprot/arprot (verified in mrmac_0.v:
#    18 signals total), so this is trivially drivable from a TB.
#
#    Note these are individually-connectable pins even though they are members of
#    the s_axi aximm interface -- which is exactly why the sweep below needs the
#    interface-member exclusion dict.
##########################################################################
# s_axi clock + reset: the freerun clock and the board reset, matching the exdes
# (which uses s_axi_aclk as its freerun clock, exdes.sv:1319, and s_axi_aresetn from
# the board reset, :1173). Connected BEFORE the sweep: these are scalar pins, NOT
# members of the s_axi interface bus, so the exclusion dict below does not cover
# them and the sweep would otherwise tie them to GND.
ad_connect gt_freerun_clk mrmac_0/s_axi_aclk
ad_connect pl_resetn      mrmac_0/s_axi_aresetn

# The 16 AXI4-Lite channel signals as boundary ports. Names mirror the pins so the
# TB port map reads 1:1 against mrmac_0.v.
foreach {_dir _w _p} {
  I  32 s_axi_awaddr
  I  0  s_axi_awvalid
  O  0  s_axi_awready
  I  32 s_axi_wdata
  I  0  s_axi_wvalid
  O  0  s_axi_wready
  O  2  s_axi_bresp
  O  0  s_axi_bvalid
  I  0  s_axi_bready
  I  32 s_axi_araddr
  I  0  s_axi_arvalid
  O  0  s_axi_arready
  O  32 s_axi_rdata
  O  2  s_axi_rresp
  O  0  s_axi_rvalid
  I  0  s_axi_rready
} {
  if {$_w == 0} {
    create_bd_port -dir $_dir $_p
  } else {
    create_bd_port -dir $_dir -from [expr {$_w - 1}] -to 0 $_p
  }
  ad_connect $_p mrmac_0/$_p
}

# Tie every remaining UNDRIVEN mrmac_0 input to GND. This is what produces the
# exdes-matching 4'b0000 on tx_flexif_clk / rx_flexif_clk (deliberately left
# unconnected in section 4), plus all the pause/AN-LT inputs the glue used to drive.
#
# The regexp exclusion the sibling used for clocks is INTENTIONALLY ABSENT here:
# GND-ing the two flexif clock pins is the desired outcome, not an accident.
#
# tx_ts_clk / rx_ts_clk are NO LONGER swept, and neither are the twelve PTP pins. All
# fourteen are driven in section 5b, which runs first, so the already-driven test below
# skips them -- the same ordering mechanism section 5 relies on. Through increments 1-4
# this sweep GND'd every one of them (timestamping was off and the PTP pins did not even
# exist on the generated core); if increment 5 is ever reverted, they come back here on
# their own with no change to this section.
#
# *** The exclusion dict is DELIBERATELY NARROW -- s_axi ONLY, exactly as in the
# sibling. Do NOT broaden it to "all interfaces of mrmac_0": 226 of mrmac_0's 248
# inputs are members of some single- or few-pin bus interface (every ctl_tx_port*,
# ctl_rx_port*, fec_*_port*, tx_flex_*_in, tx_ptp_*_in, gt_{tx,rx}_serdes_interface_*,
# AND each clock/reset, which gets its own *_port interface: tx_ts_clk ->
# 'tx_ts_clk_port', tx_flexif_clk -> 'tx_flexif_clk_port', ...). A dict built from
# all of them shadows almost the whole sweep and leaves those pins FLOATING, whereas
# the passing exdes ties every one of them to an explicit 1'b0 (exdes.sv:1221-1299
# for the ctl/flex/ptp set, :616-617 and :656-657 for flexif/ts clk = 4'b0000).
#
# The dict exists only to defend against the bd_intf_net trap: get_bd_nets is BLIND
# to interface nets, so a member of an interface connected AS AN INTERFACE looks
# undriven and would get a second driver. In this bench nothing on mrmac_0 is
# interface-connected -- serdes data, s_axi and AXIS are all wired pin-by-pin with
# connect_bd_net/ad_connect, which DOES work on members and leaves visible bd_nets.
# The s_axi entry is therefore belt-and-braces, kept for symmetry with the sibling
# (where s_axi really did cross ad_cpu_interconnect as an interface).
set _excl [dict create]
foreach _mp [get_bd_pins -quiet -of [get_bd_intf_pins -quiet mrmac_0/s_axi]] {
  dict set _excl $_mp 1
}
foreach _p [lsort [get_bd_pins -quiet -of [get_bd_cells mrmac_0]]] {
  if {[get_property DIR $_p] ne "I"} continue
  if {[dict exists $_excl $_p]} continue
  if {[llength [get_bd_nets -quiet -of $_p]]} continue
  # gnd_pin_obj, NOT ad_connect: mrmac_0 has ~200 pins that are name-identical to a
  # single-pin bus interface (tx_ts_clk / 'tx_ts_clk_port', the ctl_*_port* groups,
  # ...), and ad_connect resolves names via get_bd_intf_pins first.
  gnd_pin_obj $_p
}

##########################################################################
# 8. GT (gtwiz) secondary inputs -> constants.
##########################################################################
# *** EXDES *** gt_line_rate = 8'h00, NOT 8'h02. The passing reference runs with
# ZERO: exdes_tb.v:351 sets gt_line_rate=8'h00, and line 416's
# `gt_line_rate=8'h02;` is COMMENTED OUT; exdes.sv:1081 fans the value to all four
# ch_{tx,rx}rate pins. The sibling's CONST_VAL 2 was a divergence from the only
# known-good value.
ad_ip_instance xlconstant gt_line_rate [list \
  CONST_WIDTH 8 \
  CONST_VAL 0 \
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
# 9. GT serial breakout + status boundary ports.
##########################################################################
# The gt_rtl master interface Quad0_GT_Serial breaks out to discrete per-lane
# QUAD0_{txp,txn,rxp,rxn}[3:0] pins. For GTY the boolean p/n pins carry REAL data
# (the whole point of the GTM->GTY pivot), so system_tb.sv closes the loop with a
# PLAIN WIRE ALIAS -- no hierarchical *_integer force. Matches the reference
# exdes_tb, which loops gt_txp_out<->gt_rxp_in on a shared wire.
create_bd_port -dir O -from 3 -to 0 gt_txp
create_bd_port -dir O -from 3 -to 0 gt_txn
create_bd_port -dir I -from 3 -to 0 gt_rxp
create_bd_port -dir I -from 3 -to 0 gt_rxn
ad_connect gt_txp gtwiz_versal/QUAD0_txp
ad_connect gt_txn gtwiz_versal/QUAD0_txn
ad_connect gt_rxp gtwiz_versal/QUAD0_rxp
ad_connect gt_rxn gtwiz_versal/QUAD0_rxn

# GT status, observed by the test program to gate the register bring-up. The exdes
# gates on stat_mst_reset_done, which is exactly gt_rx_reset_done_out
# (exdes.sv:2056 assign stat_mst_reset_done = gt_rx_reset_done_out) -- so
# rx_reset_done here IS the reference's gate signal.
create_bd_port -dir O rx_reset_done
create_bd_port -dir O tx_reset_done
create_bd_port -dir O gtpowergood
ad_connect rx_reset_done gtwiz_versal/INTF0_rst_rx_done_out
ad_connect tx_reset_done gtwiz_versal/INTF0_rst_tx_done_out
ad_connect gtpowergood   gtwiz_versal/gtpowergood

# gtwiz Quad0_AXI_LITE (the GT register plane) is left open, exactly as the M1
# gtwiz de-risk TB did (validate rc=0) and as this loopback needs no GT register
# writes.

##########################################################################
# 10. Sweep any remaining undriven scalar gtwiz inputs to GND (M1 idiom).
#     Skips clocks, refclks, usrclks, already-driven pins, and interface members.
#     This is what ties QUAD0_ch{0..3}_loopback to 3'b000 = EXTERNAL loopback,
#     matching exdes_tb.v:324 .gt_loopback(3'b000).
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
  # gnd_pin_obj for the same name-collision reason as the other two sweeps. gtwiz
  # kept the blanket interface dict above (unlike the glue): its interfaces are real
  # declared ones that ARE interface-connected, matching the validated sibling.
  gnd_pin_obj $_pin
}

# Export the traffic shape to the test program so its counter-check expectations
# cannot drift from the RTL parameters (both come from the cfg).
adi_sim_add_define "GEN_NUM_PKTS=$NUM_PKTS"
adi_sim_add_define "GEN_PKT_BYTES=$PKT_BYTES"
adi_sim_add_define "GEN_STRIP_FCS=$STRIP_FCS"
