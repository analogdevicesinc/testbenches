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

** NOTE
 * cfg1 - AD7606B device selected;
 * cfg2 - AD7606C-16 device selected;
 * cfg3 - AD7606C-18 device selected;
