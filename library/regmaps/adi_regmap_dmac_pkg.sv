// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2014 - 2025 Analog Devices, Inc. All rights reserved.
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
//      https://github.com/analogdevicesinc/hdl/blob/main/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************
/* Auto generated Register Map */
/* Jan 28 13:30:16 2025 v0.3.55 */

package adi_regmap_dmac_pkg;
  import logger_pkg::*;
  import adi_api_pkg::*;

  class adi_regmap_dmac extends adi_regmap;

    /* DMA Controller (axi_dmac) */
    class VERSION_CLASS extends register_base;
      field_base VERSION_MAJOR_F;
      field_base VERSION_MINOR_F;
      field_base VERSION_PATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.VERSION_MAJOR_F = new("VERSION_MAJOR", 31, 16, RO, 'h4, this);
        this.VERSION_MINOR_F = new("VERSION_MINOR", 15, 8, RO, 'h5, this);
        this.VERSION_PATCH_F = new("VERSION_PATCH", 7, 0, RO, 'h64, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: VERSION_CLASS

    class PERIPHERAL_ID_CLASS extends register_base;
      field_base PERIPHERAL_ID_F;

      function new(
        input string name,
        input int address,
        input int ID,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PERIPHERAL_ID_F = new("PERIPHERAL_ID", 31, 0, RO, ID, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PERIPHERAL_ID_CLASS

    class SCRATCH_CLASS extends register_base;
      field_base SCRATCH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SCRATCH_F = new("SCRATCH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SCRATCH_CLASS

    class IDENTIFICATION_CLASS extends register_base;
      field_base IDENTIFICATION_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.IDENTIFICATION_F = new("IDENTIFICATION", 31, 0, RO, 'h444d4143, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IDENTIFICATION_CLASS

    class INTERFACE_DESCRIPTION_1_CLASS extends register_base;
      field_base BYTES_PER_BEAT_DEST_LOG2_F;
      field_base DMA_TYPE_DEST_F;
      field_base BYTES_PER_BEAT_SRC_LOG2_F;
      field_base DMA_TYPE_SRC_F;
      field_base BYTES_PER_BURST_WIDTH_F;
      field_base AUTORUN_F;
      field_base USE_EXT_SYNC_F;
      field_base DMA_2D_TLAST_MODE_F;
      field_base MAX_NUM_FRAMES_F;

      function new(
        input string name,
        input int address,
        input int AUTORUN,
        input int BYTES_PER_BURST_WIDTH,
        input int DMA_2D_TLAST_MODE,
        input int DMA_DATA_WIDTH_DEST,
        input int DMA_DATA_WIDTH_SRC,
        input int DMA_TYPE_DEST,
        input int DMA_TYPE_SRC,
        input int MAX_NUM_FRAMES,
        input int USE_EXT_SYNC,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.BYTES_PER_BEAT_DEST_LOG2_F = new("BYTES_PER_BEAT_DEST_LOG2", 3, 0, RO, $clog2(DMA_DATA_WIDTH_DEST/8), this);
        this.DMA_TYPE_DEST_F = new("DMA_TYPE_DEST", 5, 4, RO, DMA_TYPE_DEST, this);
        this.BYTES_PER_BEAT_SRC_LOG2_F = new("BYTES_PER_BEAT_SRC_LOG2", 11, 8, RO, $clog2(DMA_DATA_WIDTH_SRC/8), this);
        this.DMA_TYPE_SRC_F = new("DMA_TYPE_SRC", 13, 12, RO, DMA_TYPE_SRC, this);
        this.BYTES_PER_BURST_WIDTH_F = new("BYTES_PER_BURST_WIDTH", 19, 16, RO, BYTES_PER_BURST_WIDTH, this);
        this.AUTORUN_F = new("AUTORUN", 24, 24, RO, AUTORUN, this);
        this.USE_EXT_SYNC_F = new("USE_EXT_SYNC", 25, 25, RO, USE_EXT_SYNC, this);
        this.DMA_2D_TLAST_MODE_F = new("DMA_2D_TLAST_MODE", 26, 26, RO, DMA_2D_TLAST_MODE, this);
        this.MAX_NUM_FRAMES_F = new("MAX_NUM_FRAMES", 31, 27, RO, MAX_NUM_FRAMES, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: INTERFACE_DESCRIPTION_1_CLASS

    class INTERFACE_DESCRIPTION_2_CLASS extends register_base;
      field_base CACHE_COHERENT_F;
      field_base AXI_AXCACHE_F;
      field_base AXI_AXPROT_F;

      function new(
        input string name,
        input int address,
        input int AXI_AXCACHE,
        input int AXI_AXPROT,
        input int CACHE_COHERENT,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CACHE_COHERENT_F = new("CACHE_COHERENT", 0, 0, RO, CACHE_COHERENT, this);
        this.AXI_AXCACHE_F = new("AXI_AXCACHE", 7, 4, RO, AXI_AXCACHE, this);
        this.AXI_AXPROT_F = new("AXI_AXPROT", 10, 8, RO, AXI_AXPROT, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: INTERFACE_DESCRIPTION_2_CLASS

    class IRQ_MASK_CLASS extends register_base;
      field_base TRANSFER_COMPLETED_F;
      field_base TRANSFER_QUEUED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRANSFER_COMPLETED_F = new("TRANSFER_COMPLETED", 1, 1, RW, 'h1, this);
        this.TRANSFER_QUEUED_F = new("TRANSFER_QUEUED", 0, 0, RW, 'h1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_MASK_CLASS

    class IRQ_PENDING_CLASS extends register_base;
      field_base TRANSFER_COMPLETED_F;
      field_base TRANSFER_QUEUED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRANSFER_COMPLETED_F = new("TRANSFER_COMPLETED", 1, 1, RW1C, 'h0, this);
        this.TRANSFER_QUEUED_F = new("TRANSFER_QUEUED", 0, 0, RW1C, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_PENDING_CLASS

    class IRQ_SOURCE_CLASS extends register_base;
      field_base TRANSFER_COMPLETED_F;
      field_base TRANSFER_QUEUED_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRANSFER_COMPLETED_F = new("TRANSFER_COMPLETED", 1, 1, RO, 'h0, this);
        this.TRANSFER_QUEUED_F = new("TRANSFER_QUEUED", 0, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: IRQ_SOURCE_CLASS

    class CONTROL_CLASS extends register_base;
      field_base FRAMELOCK_F;
      field_base HWDESC_F;
      field_base PAUSE_F;
      field_base ENABLE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.FRAMELOCK_F = new("FRAMELOCK", 3, 3, RW, 'h0, this);
        this.HWDESC_F = new("HWDESC", 2, 2, RW, 'h0, this);
        this.PAUSE_F = new("PAUSE", 1, 1, RW, 'h0, this);
        this.ENABLE_F = new("ENABLE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CONTROL_CLASS

    class TRANSFER_ID_CLASS extends register_base;
      field_base TRANSFER_ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRANSFER_ID_F = new("TRANSFER_ID", 1, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRANSFER_ID_CLASS

    class TRANSFER_SUBMIT_CLASS extends register_base;
      field_base TRANSFER_SUBMIT_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRANSFER_SUBMIT_F = new("TRANSFER_SUBMIT", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRANSFER_SUBMIT_CLASS

    class FLAGS_CLASS extends register_base;
      field_base CYCLIC_F;
      field_base TLAST_F;
      field_base PARTIAL_REPORTING_EN_F;

      function new(
        input string name,
        input int address,
        input int CYCLIC,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CYCLIC_F = new("CYCLIC", 0, 0, RW, CYCLIC, this);
        this.TLAST_F = new("TLAST", 1, 1, RW, 'h1, this);
        this.PARTIAL_REPORTING_EN_F = new("PARTIAL_REPORTING_EN", 2, 2, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FLAGS_CLASS

    class DEST_ADDRESS_CLASS extends register_base;
      field_base DEST_ADDRESS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DEST_ADDRESS_F = new("DEST_ADDRESS", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DEST_ADDRESS_CLASS

    class SRC_ADDRESS_CLASS extends register_base;
      field_base SRC_ADDRESS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SRC_ADDRESS_F = new("SRC_ADDRESS", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SRC_ADDRESS_CLASS

    class X_LENGTH_CLASS extends register_base;
      field_base X_LENGTH_F;

      function new(
        input string name,
        input int address,
        input int DMA_DATA_WIDTH_DEST,
        input int DMA_DATA_WIDTH_SRC,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.X_LENGTH_F = new("X_LENGTH", 31, 0, RW, 2**$clog2(`MAX(DMA_DATA_WIDTH_SRC, DMA_DATA_WIDTH_DEST)/8)-1, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: X_LENGTH_CLASS

    class Y_LENGTH_CLASS extends register_base;
      field_base Y_LENGTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.Y_LENGTH_F = new("Y_LENGTH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: Y_LENGTH_CLASS

    class DEST_STRIDE_CLASS extends register_base;
      field_base DEST_STRIDE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DEST_STRIDE_F = new("DEST_STRIDE", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DEST_STRIDE_CLASS

    class SRC_STRIDE_CLASS extends register_base;
      field_base SRC_STRIDE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SRC_STRIDE_F = new("SRC_STRIDE", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SRC_STRIDE_CLASS

    class TRANSFER_DONE_CLASS extends register_base;
      field_base TRANSFER_0_DONE_F;
      field_base TRANSFER_1_DONE_F;
      field_base TRANSFER_2_DONE_F;
      field_base TRANSFER_3_DONE_F;
      field_base PARTIAL_TRANSFER_DONE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRANSFER_0_DONE_F = new("TRANSFER_0_DONE", 0, 0, RO, 'h0, this);
        this.TRANSFER_1_DONE_F = new("TRANSFER_1_DONE", 1, 1, RO, 'h0, this);
        this.TRANSFER_2_DONE_F = new("TRANSFER_2_DONE", 2, 2, RO, 'h0, this);
        this.TRANSFER_3_DONE_F = new("TRANSFER_3_DONE", 3, 3, RO, 'h0, this);
        this.PARTIAL_TRANSFER_DONE_F = new("PARTIAL_TRANSFER_DONE", 31, 31, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRANSFER_DONE_CLASS

    class ACTIVE_TRANSFER_ID_CLASS extends register_base;
      field_base ACTIVE_TRANSFER_ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.ACTIVE_TRANSFER_ID_F = new("ACTIVE_TRANSFER_ID", 4, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: ACTIVE_TRANSFER_ID_CLASS

    class STATUS_CLASS extends register_base;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);


        this.initialization_done = 1;
      endfunction: new
    endclass: STATUS_CLASS

    class CURRENT_DEST_ADDRESS_CLASS extends register_base;
      field_base CURRENT_DEST_ADDRESS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CURRENT_DEST_ADDRESS_F = new("CURRENT_DEST_ADDRESS", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CURRENT_DEST_ADDRESS_CLASS

    class CURRENT_SRC_ADDRESS_CLASS extends register_base;
      field_base CURRENT_SRC_ADDRESS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CURRENT_SRC_ADDRESS_F = new("CURRENT_SRC_ADDRESS", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CURRENT_SRC_ADDRESS_CLASS

    class TRANSFER_PROGRESS_CLASS extends register_base;
      field_base TRANSFER_PROGRESS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.TRANSFER_PROGRESS_F = new("TRANSFER_PROGRESS", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: TRANSFER_PROGRESS_CLASS

    class PARTIAL_TRANSFER_LENGTH_CLASS extends register_base;
      field_base PARTIAL_LENGTH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PARTIAL_LENGTH_F = new("PARTIAL_LENGTH", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PARTIAL_TRANSFER_LENGTH_CLASS

    class PARTIAL_TRANSFER_ID_CLASS extends register_base;
      field_base PARTIAL_TRANSFER_ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.PARTIAL_TRANSFER_ID_F = new("PARTIAL_TRANSFER_ID", 1, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: PARTIAL_TRANSFER_ID_CLASS

    class DESCRIPTOR_ID_CLASS extends register_base;
      field_base DESCRIPTOR_ID_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DESCRIPTOR_ID_F = new("DESCRIPTOR_ID", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DESCRIPTOR_ID_CLASS

    class FRAMELOCK_CONFIG_CLASS extends register_base;
      field_base DISTANCE_F;
      field_base FRAMENUM_F;
      field_base WAIT_WRITER_F;
      field_base MODE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DISTANCE_F = new("DISTANCE", 23, 16, RW, 'h0, this);
        this.FRAMENUM_F = new("FRAMENUM", 15, 8, RW, 'h0, this);
        this.WAIT_WRITER_F = new("WAIT_WRITER", 1, 1, RW, 'h0, this);
        this.MODE_F = new("MODE", 0, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FRAMELOCK_CONFIG_CLASS

    class FRAMELOCK_STRIDE_CLASS extends register_base;
      field_base STRIDE_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.STRIDE_F = new("STRIDE", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: FRAMELOCK_STRIDE_CLASS

    class SG_ADDRESS_CLASS extends register_base;
      field_base SG_ADDRESS_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SG_ADDRESS_F = new("SG_ADDRESS", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SG_ADDRESS_CLASS

    class DEST_ADDRESS_HIGH_CLASS extends register_base;
      field_base DEST_ADDRESS_HIGH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.DEST_ADDRESS_HIGH_F = new("DEST_ADDRESS_HIGH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: DEST_ADDRESS_HIGH_CLASS

    class SRC_ADDRESS_HIGH_CLASS extends register_base;
      field_base SRC_ADDRESS_HIGH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SRC_ADDRESS_HIGH_F = new("SRC_ADDRESS_HIGH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SRC_ADDRESS_HIGH_CLASS

    class CURRENT_DEST_ADDRESS_HIGH_CLASS extends register_base;
      field_base CURRENT_DEST_ADDRESS_HIGH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CURRENT_DEST_ADDRESS_HIGH_F = new("CURRENT_DEST_ADDRESS_HIGH", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CURRENT_DEST_ADDRESS_HIGH_CLASS

    class CURRENT_SRC_ADDRESS_HIGH_CLASS extends register_base;
      field_base CURRENT_SRC_ADDRESS_HIGH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.CURRENT_SRC_ADDRESS_HIGH_F = new("CURRENT_SRC_ADDRESS_HIGH", 31, 0, RO, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: CURRENT_SRC_ADDRESS_HIGH_CLASS

    class SG_ADDRESS_HIGH_CLASS extends register_base;
      field_base SG_ADDRESS_HIGH_F;

      function new(
        input string name,
        input int address,
        input adi_regmap parent = null);

        super.new(name, address, parent);

        this.SG_ADDRESS_HIGH_F = new("SG_ADDRESS_HIGH", 31, 0, RW, 'h0, this);

        this.initialization_done = 1;
      endfunction: new
    endclass: SG_ADDRESS_HIGH_CLASS

    VERSION_CLASS VERSION_R;
    PERIPHERAL_ID_CLASS PERIPHERAL_ID_R;
    SCRATCH_CLASS SCRATCH_R;
    IDENTIFICATION_CLASS IDENTIFICATION_R;
    INTERFACE_DESCRIPTION_1_CLASS INTERFACE_DESCRIPTION_1_R;
    INTERFACE_DESCRIPTION_2_CLASS INTERFACE_DESCRIPTION_2_R;
    IRQ_MASK_CLASS IRQ_MASK_R;
    IRQ_PENDING_CLASS IRQ_PENDING_R;
    IRQ_SOURCE_CLASS IRQ_SOURCE_R;
    CONTROL_CLASS CONTROL_R;
    TRANSFER_ID_CLASS TRANSFER_ID_R;
    TRANSFER_SUBMIT_CLASS TRANSFER_SUBMIT_R;
    FLAGS_CLASS FLAGS_R;
    DEST_ADDRESS_CLASS DEST_ADDRESS_R;
    SRC_ADDRESS_CLASS SRC_ADDRESS_R;
    X_LENGTH_CLASS X_LENGTH_R;
    Y_LENGTH_CLASS Y_LENGTH_R;
    DEST_STRIDE_CLASS DEST_STRIDE_R;
    SRC_STRIDE_CLASS SRC_STRIDE_R;
    TRANSFER_DONE_CLASS TRANSFER_DONE_R;
    ACTIVE_TRANSFER_ID_CLASS ACTIVE_TRANSFER_ID_R;
    STATUS_CLASS STATUS_R;
    CURRENT_DEST_ADDRESS_CLASS CURRENT_DEST_ADDRESS_R;
    CURRENT_SRC_ADDRESS_CLASS CURRENT_SRC_ADDRESS_R;
    TRANSFER_PROGRESS_CLASS TRANSFER_PROGRESS_R;
    PARTIAL_TRANSFER_LENGTH_CLASS PARTIAL_TRANSFER_LENGTH_R;
    PARTIAL_TRANSFER_ID_CLASS PARTIAL_TRANSFER_ID_R;
    DESCRIPTOR_ID_CLASS DESCRIPTOR_ID_R;
    FRAMELOCK_CONFIG_CLASS FRAMELOCK_CONFIG_R;
    FRAMELOCK_STRIDE_CLASS FRAMELOCK_STRIDE_R;
    SG_ADDRESS_CLASS SG_ADDRESS_R;
    DEST_ADDRESS_HIGH_CLASS DEST_ADDRESS_HIGH_R;
    SRC_ADDRESS_HIGH_CLASS SRC_ADDRESS_HIGH_R;
    CURRENT_DEST_ADDRESS_HIGH_CLASS CURRENT_DEST_ADDRESS_HIGH_R;
    CURRENT_SRC_ADDRESS_HIGH_CLASS CURRENT_SRC_ADDRESS_HIGH_R;
    SG_ADDRESS_HIGH_CLASS SG_ADDRESS_HIGH_R;

    function new(
      input string name,
      input int address,
      input int AUTORUN,
      input int AXI_AXCACHE,
      input int AXI_AXPROT,
      input int BYTES_PER_BURST_WIDTH,
      input int CACHE_COHERENT,
      input int CYCLIC,
      input int DMA_2D_TLAST_MODE,
      input int DMA_DATA_WIDTH_DEST,
      input int DMA_DATA_WIDTH_SRC,
      input int DMA_TYPE_DEST,
      input int DMA_TYPE_SRC,
      input int ID,
      input int MAX_NUM_FRAMES,
      input int USE_EXT_SYNC,
      input adi_api parent = null);

      super.new(name, address, parent);

      this.VERSION_R = new("VERSION", 'h0, this);
      this.PERIPHERAL_ID_R = new("PERIPHERAL_ID", 'h4, ID, this);
      this.SCRATCH_R = new("SCRATCH", 'h8, this);
      this.IDENTIFICATION_R = new("IDENTIFICATION", 'hc, this);
      this.INTERFACE_DESCRIPTION_1_R = new("INTERFACE_DESCRIPTION_1", 'h10, AUTORUN, BYTES_PER_BURST_WIDTH, DMA_2D_TLAST_MODE, DMA_DATA_WIDTH_DEST, DMA_DATA_WIDTH_SRC, DMA_TYPE_DEST, DMA_TYPE_SRC, MAX_NUM_FRAMES, USE_EXT_SYNC, this);
      this.INTERFACE_DESCRIPTION_2_R = new("INTERFACE_DESCRIPTION_2", 'h14, AXI_AXCACHE, AXI_AXPROT, CACHE_COHERENT, this);
      this.IRQ_MASK_R = new("IRQ_MASK", 'h80, this);
      this.IRQ_PENDING_R = new("IRQ_PENDING", 'h84, this);
      this.IRQ_SOURCE_R = new("IRQ_SOURCE", 'h88, this);
      this.CONTROL_R = new("CONTROL", 'h400, this);
      this.TRANSFER_ID_R = new("TRANSFER_ID", 'h404, this);
      this.TRANSFER_SUBMIT_R = new("TRANSFER_SUBMIT", 'h408, this);
      this.FLAGS_R = new("FLAGS", 'h40c, CYCLIC, this);
      this.DEST_ADDRESS_R = new("DEST_ADDRESS", 'h410, this);
      this.SRC_ADDRESS_R = new("SRC_ADDRESS", 'h414, this);
      this.X_LENGTH_R = new("X_LENGTH", 'h418, DMA_DATA_WIDTH_DEST, DMA_DATA_WIDTH_SRC, this);
      this.Y_LENGTH_R = new("Y_LENGTH", 'h41c, this);
      this.DEST_STRIDE_R = new("DEST_STRIDE", 'h420, this);
      this.SRC_STRIDE_R = new("SRC_STRIDE", 'h424, this);
      this.TRANSFER_DONE_R = new("TRANSFER_DONE", 'h428, this);
      this.ACTIVE_TRANSFER_ID_R = new("ACTIVE_TRANSFER_ID", 'h42c, this);
      this.STATUS_R = new("STATUS", 'h430, this);
      this.CURRENT_DEST_ADDRESS_R = new("CURRENT_DEST_ADDRESS", 'h434, this);
      this.CURRENT_SRC_ADDRESS_R = new("CURRENT_SRC_ADDRESS", 'h438, this);
      this.TRANSFER_PROGRESS_R = new("TRANSFER_PROGRESS", 'h448, this);
      this.PARTIAL_TRANSFER_LENGTH_R = new("PARTIAL_TRANSFER_LENGTH", 'h44c, this);
      this.PARTIAL_TRANSFER_ID_R = new("PARTIAL_TRANSFER_ID", 'h450, this);
      this.DESCRIPTOR_ID_R = new("DESCRIPTOR_ID", 'h454, this);
      this.FRAMELOCK_CONFIG_R = new("FRAMELOCK_CONFIG", 'h458, this);
      this.FRAMELOCK_STRIDE_R = new("FRAMELOCK_STRIDE", 'h45c, this);
      this.SG_ADDRESS_R = new("SG_ADDRESS", 'h47c, this);
      this.DEST_ADDRESS_HIGH_R = new("DEST_ADDRESS_HIGH", 'h490, this);
      this.SRC_ADDRESS_HIGH_R = new("SRC_ADDRESS_HIGH", 'h494, this);
      this.CURRENT_DEST_ADDRESS_HIGH_R = new("CURRENT_DEST_ADDRESS_HIGH", 'h498, this);
      this.CURRENT_SRC_ADDRESS_HIGH_R = new("CURRENT_SRC_ADDRESS_HIGH", 'h49c, this);
      this.SG_ADDRESS_HIGH_R = new("SG_ADDRESS_HIGH", 'h4bc, this);

      this.info($sformatf("Initialized"), ADI_VERBOSITY_HIGH);
    endfunction: new

  endclass: adi_regmap_dmac

endpackage: adi_regmap_dmac_pkg
