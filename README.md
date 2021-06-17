# General description

This repository contains testbenches and verification components for system level projects or components connected at block level from the [hdl](https://github.com/analogdevicesinc/hdl) repository.

This repository is not a stand alone one. It must be checked out or linked as a submodule inside the [hdl](https://github.com/analogdevicesinc/hdl) repository you want to test. 

The folder structure of the hdl will look as follows:

hdl
  - projects
  - library
  - testbenches
  
## Setup
The testbenches are built around Xilinx verification IPs so it requires Vivado to be set up according to the hdl repository requirenments. 
Running the testbenches relies on the build mechanism from the hdl repository,  make sure you have a proper setup for Xilinx flow described [here](https://wiki.analog.com/resources/fpga/docs/build)

## Running a testbench:

Change the workig directory to the testbench you want to run: 

	cd testbenches/fmcomms2

The scripts first will build all components used from the hdl library, build the block design environment based on a configuration file that describes parameters of under test block, then will actually run the test. 
These steps are separated in ordrer to be able to run multiple tests on the same configuration. 

### Run all tests in batch mode:

	make

### Run all tests in GUI mode:

	make MODE=gui

### Run specific test on a specific configuration in gui mode:

	make CFG=<name of cfg> TST=<name of test> MODE=gui

### Run all test from a configuration:

	make <name of cfg>


Where:

 * \<name of cfg\> is a file from the cfgs directory without the tcl extension of format cfg\*
 * \<name of test\> is a file from the tests directory without the tcl extension

