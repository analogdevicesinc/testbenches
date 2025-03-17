Base design to be copied when starting to work on a new testbench.

By default includes:

 * all the files that are needed for any testbench
 * scoreboard and auxiliary module imports, ready to be integrated
 * new environment file ready to expand the base test harness environment
 * test program that powers up and shuts down the system
 * option to add manual seeding

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

