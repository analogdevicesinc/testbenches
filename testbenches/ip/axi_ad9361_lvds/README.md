Testbench for the LVDS physical interface of the `axi_ad9361` IP core (`library/axi_ad9361/xilinx/axi_ad9361_lvds_if.v`).

Validates:

 * frame error detection — explicit whitelist of the four valid AD9361 DDR frame patterns (`4'b1111`, `4'b1100`, `4'b0000`, `4'b0011`) using case-equality (`===`) to handle simulation X-states
 * RX data delineation state machine in 2R2T and 1R1T modes
 * TX serialization path

Configurations:

 * `cfg_2r2t` — `MODE_1R1T=0`, full 48-bit ADC data path
 * `cfg_1r1t` — `MODE_1R1T=1`, 24-bit ADC data path (upper 24 bits zeroed)

Test programs:

 * `test_program` — functional pass/fail tests with `ERROR`/`INFO` assertions
 * `frame_sweep` — exhaustive pattern sweep for waveform inspection (no assertions)

Run all tests in batch mode:

	make


Run all tests in GUI mode:

	make MODE=gui


Run specific test on a specific configuration in GUI mode:

	make CFG=<name of cfg> TST=<name of test> MODE=gui


Run all tests from a configuration:

	make <name of cfg>


Where:

 * `<name of cfg>` is a file from the `cfgs/` directory without the `.tcl` extension (`cfg_2r2t` or `cfg_1r1t`)
 * `<name of test>` is a file from the `tests/` directory without the `.sv` extension (`test_program` or `frame_sweep`)
