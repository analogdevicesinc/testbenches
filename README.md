<p align="center">
<img src="docs/sources/HDL_logo.png" width="500" alt="ADI HDL Logo"> </br>
</p>

<p align="center">
<a href="http://analogdevicesinc.github.io/testbenches/">
<img alt="GitHub Pages" src="https://img.shields.io/badge/docs-GitHub%20Pages-blue.svg">
</a>

<a href="https://ez.analog.com/fpga/f/q-a">
<img alt="EngineerZone" src="https://img.shields.io/badge/Support-on%20EngineerZone-blue.svg">
</a>
</p>

---
# General description

This repository contains testbenches and verification components for system-level projects or components connected at block level from the [hdl](https://github.com/analogdevicesinc/hdl) repository.

This repository is not a standalone one. It must be cloned or linked as a submodule inside the [hdl](https://github.com/analogdevicesinc/hdl) repository you want to test.

The folder structure of the HDL will look as follows:

hdl
  - projects
  - library
  - testbenches

## Setup
The testbenches are built around Xilinx verification IPs so it requires Vivado to be set up according to the HDL repository requirements.
Running the testbenches relies on the build mechanism from the HDL repository, make sure you have a proper setup for Xilinx flow described [here](https://wiki.analog.com/resources/fpga/docs/build)

## Running a testbench:

Change the working directory to the testbench you want to run:

	cd testbenches/fmcomms2

The scripts first will build all components used from the HDL library, build the block design environment based on a configuration file that describes parameters of under test block, then will actually run the test.
These steps are separated in order to be able to run multiple tests on the same configuration without rebuilding the block design every time.

### Run all tests in batch mode:

	make

### Run all tests in GUI mode:

	make MODE=gui

### Run specific test on a specific configuration in gui mode:

	make CFG=<name of cfg> TST=<name of test> MODE=gui

### Run all tests from a configuration:

	make <name of cfg>


Where:

 * \<name of cfg\> is a file from the cfgs directory without the tcl extension of format cfg\*
 * \<name of test\> is a file from the tests directory without the tcl extension
