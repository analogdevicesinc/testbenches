`include "utils.svh"
`include "m_axi_sequencer.sv"
`include "environment.sv"

import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import logger_pkg::*;

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

`define GPIO_DATA                       32'h00000

`define TRANSFER_LENGTH 32'h600

module test_program();

  //declaring environment instance
  environment env;
  xil_axi4stream_ready_gen_policy_t dac_mode;

  initial begin
    //creating environment
    env = new(`TH.`MNG_AXI.inst.IF,
              `TH.`SRC_AXIS.inst.IF,
              `TH.`DST_AXIS.inst.IF
             );

    //=========================================================================
    // Setup generator/monitor stubs
    //=========================================================================

    // ADC stub
    env.src_axis_seq.configure(1, 0);
    for (int i = 0; i < 10; i++)
      env.src_axis_seq.update(`TRANSFER_LENGTH, 1, 0);
    
    env.src_axis_seq.enable();

    // DAC stub
    dac_mode = XIL_AXI4STREAM_READY_GEN_NO_BACKPRESSURE;
    env.dst_axis_seq.set_mode(dac_mode);

    //=========================================================================

    setLoggerVerbosity(250);

    start_clocks;
    sys_reset;

    #1
    env.start();

    #100
    `INFO(("Bring up IP from reset."));
    systemBringUp;

    //do_set_transfer_length(`TRANSFER_LENGTH);
    //do_set_transfer_length(`TRANSFER_LENGTH);

    // Start the ADC/DAC stubs
    `INFO(("Call the run() ..."));
    env.run();

    #30000
    env.stop();

    stop_clocks;

    `INFO(("Test bench done!"));
    $finish();

  end

  task start_clocks;

    #1
    `TH.`SRC_CLK.inst.IF.start_clock;
    #1
    `TH.`DST_CLK.inst.IF.start_clock;
    #1
    `TH.`SYS_CLK.inst.IF.start_clock;
  endtask

  task stop_clocks;

    `TH.`SRC_CLK.inst.IF.stop_clock;
    `TH.`DST_CLK.inst.IF.stop_clock;
    `TH.`SYS_CLK.inst.IF.stop_clock;
    
  endtask

  task sys_reset;

    `TH.`SRC_RST.inst.IF.assert_reset;
    `TH.`DST_RST.inst.IF.assert_reset;
    `TH.`SYS_RST.inst.IF.assert_reset;
    
    #500
    `TH.`SRC_RST.inst.IF.deassert_reset;
    `TH.`DST_RST.inst.IF.deassert_reset;
    `TH.`SYS_RST.inst.IF.deassert_reset;

  endtask

  task systemBringUp;

    // bring up the Data Offload instances from reset
    `INFO(("Bring up TX Data Offload"));
    env.mng.RegWrite32(`DOFF_BA + `DO_ADDR_CONTROL_1, 32'h1);

    // Enable tx oneshot mode
    env.mng.RegWrite32(`DOFF_BA + `DO_ADDR_CONTROL_2, 32'b10);
    
    // Enable GPIO
    env.mng.RegWrite32(`CTRL_GPIO_BA + `GPIO_DATA, 32'b1);

  endtask

  task do_set_transfer_length(int length);
    env.mng.RegWrite32(`DOFF_BA + `DO_ADDR_TRANSFER_LENGTH, length-1);
  endtask

endmodule
