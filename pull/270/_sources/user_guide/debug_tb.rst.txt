.. _debug_tb:

Debugging a testbench
===============================================================================

Info message logging
-------------------------------------------------------------------------------

Message logging is similar to the UVM style logging, but it is more primitive
and does support many features from it. The logger supports multiple levels of
debug message printing, like UVM, however, it does not follow the debug level
recommendations. These levels are described in :ref:`coding_guidelines` section
F5. Similarly to how UVM works, activating a higher debug level will activate
all debug messages, that are below it as well.

.. hint::

   - ADI_VERBOSITY_NONE: only activates the info messages that are set to NONE
   - ADI_VERBOSITY_LOW: activates the info messages that are NONE and LOW
   - ADI_VERBOSITY_MEDIUM: activates the info messages that are NONE, LOW and
     MEDIUM
   - ADI_VERBOSITY_HIGH: activates all info messages

Activating logger messages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, all testbenches are set to report the minimum amount of messages.
These messages include warning, error, fatal messages, as well as other
important informations regarding randomization state and a testbench done
message, if the simulation reached the end of the test. In order to activate
other messages, look for the **setLoggerVerbosity(...)** function found in the
test_program in one of the **initial begin** blocks, which starts the
simulation. Set the verbosity level to what is necessary for the debug sesstion.

Adding additional logger messages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Since the logger messages don't cover every part of the code, it might be
necessary to add additional logging messages in certain cases to ensure that
the module is working as expected. In this case, please follow the logger
verbosity level guide found in :ref:`coding_guidelines` section F5.

Replicating a simulation
-------------------------------------------------------------------------------

In order to replicate a simulation a number of parameters are needed. In order
to avoid any confusion, here is the complete list of parameters that are needed
to replicate any testbench simulation.

Nothing is changed:

- Configuration file used
- parameters.log, which is found in **<testbench>/runs/<configuration>/**
- Randomization seed value, found in **test_program*.log** or TCL console in GUI
  mode look for: # random sv_seed = <value>; this parameter is set in Vivado,
  Settings, Simulation, Simulation tab, xsim.simulate.xsim.more_options,
  -sv_seed, or in the system_project.tcl file
- Randomization state, which is used to verify that the correct randomization
  value is set in Vivado at the start of the simulation, found in
  **test_program*.log** or TCL console in GUI mode look for: [INFO] @ 0 ns:
  Randomization state: <value>

If there are changes made to the testbench:

- All of the above
- Configuration used, with all modified parameters, or the custom configuration
  file itself
- Any changes made to the block design, test program, libraries and/or IPs
