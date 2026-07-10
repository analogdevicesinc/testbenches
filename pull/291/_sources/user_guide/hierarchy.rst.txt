.. _hierarchy:

Repository hierarchy
===============================================================================

File structure of a project
-------------------------------------------------------------------------------

.. tip::

   In ``testbenches/ip/base/`` you can find a test bench base design.

Project files for test benches
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  ``library`` --- common files that are used in many projects

    -  ``drivers`` --- drivers and APIs used for controlling IPs as well as VIPs;
       these modules can use register map files, VIPs and other APIs
    -  ``regmaps`` ---  register map files created for simulations based on the
       HDL IP register maps along with a couple of utility files; these are macro
       functions that are used to access a specific IP's register's field in a
       given variable that is passed to these functions
    -  ``utilities`` --- common scripts, modules and macros that are used for
       testbench design and environment creation
    -  ``vip`` --- ADI verification IPs (VIP) and additional auxiliary classes
       which are vendor specific

-  ``scripts`` --- used for creating and running the testbenches

-  ``testbenches``

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
