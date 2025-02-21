// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2021 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsabilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
`include "utils.svh"

package adi_jesd204_pkg;

  import logger_pkg::*;
  import adi_peripheral_pkg::*;
  import reg_accessor_pkg::*;
  import adi_regmap_pkg::*;
  import adi_regmap_jesd_tx_pkg::*;
  import adi_regmap_jesd_rx_pkg::*;

  `define set_member(T, name) function set_``name (input T val); name = val; endfunction

  typedef enum bit [1:0] {sc0 = 0, sc1 = 1, sc2 = 2} subclass_t;
  typedef enum bit [1:0] {v204A = 0, v204B = 1, v204C = 2} version_t;
  typedef enum bit [0:0] {enc8b10b = 0, enc64b66b = 1} encoding_t;
  typedef enum bit [1:0] {ls_8b10b_init = 0, ls_8b10b_check = 1, ls_8b10b_data = 2} lanestate_8b10b_t;
  typedef enum bit [2:0] {ls_64b66b_emb_init = 1, ls_64b66b_emb_hunt = 2, ls_64b66b_emb_lock = 4} lanestate_64b66b_t;
  const string encoding_s [2] = {"8B10B", "64B66B"};
  const string rx_link_states_8b10b [4] = {"RESET", "WAIT_FOR_PHY", "CGS", "DATA"};
  const string rx_link_states_64b66b [4] = {"RESET", "WAIT_BS", "BLOCK_SYNC", "DATA"};
  const string tx_link_states_8b10b [4] = {"WAIT", "CGS", "ILAS", "DATA"};
  const string tx_link_states_64b66b [4] = {"RESET", "N/A", "N/A", "DATA"};

  const string rx_lane_states_8b10b [3] = {"INIT", "CHECK", "DATA"};
  const string rx_lane_states_64b66b [8] = { "UNUSED",
                                             "EMB_INIT",
                                             "EMB_HUNT",
                                             "UNUSED",
                                             "EMB_LOCK",
                                             "UNUSED",
                                             "UNUSED",
                                             "UNUSED"};

  //============================================================================
  // JESD 204C link class
  //============================================================================
  class jesd_link;

    subclass_t SUBCLASSV = sc1;
    version_t JESDV = v204C;
    encoding_t encoding = enc8b10b;
    real encoding_ratio = 10.0/8.0;
    bit SCR = 1;
    longint unsigned lane_rate;

    bit [7:0] L;      /* lanes_per_device               */
    bit [7:0] M;      /* converters_per_device          */
    bit [7:0] F;      /* octets_per_frame               */
    bit [7:0] S;      /* samples_per_converter_per_frame*/
    bit [9:0] K;      /* frames_per_multiframe          */
    bit [7:0] E;      /* multiblocks_in_extended_multiblock */
    bit [4:0] N;      /* converter_resolution           */
    bit [4:0] NP;     /* bits_per_sample                */
    bit [1:0] CS = 0; /* control_bits_per_sample        */
    bit [0:0] HD = 1; /* high_density                   */
    bit [3:0] CF = 0; /* control words per frame duration per link */

    // -----------------
    //
    // -----------------
    function set_encoding(encoding_t encoding);
      this.encoding = encoding;
      if (encoding == enc8b10b) begin
        this.encoding_ratio = 10.0/8.0;
      end else begin
        this.encoding_ratio = 66.0/64.0;
        // set E based on other paramters
        // K * F = E * 32 * 8
        set_E(K * F / 256);
       end
    endfunction

    // -----------------
    //
    // -----------------
    `set_member(int, L);
    `set_member(int, M);
    `set_member(int, F);
    `set_member(int, S);
    `set_member(int, K);
    `set_member(int, E);
    `set_member(int, N);
    `set_member(int, NP);
    `set_member(int, CS);
    `set_member(int, HD);
    `set_member(longint unsigned, lane_rate);

    // -----------------
    //
    // -----------------
    virtual function void print();
      `INFO(("--------------------------"), ADI_VERBOSITY_MEDIUM);
      `INFO(("--Link parameters---------"), ADI_VERBOSITY_MEDIUM);
      `INFO(("--------------------------"), ADI_VERBOSITY_MEDIUM);
      `INFO(("L         is %0d", L), ADI_VERBOSITY_MEDIUM);
      `INFO(("M         is %0d", M), ADI_VERBOSITY_MEDIUM);
      `INFO(("F         is %0d", F), ADI_VERBOSITY_MEDIUM);
      `INFO(("S         is %0d", S), ADI_VERBOSITY_MEDIUM);
      `INFO(("K         is %0d", K), ADI_VERBOSITY_MEDIUM);
      `INFO(("E         is %0d", E), ADI_VERBOSITY_MEDIUM);
      `INFO(("N         is %0d", N), ADI_VERBOSITY_MEDIUM);
      `INFO(("N'        is %0d", NP), ADI_VERBOSITY_MEDIUM);
      `INFO(("CS        is %0d", CS), ADI_VERBOSITY_MEDIUM);
      `INFO(("HD        is %0d", HD), ADI_VERBOSITY_MEDIUM);
      `INFO(("SCR       is %0d", SCR), ADI_VERBOSITY_MEDIUM);
      `INFO(("SUBCLASSV is %0d", SUBCLASSV), ADI_VERBOSITY_MEDIUM);
      `INFO(("ENCODING  is %s", encoding_s[encoding]), ADI_VERBOSITY_MEDIUM);
    endfunction

    // -----------------
    //
    // -----------------
    function int check_config();
      // 8 * F * L = M * N' * S
      if (8 * F * L != M * NP * S) begin
        `FATAL(("Configuration mismatch. 8 * F * L != M * N' * S"));
        return 1;
      end
      return 0;
    endfunction

    // -----------------
    //
    // -----------------
    function bit[7:0] calc_checksum(int LID);
      bit [7:0] val;
      val = (LID +
             L - 1 +
             SCR +
             F - 1 +
             K - 1 +
             M - 1 +
             N - 1 +
             CS +
             NP - 1 +
             SUBCLASSV +
             S - 1 +
             JESDV +
             CF +
             HD);
      return val;
    endfunction

  endclass : jesd_link

  //============================================================================
  // Base Link layer class
  //============================================================================
  class link_layer extends adi_peripheral;

    jesd_link link;
    int dp_width = 4;  // Data width towards Phy
    int tpl_dp_width = 4;  // Data width towards Transport Layer
    int num_links = 1;

    int unsigned link_clk;
    int unsigned device_clk;
    real sysref_clk;
    real sysref_clk_fract;

    // -----------------
    //
    // -----------------
    function new (string name, reg_accessor bus, bit [31:0] base_address, jesd_link link);

      super.new(name, bus, base_address);
      this.link = link;

    endfunction

    // -----------------
    //
    // -----------------
    function set_link(jesd_link link);
      this.link = link;
    endfunction : set_link

    // -----------------
    //
    // -----------------
    // Discover Hw capabilities
    task discover_capabs();
      bit [31:0] val;
      // Use Rx regs here since this is common also with Tx
      this.bus.RegRead32(this.base_address + GetAddrs(JESD_RX_SYNTH_DATA_PATH_WIDTH), val);
      tpl_dp_width = `GET_JESD_RX_SYNTH_DATA_PATH_WIDTH_TPL_DATA_PATH_WIDTH(val);
      dp_width = 2**`GET_JESD_RX_SYNTH_DATA_PATH_WIDTH_SYNTH_DATA_PATH_WIDTH(val);
      this.bus.RegRead32(this.base_address + GetAddrs(JESD_RX_SYNTH_REG_1), val);
      num_links = `GET_JESD_RX_SYNTH_REG_1_NUM_LINKS(val);
    endtask : discover_capabs

    // -----------------
    //
    // -----------------
    task probe ();
      super.probe();
      link.print();
      link.check_config();
      discover_capabs();
    endtask : probe

    // -----------------
    //
    // -----------------
    function int unsigned calc_link_clk();
      link_clk = link.lane_rate/(dp_width * 8 * link.encoding_ratio);
      return link_clk;
    endfunction : calc_link_clk

    // -----------------
    //
    // -----------------
    function int unsigned calc_device_clk();
      if (link_clk == 0) calc_link_clk;
      device_clk = link_clk * dp_width / tpl_dp_width;
      return device_clk;
    endfunction : calc_device_clk

    // -----------------
    //
    // -----------------
    function real calc_sysref_clk();
      if (link_clk == 0) calc_link_clk;
      sysref_clk = link_clk * dp_width / (link.K * link.F);
      sysref_clk_fract = sysref_clk - $floor(sysref_clk);
      if (sysref_clk_fract != 0)
        this.error($sformatf("Current clock generator can't generate this exact frequency: %f", sysref_clk));
      return sysref_clk;
    endfunction : calc_sysref_clk;

  endclass : link_layer

  //============================================================================
  // Rx Link layer class
  //============================================================================
  class rx_link_layer extends link_layer;

    // -----------------
    //
    // -----------------
    function new (string name, reg_accessor bus, bit [31:0] base_address, jesd_link link);
      super.new(name, bus, base_address, link);
    endfunction

    // -----------------
    //
    // -----------------
    task link_up();

      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_RX_LINK_DISABLE),
                          `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));

      //SYSREFCONF
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_RX_SYSREF_CONF),
                         `SET_JESD_RX_SYSREF_CONF_SYSREF_DISABLE(link.SUBCLASSV != sc1));

      //CONF0
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_RX_LINK_CONF0),
                         `SET_JESD_RX_LINK_CONF0_OCTETS_PER_FRAME(link.F - 1) |
                         `SET_JESD_RX_LINK_CONF0_OCTETS_PER_MULTIFRAME(link.F * link.K - 1));
      //CONF4
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_RX_LINK_CONF4),
                         `SET_JESD_RX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((link.F * link.K) / tpl_dp_width - 1));
      //CONF1
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_RX_LINK_CONF1),
                         `SET_JESD_RX_LINK_CONF1_DESCRAMBLER_DISABLE(link.SCR == 0));

      //LINK ENABLE
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_RX_LINK_DISABLE),
                          `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(0));

    endtask : link_up

    // -----------------
    //
    // -----------------
    task wait_link_up();
      bit [31:0] val;
      int timeout = 30;
      bit [1:0] link_state;
      bit [2:0] lane_state;
      bit all_lanes_in_data = 1'b0;
      // wait until link and all lanes are in DATA
      while ((link_state != 3 || all_lanes_in_data == 1'b0) && timeout > 0) begin
        #1us;
        this.bus.RegRead32(this.base_address + GetAddrs(JESD_RX_LINK_STATUS), val);
        link_state = `GET_JESD_RX_LINK_STATUS_STATUS_STATE(val);
        // Read lane state
        all_lanes_in_data = 1;
        for (int i = 0; i < link.L; i++) begin
          this.bus.RegRead32(this.base_address + i * 'h20 + GetAddrs(JESD_RX_LANEn_STATUS), val);
          if (link.encoding == enc8b10b) begin
            lane_state = `GET_JESD_RX_LANEn_STATUS_CGS_STATE(val);
            if (lane_state != ls_8b10b_data)
              all_lanes_in_data = 0;
          end else begin
            lane_state = `GET_JESD_RX_LANEn_STATUS_EMB_STATE(val);
            if (lane_state != ls_64b66b_emb_lock)
              all_lanes_in_data = 0;
          end
        end
        // timeout--;
      end

      link_verify();
    endtask : wait_link_up

    // -----------------
    //
    // -----------------
    task link_down();
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_RX_LINK_DISABLE),
                          `SET_JESD_RX_LINK_DISABLE_LINK_DISABLE(1));
    endtask : link_down

    // -----------------
    //
    // -----------------
    task link_verify();
      bit [31:0] val;
      bit [2:0] lane_state;

      link_status_print();

      this.bus.RegReadVerify32(this.base_address + GetAddrs(JESD_RX_LINK_STATUS),
                              `SET_JESD_RX_LINK_STATUS_STATUS_STATE(3));

      // Check SYSREF alignment ERROR
      this.bus.RegReadVerify32(this.base_address + GetAddrs(JESD_RX_SYSREF_STATUS),
                               `SET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(0) |
                               `SET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(link.SUBCLASSV == sc1));
      // Check lane status
      for (int i = 0; i < link.L; i++) begin
        this.bus.RegRead32(this.base_address + i * 'h20 + GetAddrs(JESD_RX_LANEn_STATUS), val);
        if (link.encoding == enc8b10b) begin
          lane_state = `GET_JESD_RX_LANEn_STATUS_CGS_STATE(val);
          if (lane_state != ls_8b10b_data)
            this.error($sformatf("Lane %d state %s",i,rx_lane_states_8b10b[i]));
        end else begin
          lane_state = `GET_JESD_RX_LANEn_STATUS_EMB_STATE(val);
          if (lane_state != ls_64b66b_emb_lock)
            this.error($sformatf("Lane %d state %s",i,rx_lane_states_64b66b[i]));
        end
      end

      // Check received ILAS
      if (link.encoding == enc8b10b) begin
        for (int i = 0; i < link.L; i++) begin
          this.bus.RegReadVerify32(this.base_address + i * 'h20 + GetAddrs(JESD_TX_LANEn_ILAS1),
                                   `SET_JESD_RX_LANEn_ILAS1_LID(i) |
                                   `SET_JESD_RX_LANEn_ILAS1_L(link.L - 1) |
                                   `SET_JESD_RX_LANEn_ILAS1_SCR(link.SCR) |
                                   `SET_JESD_RX_LANEn_ILAS1_F(link.F - 1) |
                                   `SET_JESD_RX_LANEn_ILAS1_K(link.K - 1));
          this.bus.RegReadVerify32(this.base_address + i * 'h20 + GetAddrs(JESD_TX_LANEn_ILAS2),
                                   `SET_JESD_RX_LANEn_ILAS2_M(link.M - 1) |
                                   `SET_JESD_RX_LANEn_ILAS2_N(link.N - 1) |
                                   `SET_JESD_RX_LANEn_ILAS2_CS(link.CS) |
                                   `SET_JESD_RX_LANEn_ILAS2_NP(link.NP - 1) |
                                   `SET_JESD_RX_LANEn_ILAS2_SUBCLASSV(link.SUBCLASSV) |
                                   `SET_JESD_RX_LANEn_ILAS2_S(link.S - 1) |
                                   `SET_JESD_RX_LANEn_ILAS2_JESDV(link.JESDV));
          this.bus.RegReadVerify32(this.base_address + i * 'h20 + GetAddrs(JESD_TX_LANEn_ILAS3),
                                   `SET_JESD_RX_LANEn_ILAS3_CF(link.CF) |
                                   `SET_JESD_RX_LANEn_ILAS3_HD(link.HD) |
                                   `SET_JESD_RX_LANEn_ILAS3_FCHK(link.calc_checksum(i)));
        end
      end

    endtask : link_verify

    // -----------------
    //
    // -----------------
    task link_status_print();
      bit [31:0] val;
      this.bus.RegRead32(this.base_address + GetAddrs(JESD_RX_LINK_STATUS), val);
      if (link.encoding == enc8b10b) begin
        this.info($sformatf("Link status : %s", rx_link_states_8b10b[`GET_JESD_RX_LINK_STATUS_STATUS_STATE(val)]), ADI_VERBOSITY_MEDIUM);
      end else begin
        this.info($sformatf("Link status : %s", rx_link_states_64b66b[`GET_JESD_RX_LINK_STATUS_STATUS_STATE(val)]), ADI_VERBOSITY_MEDIUM);
      end

      // Check SYSREF alignment ERROR
      this.bus.RegRead32(this.base_address + GetAddrs(JESD_RX_SYSREF_STATUS), val);
      this.info($sformatf("SYSREF captured : %s", `GET_JESD_RX_SYSREF_STATUS_SYSREF_DETECTED(val) ? "Yes" : "No"), ADI_VERBOSITY_MEDIUM);
      this.info($sformatf("SYSREF alignment error : %s", `GET_JESD_RX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(val) ? "Yes" : "No"), ADI_VERBOSITY_MEDIUM);

    endtask : link_status_print

  endclass : rx_link_layer

  //============================================================================
  // Tx Link layer class
  //============================================================================
  class tx_link_layer extends link_layer;

    // -----------------
    //
    // -----------------
    function new (string name, reg_accessor bus, bit [31:0] base_address, jesd_link link);
      super.new(name, bus, base_address, link);
    endfunction

    // -----------------
    //
    // -----------------
    task link_up();

      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_TX_LINK_DISABLE),
                          `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));

      //SYSREFCONF
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_TX_SYSREF_CONF),
                         `SET_JESD_TX_SYSREF_CONF_SYSREF_DISABLE(link.SUBCLASSV != sc1));

      //CONF0
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_TX_LINK_CONF0),
                         `SET_JESD_TX_LINK_CONF0_OCTETS_PER_FRAME(link.F - 1) |
                         `SET_JESD_TX_LINK_CONF0_OCTETS_PER_MULTIFRAME(link.F * link.K - 1));
      //CONF4
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_TX_LINK_CONF4),
                         `SET_JESD_TX_LINK_CONF4_TPL_BEATS_PER_MULTIFRAME((link.F * link.K) / tpl_dp_width - 1));
      //CONF1
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_TX_LINK_CONF1),
                         `SET_JESD_TX_LINK_CONF1_SCRAMBLER_DISABLE(link.SCR == 0));

      //ILAS
      if (link.encoding == enc8b10b) begin
        for (int i = 0; i < link.L; i++) begin
          this.bus.RegWrite32(this.base_address + i * 'h20 + GetAddrs(JESD_TX_LANEn_ILAS1),
                             `SET_JESD_TX_LANEn_ILAS1_LID(i) |
                             `SET_JESD_TX_LANEn_ILAS1_L(link.L - 1) |
                             `SET_JESD_TX_LANEn_ILAS1_SCR(link.SCR) |
                             `SET_JESD_TX_LANEn_ILAS1_F(link.F - 1) |
                             `SET_JESD_TX_LANEn_ILAS1_K(link.K - 1));
          this.bus.RegWrite32(this.base_address + i * 'h20 + GetAddrs(JESD_TX_LANEn_ILAS2),
                             `SET_JESD_TX_LANEn_ILAS2_M(link.M - 1) |
                             `SET_JESD_TX_LANEn_ILAS2_N(link.N - 1) |
                             `SET_JESD_TX_LANEn_ILAS2_CS(link.CS) |
                             `SET_JESD_TX_LANEn_ILAS2_NP(link.NP - 1) |
                             `SET_JESD_TX_LANEn_ILAS2_SUBCLASSV(link.SUBCLASSV) |
                             `SET_JESD_TX_LANEn_ILAS2_S(link.S - 1) |
                             `SET_JESD_TX_LANEn_ILAS2_JESDV(link.JESDV));
          this.bus.RegWrite32(this.base_address + i * 'h20 + GetAddrs(JESD_TX_LANEn_ILAS3),
                             `SET_JESD_TX_LANEn_ILAS3_CF(link.CF) |
                             `SET_JESD_TX_LANEn_ILAS3_HD(link.HD) |
                             `SET_JESD_TX_LANEn_ILAS3_FCHK(link.calc_checksum(i)));
        end

      end

      //LINK ENABLE
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_TX_LINK_DISABLE),
                          `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(0));

    endtask : link_up

    // -----------------
    //
    // -----------------
    task wait_link_up();
      bit [31:0] val;
      int timeout = 20;
      bit [1:0] link_state;
      // wait until link is not in DATA
      while (link_state!=3 && timeout > 0) begin
        #1us;
        this.bus.RegRead32(this.base_address + GetAddrs(JESD_TX_LINK_STATUS), val);
        link_state = `GET_JESD_TX_LINK_STATUS_STATUS_STATE(val);
        timeout--;
      end

      link_verify();
    endtask : wait_link_up

    // -----------------
    //
    // -----------------
    task link_down();
      this.bus.RegWrite32(this.base_address + GetAddrs(JESD_TX_LINK_DISABLE),
                          `SET_JESD_TX_LINK_DISABLE_LINK_DISABLE(1));
    endtask : link_down

    // -----------------
    //
    // -----------------
    task link_verify();

      bit [7:0] status_sync = 8'h00;

      link_status_print();

      for (int i=0; i<num_links; i++) begin
        if (link.encoding == enc8b10b) begin
          status_sync = status_sync << 1;
          status_sync = status_sync | 1'b1;
        end
      end

      // There is no SYNC signal in 64b66b
      this.bus.RegReadVerify32(this.base_address + GetAddrs(JESD_TX_LINK_STATUS),
                               `SET_JESD_TX_LINK_STATUS_STATUS_SYNC(status_sync) |
                               `SET_JESD_TX_LINK_STATUS_STATUS_STATE(3));
      // Check SYSREF alignment ERROR
      this.bus.RegReadVerify32(this.base_address + GetAddrs(JESD_TX_SYSREF_STATUS),
                               `SET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(0) |
                               `SET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(link.SUBCLASSV == sc1));
    endtask : link_verify

    // -----------------
    //
    // -----------------
    task link_status_print();
      bit [31:0] val;
      // There is no SYNC signal in 64b66b
      this.bus.RegRead32(this.base_address + GetAddrs(JESD_TX_LINK_STATUS), val);
      if (link.encoding == enc8b10b) begin
        this.info($sformatf("Link status : %s", tx_link_states_8b10b[`GET_JESD_TX_LINK_STATUS_STATUS_STATE(val)]), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("SYNC~ : %s", `SET_JESD_TX_LINK_STATUS_STATUS_SYNC(val) ? "deasserted" : "asserted"), ADI_VERBOSITY_MEDIUM);
      end else begin
        this.info($sformatf("Link status %s", tx_link_states_64b66b[`GET_JESD_TX_LINK_STATUS_STATUS_STATE(val)]), ADI_VERBOSITY_MEDIUM);
      end

      // Check SYSREF alignment ERROR
      this.bus.RegRead32(this.base_address + GetAddrs(JESD_TX_SYSREF_STATUS), val);
      this.info($sformatf("SYSREF captured : %s", `GET_JESD_TX_SYSREF_STATUS_SYSREF_DETECTED(val) ? "Yes" : "No"), ADI_VERBOSITY_MEDIUM);
      this.info($sformatf("SYSREF alignment error : %s", `GET_JESD_TX_SYSREF_STATUS_SYSREF_ALIGNMENT_ERROR(val) ? "Yes" : "No"), ADI_VERBOSITY_MEDIUM);

    endtask : link_status_print

  endclass : tx_link_layer

endpackage

