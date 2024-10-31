`include "utils.svh"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;
import m_axi_sequencer_pkg::*;
import m_axis_sequencer_pkg::*;
import environment_pkg::*;

//=============================================================================
// Register Maps
//=============================================================================

`define DO_ADDR_VERSION                 32'h00000
`define DO_ADDR_ID                      32'h00004
`define DO_ADDR_SCRATCH                 32'h00008
`define DO_ADDR_MAGIC                   32'h0000C
`define DO_ADDR_MEM_TYPE                32'h00010
`define DO_ADDR_MEM_SIZE_LSB            32'h00014
`define DO_ADDR_MEM_SIZE_MSB            32'h00018
`define DO_ADDR_TRANSFER_LENGTH         32'h0001C
`define DO_ADDR_DDR_CALIB_DONE          32'h00080
`define DO_ADDR_CONTROL_1               32'h00084
`define DO_ADDR_CONTROL_2               32'h00088
`define DO_ADDR_SYNC                    32'h00100
`define DO_ADDR_SYNC_CONFIG             32'h00104
`define DO_ADDR_DBG_FSM                 32'h00200
`define DO_ADDR_DBG_SMP_LSB_COUNTER     32'h00204
`define DO_ADDR_DBG_SMP_MSB_COUNTER     32'h00208

`define	DO_CORE_VERSION 			          32'h00000100
`define	DO_CORE_MAGIC   			          32'h44414F46

`define DMAC_ADDR_VERSION               32'h00000
`define DMAC_ADDR_ID                    32'h00004
`define DMAC_ADDR_SCRATCH               32'h00008
`define DMAC_ADDR_MAGIC                 32'h0000C
`define DMAC_ADDR_IRQMASK               32'h00080
`define DMAC_ADDR_IRQPEND               32'h00084
`define DMAC_ADDR_IRQSRC                32'h00088
`define DMAC_ADDR_CONTROL               32'h00400
`define DMAC_ADDR_TRANSFER_ID           32'h00404
`define DMAC_ADDR_TRANSFER_SUBMIT       32'h00408
`define DMAC_ADDR_FLAGS                 32'h0040c
`define DMAC_ADDR_DEST_ADDR             32'h00410
`define DMAC_ADDR_SRC_ADDR              32'h00414
`define DMAC_ADDR_X_LENGTH              32'h00418
`define DMAC_ADDR_Y_LENGTH              32'h0041C
`define DMAC_ADDR_DEST_STRIDE           32'h00420
`define DMAC_ADDR_SRC_STRIDE            32'h00424
`define DMAC_ADDR_TRANSFER_DONE         32'h00428
`define DMAC_ADDR_ACTIVE_TRNS_ID        32'h0042C
`define DMAC_ADDR_STATUS                32'h00430
`define DMAC_ADDR_CURRENT_DST_ADDR      32'h00434
`define DMAC_ADDR_CURRENT_SRC_ADDR      32'h00438
`define DMAC_ADDR_TRANSFER_PROGRESS     32'h00448
`define DMAC_ADDR_PARTIAL_TRNS_LENGTH   32'h0044C
`define DMAC_ADDR_PARTIAL_TRNS_ID       32'h00450
`define DMAC_ADDR_FRAME_LOCK_CONFIG     32'h00454
`define DMAC_ADDR_FRAME_LOCK_STRIDE     32'h00458

`define ADC_TRANSFER_LENGTH 32'h600

module test_program();

  //declaring environment instance
  environment env;
  xil_axi4stream_ready_gen_policy_t dac_mode;

  initial begin
    //creating environment
    env = new(`TH.`MNG_AXI.inst.IF,
              `TH.`DDR_AXI.inst.IF,
              `TH.`PLDDR_AXI.inst.IF,
              `TH.`ADC_SRC_AXIS.inst.IF,
              `TH.`DAC_DST_AXIS.inst.IF
             );

    //=========================================================================
    // Setup generator/monitor stubs
    //=========================================================================

    // ADC stub
    env.adc_src_axis_seq.set_data_gen_mode(DATA_GEN_MODE_AUTO_INCR);
    env.adc_src_axis_seq.add_xfer_descriptor(`ADC_TRANSFER_LENGTH, 0, 0);

    // DAC stub
    dac_mode = XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE;
    env.dac_dst_axis_seq.set_mode(dac_mode);

    //=========================================================================

    setLoggerVerbosity(250);
    
    `TH.`PLDDR_RST.inst.IF.assert_reset;
    #1;
    
    start_clocks();
    sys_reset();
          
    #1
    env.start();

    #100
    `INFO(("Bring up IP from reset."), ADI_VERBOSITY_DEBUG);
    systemBringUp();

    //do_set_transfer_length(`ADC_TRANSFER_LENGTH);
    do_set_transfer_length(`ADC_TRANSFER_LENGTH/64);

    // Start the ADC/DAC stubs
    `INFO(("Call the run() ..."), ADI_VERBOSITY_DEBUG);
    env.run();

    env.adc_src_axis_seq.start();

    // Generate DMA transfers
    #100
    `INFO(("Start RX DMA ..."), ADI_VERBOSITY_DEBUG);
    rx_dma_transfer(`RX_DMA_BA, 32'h80000000, `ADC_TRANSFER_LENGTH);

    #10000

    `INFO(("Initialize the memory ..."), ADI_VERBOSITY_DEBUG);
    init_mem_64(32'h80000000, 1024);

    `INFO(("Start TX DMA ..."), ADI_VERBOSITY_DEBUG);
    tx_dma_transfer(`TX_DMA_BA, 32'h80000000, 1024);

    #30000
    env.stop();

    stop_clocks();

    `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
    $finish();

  end

  task start_clocks();
    #1
    `TH.`SRC_CLK.inst.IF.start_clock;
    #1
    `TH.`DST_CLK.inst.IF.start_clock;
    #1
    `TH.`SYS_CLK.inst.IF.start_clock;
    #1
    `TH.`PLDDR_CLK.inst.IF.start_clock;
  endtask

  task stop_clocks();
    `TH.`SRC_CLK.inst.IF.stop_clock;
    `TH.`DST_CLK.inst.IF.stop_clock;
    `TH.`SYS_CLK.inst.IF.stop_clock;
    `TH.`PLDDR_CLK.inst.IF.stop_clock;
  endtask

  task sys_reset();
    `TH.`SRC_RST.inst.IF.assert_reset;
    `TH.`DST_RST.inst.IF.assert_reset;
    `TH.`SYS_RST.inst.IF.assert_reset;
    `TH.`PLDDR_RST.inst.IF.assert_reset;

    #500
    `TH.`SRC_RST.inst.IF.deassert_reset;
    `TH.`DST_RST.inst.IF.deassert_reset;
    `TH.`SYS_RST.inst.IF.deassert_reset;
    `TH.`PLDDR_RST.inst.IF.deassert_reset;
  endtask

  task systemBringUp();
    // bring up the Data Offload instances from reset

    `INFO(("Bring up RX Data Offload"), ADI_VERBOSITY_DEBUG);
    env.mng.RegWrite32(`RX_DOFF_BA + `DO_ADDR_CONTROL_1, 32'h1);
    `INFO(("Bring up TX Data Offload"), ADI_VERBOSITY_DEBUG);
    env.mng.RegWrite32(`TX_DOFF_BA + `DO_ADDR_CONTROL_1, 32'h1);

    // Enable tx oneshot mode
    env.mng.RegWrite32(`TX_DOFF_BA + `DO_ADDR_CONTROL_2, 32'b10);

    // bring up the DMAC instances from reset

    `INFO(("Bring up RX DMAC"), ADI_VERBOSITY_DEBUG);
    env.mng.RegWrite32(`RX_DMA_BA + `DMAC_ADDR_CONTROL, 32'h1);
    `INFO(("Bring up TX DMAC"), ADI_VERBOSITY_DEBUG);
    env.mng.RegWrite32(`TX_DMA_BA + `DMAC_ADDR_CONTROL, 32'h1);
  endtask

  task do_set_transfer_length(int length);
    env.mng.RegWrite32(`RX_DOFF_BA + `DO_ADDR_TRANSFER_LENGTH, length-1);
  endtask

  // RX DMA transfer generator

  task rx_dma_transfer(int dma_baseaddr, int xfer_addr, int xfer_length);
    env.mng.RegWrite32(dma_baseaddr + `DMAC_ADDR_FLAGS, 32'h6);
    env.mng.RegWrite32(dma_baseaddr + `DMAC_ADDR_DEST_ADDR, xfer_addr);
    env.mng.RegWrite32(dma_baseaddr + `DMAC_ADDR_X_LENGTH, xfer_length - 1);
    env.mng.RegWrite32(dma_baseaddr + `DMAC_ADDR_TRANSFER_SUBMIT, 32'h1);
  endtask

  task tx_dma_transfer(int dma_baseaddr, int xfer_addr, int xfer_length);
    env.mng.RegWrite32(dma_baseaddr + `DMAC_ADDR_FLAGS, 32'b010);               // enable TLAST, CYCLIC
    env.mng.RegWrite32(dma_baseaddr + `DMAC_ADDR_SRC_ADDR, xfer_addr);
    env.mng.RegWrite32(dma_baseaddr + `DMAC_ADDR_X_LENGTH, xfer_length - 1);
    env.mng.RegWrite32(dma_baseaddr + `DMAC_ADDR_TRANSFER_SUBMIT, 32'h1);
  endtask

  // Memory initialization function for a 8byte DATA_WIDTH AXI4 bus
  task init_mem_64(longint unsigned addr, int byte_length);
    for (int i=0; i<byte_length; i=i+8) begin
      env.ddr_agent.mem_model.backdoor_memory_write_4byte(addr + i*8, i, 255);
    end
  endtask

endmodule
