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
 * cfg1 - test_program - ADA4355 variant (BUFMRCE clock routing);  BUFMRCE_EN=1, TDD_EN=0;
 * cfg2 - test_program - ADA4356 variant (default clock routing);   BUFMRCE_EN=0, TDD_EN=0;
 * cfg_tdd - test_program_tdd - LiDAR TDD timing with AXI_TDD;     BUFMRCE_EN=0, TDD_EN=1;
 * test_program     - ADC data capture and DMA verification;
 * test_program_tdd - TDD-gated LiDAR acquisition with external sync trigger;

 **Example:**

* make CFG=cfg1 TST=test_program
* make CFG=cfg2 TST=test_program
* make CFG=cfg_tdd TST=test_program_tdd
