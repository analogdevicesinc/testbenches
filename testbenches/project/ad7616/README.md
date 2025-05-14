# AD7616-SDZ HDL Project

- HDL project documentation: https://analogdevicesinc.github.io/hdl/projects/ad7616_sdz/index.html
- Testbench documentation: https://analogdevicesinc.github.io/testbenches/testbenches/project_based/ad7616/index.html

## Building the project

Run all tests in batch mode:

```
cd testbenches/project/ad7616
make
```

Run all tests in GUI mode:

```
make MODE=gui
```

Run specific test on a specific configuration in gui mode:

```
make CFG=<name of cfg> TST=<name of test> MODE=gui
```

Run all test from a configuration:

```
make <name of cfg>
```

Where:

 * \<name of cfg\> is a file from the cfgs directory without the tcl extension of format cfg\*
 * \<name of test\> is a file from the tests directory without the tcl extension
