.. _architecture:

Testbenches Architecture
===============================================================================

File structure of a project
-------------------------------------------------------------------------------

.. tip::

   In ``base/`` you can find a test bench base design.

Project files for test benches
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  ``projects``

   -  ``cfgs`` --- projects might have various parameters that can only be set
      during project creation, these parameters are set in one of these
      configuration files and can be passed to the simulation environment;
      they might also contain parameters that aid in building various block designs

   -  ``tests`` --- main simulation files, they control and monitor the DUT(s)

   -  ``waves`` --- waveforms for various configuration options (only used in
      GUI mode)

   -  ``Makefile`` --- lists the required System Verilog files, Tcl scripts,
      libraries used, and configuration-test_program combinations (if it’s the
      case, otherwise all configurations run one and the same default test program)

   -  ``system_project.tcl`` --- creates the project, the base block design based
      on the test_harness_system_bd and sets up a couple of definitions for the
      environment and test program

   -  ``system_bd.tcl`` --- adds the DUT(s) to the block design with the configuration
      files (even if no configuration parameter is used, a configuration file must
      exist)

   -  ``system_tb.sv`` --- connects the block design with the test program

-  ``common`` --- common files that are used in many projects

    -   ``sv`` --- basic functions, abstract/base classes, register maps to access
        IP’s registers, classes for controlling the IPs

    -   ``test_harness`` --- base designs

        -   ``jesd_exerciser.tcl`` --- used to instantiate the ADI JESD204 Framework 
        -   ``test_harness_system_bd.tcl`` --- used in all projects as a base design

-  ``scripts`` --- used for creating and running the testbenches

Creating a new testbench
-------------------------------------------------------------------------------

-  Create the ``Makefile`` and list all of the currently known dependencies
-  Create the ``system_project.tcl`` script and add the currently known
   simulation dependencies there as well
-  Create at least one ``configuration file`` (it can be left empty)
-  Create the ``system_bd.tcl`` script, which creates the block design
-  Create the ``system_tb.sv`` file that connects the testbench with the block design
-  Consider creating ``classes`` that encapsulate the variables and functions, so it
   can be used in other testbenches
-  Create the ``test_program.sv`` to run the simulation
-  Update the ``Makefile`` and ``system_project.tcl`` with the new dependencies
   if needed.

Adding a new configuration to a test bench
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   Simple, all of the configurations are compatible with all of the test programs.

Requirements:

-  New ``configuration`` doesn't change the connections between the block design and
   the ``test program``.
-  ``Test program`` can be used with the new ``configuration`` without modifications.
-  Create a ``new configuration`` in ``cfg`` folder.
-  Check if the ``Makefile`` automatically includes the newly created ``configuration``, 
   otherwise add it to the list manually.
-  Test the configuration with the existing test program.

Adding a new test program to a test bench
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   Simple, all of the configurations are compatible with all of the test programs.

Requirements:

-  Connections between the block design and the test program don't change.
-  All of the existing ``configurations`` must be compatible with the new
   ``test program``.
-  Create a ``new test`` program in tests folder.
-  Check if the ``Makefile`` automatically includes the newly created 
   ``configuration``, otherwise add it to the list manually.
-  Test the program with the existing configurations.

Creating a modified block design in the same project folder
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. warning::

   Advanced, not all configurations are compatible with the test programs.

Requirements:

-  Create a new parameter that tells the ``system_bd.tcl`` what to build.
        -   this parameter must be included in all of the existing and new
            configuration files; 
        -   if the design already has multiple variations of the block design,
            update the existing parameter with the new value which corresponds
            to the new block design
-  New ``configuration file(s)`` must be created for the new block design.
-  Modify the ``system_bd.tcl`` script to use the created parameter to create the
   old or new block design.
-  In ``system_tb.sv`` use the parameter to connect the new block design with a
   new ``test program``.
-  Create the ``new test program``.
-  In the ``Makefile``, modify the TESTS list to not be automatically generated
   and add the test program:config options to the list that you want to run.
-  In the ``system_project.tcl`` add a switch that chooses between the test programs
   based on the parameter.
-  Write and test the new ``test program``.
