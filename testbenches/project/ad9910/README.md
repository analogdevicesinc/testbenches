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


Available configuration and test pairs (a test must be run with its own cfg):

 * cfg1_drg    : test_program_drg    - DRG control (PWM ramp generator)
 * cfg2_par_if : test_program_par_if - parallel data interface (DMA to db_o)

