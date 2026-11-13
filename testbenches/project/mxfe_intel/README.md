Simulation of the AD9081 (MxFE) data path of the Agilex 5 (a5e) design, built
with Platform Designer and run in Questa.

The hdl ad9081_fmca_ebz_qsys.tcl is used as is, with its GTS PHY. The system
PLL and the reset sequencer glue of the a5e system_top are in system_tb, which
loops the serial TX lanes back into the RX lanes. The transceiver models are
compiled with IP7521SERDES_UX_SIMSPEED (fast simulation).

Requirements:

 * Quartus Pro (quartus_sh, qsys-script, qsys-generate) and vsim in PATH
 * a Questa license with SystemVerilog verification (e.g. Questa-Intel FPGA
   Edition), the Starter Edition does not run the class based test bench
 * ADI_HDL_DIR pointing to the hdl repository

Usage :

Run all tests in batch mode:

	make


Run all tests in GUI mode:

	make MODE=gui


Run specific test on a specific configuration in gui mode:

	make CFG=<name of cfg> TST=<name of test> MODE=gui


Run all test from a configuration:

	make <name of cfg>


Where:

 * <name of cfg> is a file from the cfgs directory without the tcl extension of format cfg\*
 * <name of test> is a file from the tests directory without the tcl extension
