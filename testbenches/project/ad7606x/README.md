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
 * cfg_p_16b - test_program_4ch - AD7605-4/AD7606-4 device selected;                   INTF=0, ADC_N_BITS=16;
 * cfg_p_16b - test_program_6ch - AD7606-6 device selected;                            INTF=0, ADC_N_BITS=16;
 * cfg_p_16b - test_program_8ch - AD76006B/AD7606C-16/AD7606-8/AD7607 device selected; INTF=0, ADC_N_BITS=16;
 * cfg_p_18b_8ch - test_program_8ch - AD7606C-18/AD7608/AD7609 device selected;        INTF=0, ADC_N_BITS=18;
 * cfg_s_sdi1    - any device selected;                                 INTF=1, NUM_OF_SDI=1;
 * cfg_s_sdi2    - any device selected;                                 INTF=1, NUM_OF_SDI=2;
 * cfg_s_sdi4    - AD7606B/AD7606C-16/AD7606C-18;                       INTF=1, NUM_OF_SDI=4;
 * cfg_s_sdi8    - AD7606C-16/AD7606C-18 device selected;               INTF=1, NUM_OF_SDI=8;
 * test_program_4ch  - AD7605-4/AD7606-4 device selected;
 * test_program_6ch  - AD7606-6 device selected;
 * test_program_8ch  - AD76006B/AD7606C-16/AD7606C-18/AD7606-8/AD7607/AD7608/AD7609 device selected;
 * test_program_si  - any device selected;

 **Example:**

* make CFG=cfg_p_16b TST=test_program_4ch
* make CFG=cfg_p_16b TST=test_program_6ch
* make CFG=cfg_p_16b TST=test_program_8ch
* make CFG=cfg_p_18b_8ch TST=test_program_8ch
* make CFG=cfg_s_sdi1 TST=test_program_si
* make CFG=cfg_s_sdi2 TST=test_program_si
* make CFG=cfg_s_sdi4 TST=test_program_si
* make CFG=cfg_s_sdi8 TST=test_program_si