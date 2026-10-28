// ***************************************************************************
// AD5529R Testbench - Single-Instruction Mode test program
//
// Thin wrapper: sets the TB-only parameters and pulls in the shared test flow
// (tests/ad5529r_test_flow.svh).
//
//   Single instruction: 1 word per transfer, 16 transfers (one per channel).
// ***************************************************************************

`include "utils.svh"

`define NUM_OF_WORDS     1
`define NUM_OF_TRANSFERS 16

program test_single_instruction (
  inout ad5529r_spi_irq,
  inout ad5529r_spi_clk,
  inout ad5529r_tg0,
  inout ad5529r_tg1,
  inout ad5529r_tg2,
  inout ad5529r_tg3);

  timeunit 1ns;
  timeprecision 1ps;

  typedef enum {DATA_MODE_RANDOM, DATA_MODE_RAMP} offload_test_t;
  // Test will loop for each mode below
  offload_test_t test_modes[$] = '{DATA_MODE_RAMP, DATA_MODE_RANDOM, DATA_MODE_RANDOM, DATA_MODE_RANDOM};

  `include "ad5529r_test_flow.svh"

endprogram
