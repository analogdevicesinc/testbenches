// ***************************************************************************
// ***************************************************************************
// Copyright (C) 2026 Analog Devices, Inc. All rights reserved.
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

import logger_pkg::*;
import watchdog_pkg::*;
import test_harness_env_pkg::*;
import adi_axi_agent_pkg::*;
import m_axi_sequencer_pkg::*;
import axi_vip_pkg::*;
import axi4stream_vip_pkg::*;
import adi_regmap_pkg::*;
import adi_regmap_clkgen_pkg::*;
import adi_regmap_dmac_pkg::*;
import adi_regmap_pwm_gen_pkg::*;
import adi_regmap_spi_engine_pkg::*;
import spi_engine_instr_pkg::*;
import adi_spi_vip_pkg::*;

import `PKGIFY(test_harness, mng_axi_vip)::*;
import `PKGIFY(test_harness, ddr_axi_vip)::*;

// Shared test flow body. Not compiled standalone: `included by a `program`
// wrapper (tests/test_*.sv) that supplies the ports and `NUM_OF_WORDS /
// `NUM_OF_TRANSFERS.

wire spi_sclk = `TH.`SPI_S.inst.IF.s_sclk;
wire spi_cs   = `TH.`SPI_S.inst.IF.s_cs;
wire spi_mosi = `TH.`SPI_S.inst.IF.s_mosi;
wire spi_miso = `TH.`SPI_S.inst.IF.s_miso;

// Toggle/trigger pins TG0-TG3
localparam int NUM_TG = 4;

// `DDR_BA is injected as the bare decimal 2147483648 (0x8000_0000), which
// overflows a 32-bit signed int (VRFC 10-9277). Hold the DDR base in a wide
// unsigned param so address arithmetic stays warning-free and correct.
localparam longint unsigned DDR_BASE_ADDR = 64'd`DDR_BA;

test_harness_env base_env;

adi_axi_master_agent #(`AXI_VIP_PARAMS(test_harness, mng_axi_vip)) mng;
adi_axi_slave_mem_agent #(`AXI_VIP_PARAMS(test_harness, ddr_axi_vip)) ddr;
adi_spi_agent spi_env;

// Shorthand handle for the sequencers (set in the main initial block)
m_axi_sequencer_base mSeq;
adi_spi_sequencer spiSeq;

// Toggle pin edge counters (one per channel, free-running)
int tg_edges[NUM_TG] = '{default:0};
wire [NUM_TG-1:0] tg_bus = {ad5529r_tg3, ad5529r_tg2, ad5529r_tg1, ad5529r_tg0};

// Pass/fail gate; only verify_* tasks increment it.
int total_error_count = 0;

// IRQ state (declared here so reset_dut_state, defined above the IRQ callback
// block, can reference them). Driven by the IRQ callback below.
reg [4:0] irq_pending = 0;
reg [7:0] sync_id = 0;
int offload_transfer_cnt = 0;

// SCLK timing measurement
time sclk_rise_time;
time sclk_prev_rise;
int sclk_period_count;
real sclk_period_sum;
bit sclk_measurement_enabled;

// CS timing measurement
time cs_fall_time;
time first_sclk_rise_after_cs;
time last_sclk_fall_before_cs_rise;
bit cs_measurement_enabled;

// Min/max timing across all transactions
real cs_setup_min;
real cs_setup_max;
real cs_hold_min;
real cs_hold_max;
int cs_timing_samples;

// Throughput Measurement
localparam int PROGRESS_REPORTER_PERCENT = 2;  // report progress every 2% of transfers

// Gate + cadence counters for tput_monitor (program scope: the monitor touches
// them before the meter handle exists)
bit tput_enabled;          // count transfers only while a run is active
int tput_print_interval;   // print a partial line every N transfers (= 2%)
int tput_until_print;      // countdown to next partial print

// Throughput accounting. One transfer = one CS cycle updating
// channels_per_transfer channels; per-channel kSPS = aggregate / channels_per_transfer.
class throughput_meter;
  int  channels_per_transfer;
  int  total_transfers;          // transfers seen by the monitor this run
  int  total_transfers_target;   // expected transfers (for the progress %)
  int  total_updates;            // = total_transfers * channels_per_transfer
  time run_start_time;           // start_measure() timestamp
  time run_end_time;             // end_measure() timestamp
  // open checkpoint window baseline + last closed window's rate
  int  ckpt_base_updates;
  time ckpt_base_time;
  real ckpt_window_ksps;
  // measured throughput, read after the run
  real measured_ksps_all_channels;
  real measured_ksps_per_channel;

  function new(int channels_per_transfer, int total_transfers_target);
    this.channels_per_transfer  = channels_per_transfer;
    this.total_transfers_target = total_transfers_target;
    clear();
  endfunction

  // Zero accumulators and re-stamp baselines to now (offload start or TB reset).
  function void clear();
    total_transfers            = 0;
    total_updates              = 0;
    run_start_time             = $time;
    run_end_time               = 0;
    ckpt_base_updates          = 0;
    ckpt_base_time             = $time;
    ckpt_window_ksps           = 0;
    measured_ksps_all_channels = 0;
    measured_ksps_per_channel  = 0;
  endfunction

  // rate = samples_seen / (end - start). The window includes software/AXI
  // overhead (offload-enable latency, flush/settle) on purpose: it dilutes over
  // many transfers, giving an honest end-to-end rate. The count is whatever the
  // CS-rise monitor saw; completeness is checked separately against the VIP RX
  // mailbox in run_verification_suite.
  function void start_measure();
    clear();
  endfunction

  function void end_measure();
    run_end_time = $time;
  endfunction

  function void record_transfer();
    total_transfers++;
    total_updates += channels_per_transfer;
  endfunction

  // Close the current window (compute its rate) and open a fresh one at now.
  // Call right before a partial print_status().
  function void checkpoint();
    real dur_us = real'($time - ckpt_base_time) / 1000.0;
    ckpt_window_ksps  = (dur_us > 0) ? real'(total_updates - ckpt_base_updates) * 1000.0 / dur_us : 0;
    ckpt_base_updates = total_updates;
    ckpt_base_time    = $time;
  endfunction

  // Aggregate kSPS -> per-channel kSPS (== transfer rate).
  function real per_channel(real all_channel_ksps);
    return (channels_per_transfer > 0) ? all_channel_ksps / real'(channels_per_transfer) : 0;
  endfunction

  function void print_header();
    `INFO((""), ADI_VERBOSITY_LOW);
    `INFO(("    Throughput: [pct|FINAL] | Dur(ms) | Transfers | Updates | Global kSPS (per-ch) | Window kSPS (per-ch)"), ADI_VERBOSITY_LOW);
  endfunction

  // Update measured_* fields and print one row: global + last-checkpoint window.
  // For the FINAL line, measure across the explicitly bracketed window
  // [run_start_time, run_end_time]; for partial lines (window still open) measure
  // up to now.
  function void print_status(bit is_final);
    time   end_t        = (is_final && run_end_time != 0) ? run_end_time : $time;
    real   total_dur_us = real'(end_t - run_start_time) / 1000.0;
    real progress_pct = (total_transfers_target > 0)
                      ? real'(total_transfers) * 100.0 / real'(total_transfers_target) : 0;
    string prefix = is_final ? "[FINAL]" : $sformatf("[%5.1f%%]", progress_pct);

    // updates/µs * 1000 = kSPS (kilosamples per second)
    measured_ksps_all_channels = (total_dur_us > 0) ? real'(total_updates) * 1000.0 / total_dur_us : 0;
    measured_ksps_per_channel  = per_channel(measured_ksps_all_channels);

    `INFO(("    %s | %8.3f ms | %9d | %7d | %8.3f kSPS (%7.3f /ch) | %8.3f kSPS (%7.3f /ch)",
           prefix, total_dur_us / 1000.0, total_transfers, total_updates,
           measured_ksps_all_channels, measured_ksps_per_channel,
           ckpt_window_ksps, per_channel(ckpt_window_ksps)),
          ADI_VERBOSITY_LOW);
  endfunction
endclass

throughput_meter tput_meter;

// PWM timing measurement
time tg_rise_times[NUM_TG][$];
time tg_fall_times[NUM_TG][$];
bit pwm_measurement_enabled = 0;

// Main procedure
initial begin
  setLoggerVerbosity(ADI_VERBOSITY_LOW);

  init_environment();

  `INFO(("=== AD5529R Testbench Started ==="), ADI_VERBOSITY_LOW);
  `INFO(("  Configuration: NUM_OF_WORDS=%0d, NUM_OF_TRANSFERS=%0d", `NUM_OF_WORDS, `NUM_OF_TRANSFERS), ADI_VERBOSITY_LOW);
  sanity_test();
  wait_random(
    .min_ns(50),
    .max_ns(150)
  );

  // Initialize all measurement state and enable the timing monitors.
  reset_measurements();

  foreach (test_modes[idx]) begin
    run_offload_test(test_modes[idx]);
    if (idx < test_modes.size() - 1) begin
      reset_dut_state();
    end
  end

  wait_random(
    .min_ns(50),
    .max_ns(150)
  );

  test_toggle_pins();

  spi_env.stop();
  base_env.stop();

  if (total_error_count > 0) begin
    `FATAL(("Test terminated with %0d errors", total_error_count));
  end

  `INFO(("Test bench done!"), ADI_VERBOSITY_NONE);
  $finish();

end

task automatic run_verification_suite();
  // Completeness check against ground truth (ungated VIP RX mailbox), not the
  // gated throughput meter. One mailbox entry per word; a complete run =
  // NUM_OF_TRANSFERS * NUM_OF_WORDS words.
  begin
    int expected_words = `NUM_OF_TRANSFERS * `NUM_OF_WORDS;
    int actual_words   = spiSeq.get_num_rx_data();
    if (actual_words != expected_words) begin
      `ERROR(("rx words (%0d) != expected (%0d) - were transfers lost?", actual_words, expected_words));
      total_error_count++;
    end
  end
  // Expected: 35 MHz with 5% tolerance
  verify_sclk_frequency(
    .expected_freq_mhz(35.0),
    .tolerance_pct(5.0)
  );
  // AD5529R requires: t5 (setup) >= 8ns, t6 (hold) >= 8ns
  verify_cs_timing(
    .min_cs_setup_ns(8.0),
    .min_cs_hold_ns(8.0)
  );
  `INFO(("Verifying IRQ..."), ADI_VERBOSITY_LOW);
  verify_irq_was_raised();
  `INFO(("Comparing transmitted SPI data against expected..."), ADI_VERBOSITY_LOW);
  // Verify every expected word, independent of the gated meter count.
  verify_received_data(.word_cnt(`NUM_OF_TRANSFERS * `NUM_OF_WORDS), .error_cnt(total_error_count));
endtask

task wait_random(
  input int min_ns,
  input int max_ns
);
  int delay_ns;
  delay_ns = $urandom_range(max_ns, min_ns);
  #(delay_ns * 1ns);
endtask

// Reset DUT state between test cases.
task reset_dut_state();
  `INFO(("reset_dut_state: Resetting DUT state..."), ADI_VERBOSITY_LOW);
  // Disable offload first
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), 0);
  // Let pending SPI transactions drain
  // TODO WAIT: size this delay properly.
  wait_random(
    .min_ns(400),
    .max_ns(600)
  );
  // Reset offload command memory (required before re-programming offload)
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_MEM_RESET), 1);
  // Clear all pending IRQs
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), 'hFF);
  // Disable DMA; tests re-enable and configure it
  mSeq.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_CONTROL), 0);
  // Empty the SPI VIP queues so a leftover RX entry can't shift the next test's
  // data by one (verify_received_data drains only as many words as were counted).
  spiSeq.clear_send();
  spiSeq.clear_receive();
  offload_transfer_cnt = 0;
  irq_pending = 0;
  // Reset SCLK running state, keep cumulative counters
  sclk_rise_time = 0;
  sclk_prev_rise = 0;
  wait_random(
    .min_ns(50),
    .max_ns(150)
  );
  `INFO(("reset_dut_state: DUT state reset complete"), ADI_VERBOSITY_LOW);
endtask

// Initialize all measurement state once at start of run: assign defaults,
// construct the throughput meter, arm the tput_monitor cadence, enable monitors.
task reset_measurements();
  // SCLK timing
  sclk_rise_time = 0;
  sclk_prev_rise = 0;
  sclk_period_count = 0;
  sclk_period_sum = 0;
  sclk_measurement_enabled = 1;

  // CS timing
  cs_fall_time = 0;
  first_sclk_rise_after_cs = 0;
  last_sclk_fall_before_cs_rise = 0;
  cs_setup_min = 1e9;
  cs_setup_max = 0;
  cs_hold_min = 1e9;
  cs_hold_max = 0;
  cs_timing_samples = 0;
  cs_measurement_enabled = 1;

  // Throughput: construct the meter and arm the tput_monitor cadence.
  // Streaming-mode: NUM_OF_WORDS = 1 stream instr + channels,
  //                 so channels_per_transfer = NUM_OF_WORDS - 1
  // Single-instruction: channels_per_transfer = 1.
  tput_enabled = 0;
  tput_meter = new(
    .channels_per_transfer((`NUM_OF_WORDS > 1) ? `NUM_OF_WORDS - 1 : 1),
    .total_transfers_target(`NUM_OF_TRANSFERS)
  );
  tput_print_interval = (`NUM_OF_TRANSFERS * PROGRESS_REPORTER_PERCENT) / 100;
  if (tput_print_interval < 1) tput_print_interval = 1;  // floor at 1 transfer
  tput_until_print = tput_print_interval;
endtask

task verify_sclk_frequency(
  input real expected_freq_mhz,
  input real tolerance_pct
);
  real avg_period_ns;
  real actual_freq_mhz;
  real deviation_pct;

  sclk_measurement_enabled = 0;

  if (sclk_period_count == 0) begin
    `ERROR(("[SCLK] No SCLK edges detected - cannot verify frequency"));
    total_error_count++;
    return;
  end

  avg_period_ns = sclk_period_sum / real'(sclk_period_count);
  actual_freq_mhz = 1000.0 / avg_period_ns;  // ns to MHz conversion
  deviation_pct = ((actual_freq_mhz - expected_freq_mhz) / expected_freq_mhz) * 100.0;

  `INFO((""), ADI_VERBOSITY_LOW);
  `INFO(("=== SCLK Frequency Verification ==="), ADI_VERBOSITY_LOW);
  `INFO(("  SCLK edges measured: %0d", sclk_period_count), ADI_VERBOSITY_LOW);
  `INFO(("  Average period:      %.2f ns", avg_period_ns), ADI_VERBOSITY_LOW);
  `INFO(("  Actual frequency:    %.2f MHz", actual_freq_mhz), ADI_VERBOSITY_LOW);
  `INFO(("  Expected frequency:  %.2f MHz", expected_freq_mhz), ADI_VERBOSITY_LOW);
  `INFO(("  Deviation:           %.2f%%", deviation_pct), ADI_VERBOSITY_LOW);

  if (deviation_pct < 0) deviation_pct = -deviation_pct;  // abs

  if (deviation_pct > tolerance_pct) begin
    if (deviation_pct > tolerance_pct * 5) begin
      `ERROR(("[SCLK] Frequency deviation %.2f%% far exceeds tolerance %.2f%% - possible clock misconfiguration", deviation_pct, tolerance_pct));
      total_error_count++;
    end else begin
      `WARNING(("[SCLK] Frequency deviation %.2f%% exceeds tolerance %.2f%% (simulation clock may differ from hardware)", deviation_pct, tolerance_pct));
    end
  end
endtask

// CS Timing Verification
task verify_cs_timing(
  input real min_cs_setup_ns,  // t5: CS fall to first SCLK rise
  input real min_cs_hold_ns    // t6: last SCLK fall to CS rise
);
  cs_measurement_enabled = 0;

  `INFO((""), ADI_VERBOSITY_LOW);
  `INFO(("=== CS Timing Verification ==="), ADI_VERBOSITY_LOW);

  if (cs_timing_samples == 0) begin
    `WARNING(("[CS] No complete CS transactions captured for timing analysis"));
    return;
  end

  `INFO(("  Transactions measured: %0d", cs_timing_samples), ADI_VERBOSITY_LOW);
  `INFO(("  CS setup (t5):  min=%.2f ns, max=%.2f ns (required: >= %.2f ns)",
         cs_setup_min, cs_setup_max, min_cs_setup_ns), ADI_VERBOSITY_LOW);

  if (cs_setup_min < min_cs_setup_ns) begin
    `ERROR(("[CS] Setup time violation: %.2f ns < %.2f ns minimum", cs_setup_min, min_cs_setup_ns));
    total_error_count++;
  end

  if (cs_hold_min < 1e9) begin
    `INFO(("  CS hold (t6):   min=%.2f ns, max=%.2f ns (required: >= %.2f ns)",
           cs_hold_min, cs_hold_max, min_cs_hold_ns), ADI_VERBOSITY_LOW);

    if (cs_hold_min < min_cs_hold_ns) begin
      `ERROR(("[CS] Hold time violation: %.2f ns < %.2f ns minimum", cs_hold_min, min_cs_hold_ns));
      total_error_count++;
    end
  end else begin
    `INFO(("  CS hold (t6):   Not measured"), ADI_VERBOSITY_LOW);
  end
endtask

// PWM Frequency and Duty Cycle Verification
task reset_pwm_measurement();
  foreach (tg_rise_times[ch]) begin
    tg_rise_times[ch].delete();
    tg_fall_times[ch].delete();
  end
  pwm_measurement_enabled = 1;
endtask

task automatic verify_pwm_timing(
  input int channel,
  input real expected_freq_mhz,
  input real freq_tolerance_pct,
  input real expected_duty_pct,
  input real duty_tolerance_pct
);
  time rise_times[$];
  time fall_times[$];
  real total_period = 0;
  real total_high_time = 0;
  int period_count = 0;
  real avg_period_ns, actual_freq_mhz, avg_duty_pct;
  real freq_deviation, duty_deviation;

  // Select channel data
  rise_times = tg_rise_times[channel];
  fall_times = tg_fall_times[channel];

  if (rise_times.size() < 2) begin
    `ERROR(("[PWM] TG%0d: Insufficient rise edges (%0d) for timing measurement", channel, rise_times.size()));
    total_error_count++;
    return;
  end

  // Calculate periods from consecutive rises
  for (int i = 1; i < rise_times.size(); i++) begin
    total_period += real'(rise_times[i] - rise_times[i-1]);
    period_count++;
  end

  // Calculate duty cycle from rise-to-fall times
  for (int i = 0; i < rise_times.size() && i < fall_times.size(); i++) begin
    if (fall_times[i] > rise_times[i]) begin
      total_high_time += real'(fall_times[i] - rise_times[i]);
    end
  end

  avg_period_ns = total_period / real'(period_count);
  actual_freq_mhz = 1000.0 / avg_period_ns;

  if (period_count > 0) begin
    avg_duty_pct = (total_high_time / total_period) * 100.0;
  end else begin
    avg_duty_pct = 0;
  end

  freq_deviation = ((actual_freq_mhz - expected_freq_mhz) / expected_freq_mhz) * 100.0;
  duty_deviation = avg_duty_pct - expected_duty_pct;

  `INFO(("  TG%0d: Freq=%.2f MHz (exp: %.2f), Duty=%.1f%% (exp: %.1f%%)",
         channel, actual_freq_mhz, expected_freq_mhz, avg_duty_pct, expected_duty_pct), ADI_VERBOSITY_LOW);

  // Check frequency
  if (freq_deviation < 0) freq_deviation = -freq_deviation;
  if (freq_deviation > freq_tolerance_pct) begin
    `ERROR(("[PWM] TG%0d: Frequency deviation %.2f%% exceeds tolerance %.2f%%",
            channel, freq_deviation, freq_tolerance_pct));
    total_error_count++;
  end

  // Check duty cycle
  if (duty_deviation < 0) duty_deviation = -duty_deviation;
  if (duty_deviation > duty_tolerance_pct) begin
    `ERROR(("[PWM] TG%0d: Duty cycle deviation %.1f%% exceeds tolerance %.1f%%",
            channel, duty_deviation, duty_tolerance_pct));
    total_error_count++;
  end
endtask

// TG edge monitor: wake on any tg_bus change, diff vs previous to find which
// channel(s) toggled and the direction; capture timestamps when measuring.
initial begin
  static logic [NUM_TG-1:0] tg_prev = '0;
  forever begin
    @(tg_bus);
    for (int ch = 0; ch < NUM_TG; ch++) begin
      if (tg_bus[ch] !== tg_prev[ch]) begin
        tg_edges[ch]++;
        if (pwm_measurement_enabled) begin
          if (tg_bus[ch]) tg_rise_times[ch].push_back($time);
          else            tg_fall_times[ch].push_back($time);
        end
      end
    end
    tg_prev = tg_bus;
  end
end

// SCLK period measurement
initial begin
  forever begin
    @(posedge spi_sclk);
    if (sclk_measurement_enabled) begin
      sclk_prev_rise = sclk_rise_time;
      sclk_rise_time = $time;
      if (sclk_prev_rise != 0) begin
        sclk_period_sum += real'(sclk_rise_time - sclk_prev_rise);
        sclk_period_count++;
      end
    end
  end
end

// CS timing measurement
initial begin
  forever begin
    @(negedge spi_cs);  // CS falls (active low)
    cs_fall_time = $time;
    first_sclk_rise_after_cs = 0;
    last_sclk_fall_before_cs_rise = 0;
  end
end

initial begin : sclk_measurement_rst
  forever begin
    @(posedge spi_cs);  // CS rises (inactive)
    // Zero both so the CS-high gap is not counted as a period (sclk_rise_time
    // becomes sclk_prev_rise on the next edge).
    sclk_rise_time = 0;
    sclk_prev_rise = 0;
  end
end

// CS setup/hold timing min/max capture
initial begin : cs_setup_hold_timing
  forever begin
    @(posedge spi_cs);
    // Capture CS timing min/max on each complete transaction
    if (cs_measurement_enabled && first_sclk_rise_after_cs != 0 && cs_fall_time != 0) begin
      automatic real t_setup = real'(first_sclk_rise_after_cs - cs_fall_time);
      automatic real t_hold = real'($time - last_sclk_fall_before_cs_rise);
      // Update min/max setup time
      if (t_setup < cs_setup_min) cs_setup_min = t_setup;
      if (t_setup > cs_setup_max) cs_setup_max = t_setup;
      // Update min/max hold time (only if valid)
      if (last_sclk_fall_before_cs_rise != 0) begin
        if (t_hold < cs_hold_min) cs_hold_min = t_hold;
        if (t_hold > cs_hold_max) cs_hold_max = t_hold;
      end

      cs_timing_samples++;
    end
  end
end

// Throughput monitor: one CS rise == one completed transfer. Record it and,
// every PROGRESS_REPORTER_PERCENT of the target, print a partial line.
// (run_spi_engine_offload prints the final line via the same meter.)
initial begin : tput_monitor
  forever begin
    @(posedge spi_cs);  // CS rises (inactive) -> one transfer completed
    if (tput_enabled && tput_meter != null) begin
      tput_meter.record_transfer();
      if (--tput_until_print <= 0) begin
        tput_meter.checkpoint();
        tput_meter.print_status(.is_final(0));
        tput_until_print = tput_print_interval;  // reload countdown
      end
    end
  end
end

// Track first SCLK rise after CS falls for setup time measurement
initial begin
  forever begin
    @(posedge spi_sclk);
    if (cs_measurement_enabled && !spi_cs && first_sclk_rise_after_cs == 0) begin
      first_sclk_rise_after_cs = $time;
    end
  end
end

// Track last SCLK fall before CS rises for hold time measurement
initial begin
  forever begin
    @(negedge spi_sclk);
    if (cs_measurement_enabled && !spi_cs) begin
      last_sclk_fall_before_cs_rise = $time;
    end
  end
end

// Build/start the environments, grab sequencer handles, reset, arm the watchdog.
task automatic init_environment();
  int transfer_timeout_ns = 100_000_000;
  base_env = new(
    .name("Base Environment"),
    .sys_clk_vip_if(`TH.`SYS_CLK.inst.IF),
    .dma_clk_vip_if(`TH.`DMA_CLK.inst.IF),
    .ddr_clk_vip_if(`TH.`DDR_CLK.inst.IF),
    .sys_rst_vip_if(`TH.`SYS_RST.inst.IF),
    .irq_base_address(`IRQ_C_BA),
    .irq_vip_if(`TH.`IRQ.inst.inst.IF.vif)
  );

  mng = new("", `TH.`MNG_AXI.inst.IF);
  ddr = new("", `TH.`DDR_AXI.inst.IF);
  `LINK(mng, base_env, mng)
  `LINK(ddr, base_env, ddr)
  spi_env = new("SPI VIP Agent", `TH.`SPI_S.inst.IF.vif);
  // Sequencer shorthands
  mSeq = base_env.mng.master_sequencer;
  spiSeq = spi_env.sequencer;
  base_env.start();
  spi_env.start();

  spiSeq.set_default_miso_data('h0);
  base_env.sys_reset();

  // TODO: derive timeout from transfer size: N*M*X / 35 MHz, +130% margin.
  base_env.simulation_watchdog.update_timer(transfer_timeout_ns);
  base_env.simulation_watchdog.reset();
  `INFO(("    Watchdog set to %0d ms", transfer_timeout_ns / 1000000), ADI_VERBOSITY_LOW);
endtask

// Check SPI Engine version + scratch register.
task automatic sanity_test();
  bit [31:0] pcore_version = (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_PATCH)
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MINOR)<<8
                            | (`DEFAULT_AXI_SPI_ENGINE_VERSION_VERSION_MAJOR)<<16;
  `INFO(("Sanity Test: Checking SPI Engine version and scratch register"), ADI_VERBOSITY_LOW);
  mSeq.RegReadVerify32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_VERSION), pcore_version);
  mSeq.RegWrite32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  mSeq.RegReadVerify32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SCRATCH), 32'hDEADBEEF);
  `INFO(("Sanity Test PASSED"), ADI_VERBOSITY_LOW);
endtask

// IRQ callback (irq_pending/sync_id/offload_transfer_cnt declared near the top)
initial begin
  forever begin
    @(posedge ad5529r_spi_irq);
    // read pending IRQs
    mSeq.RegRead32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
    // Offload SYNC command
    if (irq_pending & 5'b10000) begin
      mSeq.RegRead32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
      offload_transfer_cnt++;
      `INFO(("Offload SYNC %d IRQ. Transfer count: %d", sync_id, offload_transfer_cnt), ADI_VERBOSITY_LOW);
    end
    // SYNC command
    if (irq_pending & 5'b01000) begin
      mSeq.RegRead32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_SYNC_ID), sync_id);
      `INFO(("SYNC %d IRQ. FIFO transfer just finished.", sync_id), ADI_VERBOSITY_LOW);
    end
    if (irq_pending & 5'b00100) `INFO(("SDI FIFO IRQ."), ADI_VERBOSITY_LOW);
    if (irq_pending & 5'b00010) `INFO(("SDO FIFO IRQ."), ADI_VERBOSITY_LOW);
    if (irq_pending & 5'b00001) `INFO(("CMD FIFO IRQ."), ADI_VERBOSITY_LOW);
    // Clear all pending IRQs
    mSeq.RegWrite32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_PENDING), irq_pending);
  end
end

bit [`DATA_DLENGTH-1:0] sdo_write_data [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1 :0] = '{default:'0};
bit [`DATA_DLENGTH-1:0] sdo_write_data_store [(`NUM_OF_TRANSFERS)*(`NUM_OF_WORDS) -1 :0];

task automatic generate_sdo_data(
  input offload_test_t data_mode,
  input int num_words
);
  localparam bit [`DATA_DLENGTH-1:0] dac_max = (1 << `DATA_DLENGTH) - 1;
  bit [`DATA_DLENGTH-1:0] dac_word;
  int ramp_step;
  for (int i = 0; i < num_words; i++) begin
    case (data_mode)
      DATA_MODE_RANDOM:  dac_word = $urandom;
      DATA_MODE_RAMP: begin
        ramp_step = (num_words <= 1) ? 0 : (dac_max / (num_words - 1));
        dac_word = (num_words <= 1) ? dac_max : (i * ramp_step);
      end
      default: dac_word = {`DATA_DLENGTH{1'b1}};
    endcase
    sdo_write_data_store[i] = dac_word;
    spiSeq.send_data('0);
  end
endtask

// Copy expected data into DDR for the DMA. 16-bit words pack two per 32-bit
// beat; other widths use one word per beat.
task automatic write_data_to_ddr(
  input int num_words
);
  bit [31:0] write_data;
  if (`DATA_DLENGTH == 16) begin
    for (int i = 0; i < num_words; i = i + 2) begin
      if (i + 1 < num_words)
        write_data = {sdo_write_data_store[i+1][15:0], sdo_write_data_store[i][15:0]};
      else
        write_data = {16'h0000, sdo_write_data_store[i][15:0]};
      base_env.ddr.slave_sequencer.BackdoorWrite32(
        .addr(xil_axi_uint'(DDR_BASE_ADDR + 2*i)),
        .data(write_data), .strb('1)
      );
    end
  end else begin
    for (int i = 0; i < num_words; i = i + 1) begin
      write_data = sdo_write_data_store[i];
      base_env.ddr.slave_sequencer.BackdoorWrite32(
        .addr(xil_axi_uint'(DDR_BASE_ADDR + 4*i)),
        .data(write_data), .strb('1)
      );
    end
  end
endtask

// Point the TX DMA at the DDR buffer and submit the transfer.
task automatic config_tx_dma(
  input int total_bytes
);
  mSeq.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_CONTROL), `SET_DMAC_CONTROL_ENABLE(1));
  mSeq.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_FLAGS),
    `SET_DMAC_FLAGS_TLAST(1) | `SET_DMAC_FLAGS_PARTIAL_REPORTING_EN(1));
  mSeq.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_X_LENGTH), `SET_DMAC_X_LENGTH_X_LENGTH(total_bytes - 1));
  mSeq.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_SRC_ADDRESS), `SET_DMAC_SRC_ADDRESS_SRC_ADDRESS(DDR_BASE_ADDR));
  mSeq.RegWrite32(`SPI_ENGINE_TX_DMA_BA + GetAddrs(DMAC_TRANSFER_SUBMIT), `SET_DMAC_TRANSFER_SUBMIT_TRANSFER_SUBMIT(1));
  `INFO(("    DMA configured: SRC_ADDR=0x%08x, X_LENGTH=%0d bytes", DDR_BASE_ADDR, total_bytes), ADI_VERBOSITY_LOW);
endtask

// Load the per-transfer SPI program into offload command memory: config,
// prescale, dlength, optional CS invert, a CS-framed write, then SYNC (-> IRQ).
task automatic config_offload_command_fifo();
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_CFG);
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_PRESCALE);
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_DLENGTH);
  if (`CS_ACTIVE_HIGH) begin
    mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS_INV_MASK(8'hFF));
  end
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS(8'hFE));
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_WR);
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `SET_CS(8'hFF));
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_CDM_FIFO), `INST_SYNC | 2);
endtask

// Start the offload, wait for the trigger PWM to clock out every transfer,
// then flush and stop.
task automatic start_offload_wait_for_pwm_then_stop();
  // Open the measurement window and arm the CS monitor before enabling offload,
  // so offload-enable latency falls inside the window (intended; see start_measure).
  tput_meter.start_measure();
  tput_until_print = tput_print_interval;
  tput_meter.print_header();
  tput_enabled = 1;  // start counting transfers in the CS monitor
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(1));
  // Wait for all transfer data to be consumed by the engine.
  spiSeq.flush_send();
  // Wait for every transfer to physically complete (ungated VIP RX mailbox = one
  // entry per word) before closing the window. Bounded poll so a real shortfall
  // surfaces as the lost-transfer check instead of hanging; the TX DMA is drained
  // so no extra transfers start.
  begin
    int expected_words = `NUM_OF_TRANSFERS * `NUM_OF_WORDS;
    int settle_tries   = 20;  // 20 * ~500ns = ~10us ceiling
    while (spiSeq.get_num_rx_data() < expected_words && settle_tries > 0) begin
      wait_random(.min_ns(400), .max_ns(600));
      settle_tries--;
    end
  end
  // Close the throughput window, then disable offload and stop counting.
  tput_meter.end_measure();
  mSeq.RegWrite32(`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_OFFLOAD0_EN), `SET_AXI_SPI_ENGINE_OFFLOAD0_EN_OFFLOAD0_EN(0));
  tput_enabled = 0;  // stop counting transfers in the CS monitor
endtask

// Compare transmitted words from the SPI VIP with what the DAC received. One
// mailbox entry == one word; word_cnt is NUM_OF_TRANSFERS * NUM_OF_WORDS.
task automatic verify_received_data(input int word_cnt, ref int error_cnt);
  int len_rx = spiSeq.get_num_rx_data();
  if (len_rx < word_cnt) begin
    // All words should be in by now; if the mailbox is short, the receive_data()
    // loop below will stall on mailbox.get() in the VIP.
    `ERROR(("len_rx(%0d) < word_cnt(%0d), verification might stall", len_rx, word_cnt));
    error_cnt++;
  end
  for (int idx = 0; idx < word_cnt; idx++) begin
    spiSeq.receive_data(sdo_write_data[idx]); // might stall if mailbox is empty
    if (sdo_write_data[idx] != sdo_write_data_store[idx]) begin
      error_cnt++;
      `ERROR(("Data mismatch at word %0d: Expected=0x%04x, Actual=0x%04x",
              idx, sdo_write_data_store[idx], sdo_write_data[idx]));
    end
  end
  `INFO(("  Verified %0d words - %0d errors.", word_cnt, error_cnt), ADI_VERBOSITY_LOW);
endtask

task automatic verify_irq_was_raised();
  if (irq_pending == 'h0) begin
    `ERROR(("  No IRQ received - was offload executed?"));
    total_error_count++;
  end else begin
    `INFO(("  IRQ received (pending=0x%02x) - transfer(s) completed", irq_pending), ADI_VERBOSITY_LOW);
  end
endtask

task automatic print_test_header(
  input offload_test_t data_mode,
  input int total_bytes
);
  `INFO(("\n\n%s", data_mode.name()), ADI_VERBOSITY_LOW);
  `INFO(("  Configuration:"), ADI_VERBOSITY_LOW);
  `INFO(("    %4d transfers of %2d words each (1 transfer = 1 CS cycle)", `NUM_OF_TRANSFERS, `NUM_OF_WORDS), ADI_VERBOSITY_LOW);
  `INFO(("    Channel updates: %0d total, %2d per transfer, %0d bits each",
         `NUM_OF_TRANSFERS * tput_meter.channels_per_transfer, tput_meter.channels_per_transfer, `DATA_DLENGTH), ADI_VERBOSITY_LOW);
  `INFO(("    DDR base address: 0x%08x", DDR_BASE_ADDR), ADI_VERBOSITY_LOW);
  `INFO(("    Total bytes to transfer / DDR buffer: %0d", total_bytes), ADI_VERBOSITY_LOW);
  `INFO(("  Target: ~123 kSPS per channel when sustained (high transfer count)"), ADI_VERBOSITY_LOW);
endtask

// Start the offload and run the per-test acceptance check.
task automatic run_spi_engine_offload();
  // The CS monitor prints partial lines every PROGRESS_REPORTER_PERCENT; the
  // final line below uses the same meter.
  `INFO(("    Waiting for %0d transfers (progress every %0d transfers = %0d %%)...", `NUM_OF_TRANSFERS, tput_print_interval, PROGRESS_REPORTER_PERCENT), ADI_VERBOSITY_LOW);

  wait_random(
    .min_ns(50),
    .max_ns(150)
  );
  start_offload_wait_for_pwm_then_stop();

  // Final throughput line; measured_ksps_* is read by the end-of-test check.
  `INFO((""), ADI_VERBOSITY_LOW);
  `INFO(("  === TEST THROUGHPUT RESULTS ==="), ADI_VERBOSITY_LOW);
  tput_meter.print_status(.is_final(1));

endtask

// Shared engine for all tests:
//   1. config_spi
//   2. generate data (generate_sdo_data + write_data_to_ddr)
//   3. SPI transfers (config_tx_dma + config_offload_command_fifo + run/verify)
//   4. verify
task automatic run_offload_test(
  input offload_test_t data_mode
);
  int num_words   = (`NUM_OF_TRANSFERS) * (`NUM_OF_WORDS);
  int total_bytes = (num_words * `DATA_DLENGTH) / 8;

  print_test_header(data_mode, total_bytes);

  config_spi();

  // Generate test data and write to DDR
  `INFO(("Generating test data..."), ADI_VERBOSITY_LOW);
  generate_sdo_data(data_mode, num_words);

  `INFO(("Writing data to DDR..."), ADI_VERBOSITY_LOW);
  write_data_to_ddr(num_words);

  `INFO(("Configuring TX DMA..."), ADI_VERBOSITY_LOW);
  config_tx_dma(total_bytes);
  `INFO(("Configuring SPI Engine Offload..."), ADI_VERBOSITY_LOW);
  config_offload_command_fifo();
  `INFO(("Running SPI Engine Offload..."), ADI_VERBOSITY_LOW);
  run_spi_engine_offload();
  run_verification_suite();

  `INFO(("[run_offload_test] test complete"), ADI_VERBOSITY_LOW);
endtask

// Toggle Pin Test (TG0-TG3 PWM outputs)
//
// The toggle_gen PWM core drives the four TG pins (DAC LDAC/toggle timing). All
// channels are programmed identically (5 MHz, 50% duty) and run for one fixed
// window; each pin is then checked for toggling + frequency/duty.
//
// toggle_gen is a SEPARATE core from the SPI trigger PWM, so PWM_PERIOD_C below
// is independent of config_spi's PWM_PERIOD (TRIG_GEN).

task test_toggle_pins();
  localparam int PWM_PERIOD_C = 28;    // 140 MHz / 28 = 5 MHz
  localparam int PWM_WIDTH_C  = 14;    // 50% duty
  localparam int MIN_EDGES    = 10;    // min edges over the window to pass

  int initial_tg[NUM_TG];
  int edges_tg[NUM_TG];

  `INFO((""), ADI_VERBOSITY_LOW);
  `INFO(("=== Toggle Pin Test: Verifying PWM outputs on TG0-TG3 ==="), ADI_VERBOSITY_LOW);

  // Snapshot the free-running edge counters
  initial_tg = tg_edges;

  reset_pwm_measurement();

  // Reset toggle_gen PWM
  mSeq.RegWrite32 (`SPI_ENGINE_TOGGLE_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1));

  // Per-channel period/width (one register each, +4 bytes apart)
  for (int ch = 0; ch < NUM_TG; ch++) begin
    mSeq.RegWrite32 (`SPI_ENGINE_TOGGLE_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD) + ch*4, PWM_PERIOD_C);
    mSeq.RegWrite32 (`SPI_ENGINE_TOGGLE_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_WIDTH)  + ch*4, PWM_WIDTH_C);
  end

  // Load configuration
  mSeq.RegWrite32 (`SPI_ENGINE_TOGGLE_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1));

  `INFO(("  PWM generator configured: Period=%0d cycles, Width=%0d cycles (50%% duty)", PWM_PERIOD_C, PWM_WIDTH_C), ADI_VERBOSITY_LOW);
  `INFO(("  Expected: 5 MHz @ 140 MHz clock"), ADI_VERBOSITY_LOW);

  // Measurement window: ~50 edges/pin at 5 MHz (threshold 10)
  // TODO WAIT: size this window properly.
  #10000ns;

  pwm_measurement_enabled = 0;

  // Edges per channel over the window
  edges_tg = tg_edges;
  foreach (edges_tg[ch]) edges_tg[ch] -= initial_tg[ch];

  // Per-channel: edge count + frequency/duty
  `INFO(("  Channel verification (edge count + PWM timing):"), ADI_VERBOSITY_LOW);
  foreach (edges_tg[ch]) begin
    // Did the pin toggle during the window?
    if (edges_tg[ch] < MIN_EDGES) begin
      total_error_count++;
      `ERROR(("Toggle Pin Test: TG%0d edge count too low", ch));
      `INFO(("    TG%0d: Edges=%0d, Expected>=%0d, Status=FAIL", ch, edges_tg[ch], MIN_EDGES), ADI_VERBOSITY_LOW);
    end else begin
      `INFO(("    TG%0d: Edges=%0d, Expected>=%0d, Status=PASS", ch, edges_tg[ch], MIN_EDGES), ADI_VERBOSITY_LOW);
    end
    // 5 MHz +/-1%, 50% duty +/-2%
    verify_pwm_timing(
      .channel(ch),
      .expected_freq_mhz(5.0),
      .freq_tolerance_pct(1.0),
      .expected_duty_pct(50.0),
      .duty_tolerance_pct(2.0));
  end
endtask

// Start the SPI clk generator and trigger PWM, then configure the SPI engine.
task config_spi();

  // Period between SPI-offload triggers, in PWM-gen clock cycles (one transfer
  // per trigger). If it is longer than the time to shift out a frame, transfers
  // wait between triggers and it caps throughput; once shorter, transfers run
  // back-to-back and the SPI shift time becomes the limit. 50 sits in the
  // back-to-back region and yields appropriate throughput for every test.
  localparam int PWM_PERIOD = 50;

  `INFO(("Config SPI: Starting clock generator and configuring SPI engine"), ADI_VERBOSITY_LOW);

  // Start spi clk generator
  mSeq.RegWrite32 (`SPI_ENGINE_AXI_CLKGEN_BA + GetAddrs(AXI_CLKGEN_REG_RSTN),
    `SET_AXI_CLKGEN_REG_RSTN_MMCM_RSTN(1) |
    `SET_AXI_CLKGEN_REG_RSTN_RSTN(1)
    );

  // Config trigger PWM
  mSeq.RegWrite32 (`SPI_ENGINE_TRIG_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_RESET(1)); // PWM_GEN reset in regmap (ACTIVE HIGH)
  mSeq.RegWrite32 (`SPI_ENGINE_TRIG_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_PULSE_X_PERIOD), `SET_AXI_PWM_GEN_REG_PULSE_X_PERIOD_PULSE_X_PERIOD(PWM_PERIOD)); // set PWM period
  mSeq.RegWrite32 (`SPI_ENGINE_TRIG_GEN_BA + GetAddrs(AXI_PWM_GEN_REG_RSTN), `SET_AXI_PWM_GEN_REG_RSTN_LOAD_CONFIG(1)); // load AXI_PWM_GEN configuration
  `INFO(("Trigger PWM generator started."), ADI_VERBOSITY_LOW);

  // Enable SPI Engine
  mSeq.RegWrite32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_ENABLE), `SET_AXI_SPI_ENGINE_ENABLE_ENABLE(0));

  // Configure the execution module
  mSeq.RegWrite32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_CFG);
  mSeq.RegWrite32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_PRESCALE);
  mSeq.RegWrite32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `INST_DLENGTH);
  if (`CS_ACTIVE_HIGH) begin
    mSeq.RegWrite32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_CMD_FIFO), `SET_CS_INV_MASK(8'hFF));
  end

  // Set up the interrupts
  mSeq.RegWrite32 (`SPI_ENGINE_SPI_REGMAP_BA + GetAddrs(AXI_SPI_ENGINE_IRQ_MASK),
    `SET_AXI_SPI_ENGINE_IRQ_MASK_SYNC_EVENT(1) |
    `SET_AXI_SPI_ENGINE_IRQ_MASK_OFFLOAD_SYNC_ID_PENDING(1)
    );

  `INFO(("Config SPI PASSED"), ADI_VERBOSITY_LOW);

endtask
