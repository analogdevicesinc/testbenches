// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2025 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`include "utils.svh"

package scoreboard_object_pkg;

  import logger_pkg::*;
  import adi_common_pkg::*;
  import scoreboard_pkg::*;
  import adi_datatypes_pkg::*;

  class scoreboard_object extends scoreboard#(.data_type(adi_datatype));

    function new(
      string name,
      adi_component parent = null);
      super.new(name, parent);
    endfunction: new

    virtual function void compare_transaction();
      adi_datatype source_transaction;
      adi_datatype sink_transaction;

      this.info($sformatf("scoreboard_object compare_transaction"), ADI_VERBOSITY_MEDIUM);

      if (this.enabled == 0) begin
        this.info($sformatf("skipping compare_transaction (not enabled)"), ADI_VERBOSITY_MEDIUM);
        return;
      end

      while ((this.subscriber_source.get_size() > 0) &&
            (this.subscriber_sink.get_size() > 0)) begin
        this.info($sformatf("subscriber_source size=%0d, subscriber_sink size=%0d",this.subscriber_source.get_size(),this.subscriber_sink.get_size()), ADI_VERBOSITY_MEDIUM);
        byte_streams_empty_sig = 0;
        source_transaction = this.subscriber_source.get_data();
        this.info($sformatf("source_transaction: %p", source_transaction), ADI_VERBOSITY_MEDIUM);
        if (this.sink_type == CYCLIC)
          this.subscriber_source.put_data(source_transaction);
        sink_transaction = this.subscriber_sink.get_data();
        this.info($sformatf("sink_transaction: %p", sink_transaction), ADI_VERBOSITY_MEDIUM);
        this.info($sformatf("Source-sink data: exp %s - rcv %s", source_transaction.to_string(), sink_transaction.to_string()), ADI_VERBOSITY_MEDIUM);
        // compare transactions with "deep" object comparison
        if (!source_transaction.compare(sink_transaction)) begin
          this.error($sformatf("Failed at: exp %s - rcv %s", source_transaction.to_string(), sink_transaction.to_string()));
        end
      end

      if ((this.subscriber_source.get_size() == 0) &&
          (this.subscriber_sink.get_size() == 0)) begin
        this.info($sformatf("byte_streams_empty_sig"), ADI_VERBOSITY_MEDIUM);
        this.byte_streams_empty_sig = 1;
        ->this.byte_streams_empty;
      end
       this.info($sformatf("scoreboard_object compare_transaction END"), ADI_VERBOSITY_MEDIUM);
    endfunction: compare_transaction

  endclass

endpackage
