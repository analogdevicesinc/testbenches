.. _coding_guidelines:

ADI Testbenches coding guidelines
===============================================================================

1. Introduction
-------------------------------------------------------------------------------

This document contains coding and documentation guidelines which must be
followed by all HDL testbenches.

The coding rules are intended to be applied to testbenches written using
System Verilog.

The HDL coding guidelines :external+hdl:ref:`hdl_coding_guidelines` are also
applicable here. In addition, there are a set of rules for System Verilog,
listed below.

2. Coding style
-------------------------------------------------------------------------------

A. Naming
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**A1**

Class names should be composed in the following way:
 * <class_name>_vif - Virtual Interface
 * <class_name>_env - Environment
 * <class_name>_wd - Watchdog
 * <class_name>_api - API class for an IP
 * <class_name>_agent - Agent class for an VIP
 * <class_name>_driver - Driver class for an VIP
 * <class_name>_monitor - Monitor class for an VIP
 * <class_name>_sequencer - Sequencer class for an VIP

**A2**

File names should be composed in the following way:
 * <driver_name>_api - API
 * Makeinclude_<include_name> - Makefile includes
 * sp_include_<include_name> - system_project.tcl includes
 * adi_regmap_<ip_name>_pkg - used in registermap class definitions
 * <module_name>_pkg - generic file name
 * adi_<vip_name>_vip - packaged VIP top module
 * adi_<vip_name>_vip_pkg - VIP agent, driver, monitor and sequencer containing package
 * adi_<vip_name>_if - VIP interface
 * adi_<vip_name>_if_base_pkg - abstract interface class, to be used and implemented in the VIP interface

B. General
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**B1**

Use safe-guarded thread construct when attempting to stop/kill a thread to prevent unknown behavior

**B2**

Include files should be used in Makefile and system_project.tcl scripts for classes that have multiple dependencies

**B3**

Testbench must finish with all threads stopped, testbench done message must be printed and the finish system function must be called afterwards

**B4**

Forever statement must be used instead of while(1)

**B5**

Repeat statement must be used instead of for loops, where the same operation block is repeated with no changes

**B6**

Watchdogs must be used to ensure that the simulation doesn't get stuck during a run

**B7**

Test programs must use localparams instead of parameter

C. Design Under Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**C1**

DUT IPs with a parameterizable registermap must have a macro that is used to import the IPs paramters

**C2**

IP base addresses must be defined when the block design is created

**C3**

Testbench's FPGA part must be compatible with the IPs used in the design

**C4**

All configuration parameters must be defined in the ad_project_params associative array

**C5**

In project level testbenches, the DUT block design should come from the HDL repository

**C6**

If multiple test programs are created, the test program's name should hint towards the use-case of that test program

**C7**

If multiple configurations are created, the configuration file's name should hint towards the use-case of that configuration file

D. Methods
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**D1**

Function method definition must be used for operations that have no relation with simulation time

**D2**

Parenthesis must be present at method calls, even if these don't require any input value

**D3**

All method arguments must have their direction specified as input, output or ref, except for classes

E. Event scheduling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**E1**

Event synchronization between multiple threads should be avoided, unless the user is very familiar with the simulation scheduler and knows about all of the corner cases that may arise using multiple threads

**E2**

#0 must not be used. This would only mean that synchronization between events is not properly handled and it's prone to error if not used exactly the way it was intended to be used

**E3**

Time value and scale must be specified for delaying statements

F. Reporting
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**F1**

Reporting system functions calls from the standard must only be used in VIP files related to the block design IP

**F2**

Reporting functions from the base reporting class must be used in classes that inherit these functions

**F3**

Reporting macros must only be used in the test programs

**F4**

Error messages should be used where the simulation may continue if something is not working as expected. In every other instance, where the simulation must halt immediately, use fatal messages

**F5**

Verbosity settings must be set as follows:
* ADI_VERBOSITY_NONE: Only for simulation randomization state and simulation done messages
* ADI_VERBOSITY_LOW: all info messages inside the test program, with the exceptions of ADI_VERBOSITY_NONE
* ADI_VERBOSITY_MEDIUM: inside drivers
* ADI_VERBOSITY_HIGH: inside VIP modules, regmaps, utilities

G. Classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**G1**

Checker and scoreboard modules must be written to be parameterizable (how and what exactly this means is an open question)

**G2**

Data and methods inside classes should be protected from outside access using protected and local keywords where it makes sense

**G3**

ADI_FIFO or ADI_LIFO must be used for queues to avoid push-pull/front-back style differences and other issues (to be implemented)

**G4**

Checker or scoreboard class should be used whenever comparing data streams

H. VIP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**H1**

VIP agents must contain a driver, monitor and sequencer modules

**H2**

VIP monitors must contain a publisher module

**H3**

VIP drivers, monitors and sequencers must have their agent parents set

**H4**

VIP drivers, monitors and sequencers must not be instantiated outside of the agent

**H5**

VIP agents, drivers, monitors and sequencers should not be parameterizable. These classes should read parameter values from the interface class, which has direct access to the interface parameters

**H6**

VIP agents should have an environment as a parent

**H7**

VIP agents must be parameterized with an interface class and not with a virtual interface. AMD VIPs are an exception from this rule

I. API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**I1**

APIs that can control an IP that has a parameterizable registermap must also be parameterized with the same parameters using a macro

**I2**

APIs with registermaps must have a sanity test implemented

**I3**

IP register access calls must only be written inside an API

**I4**

Every ADI IP should have its own API driver class

**I5**

IRQ handler class must be used when dealing with interrupt requests

J. Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**J1**

An environment must only contain VIP agents, APIs and/or checkers

**J2**

Test_harness_env should not be inherited by any environment

**J3**

New environments should be created with the intent to be reused in other testbenches

K. Randomization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**K1**

Constrained randomized values must be used for randomized testing

**K2**

Variable randomization states must always be checked

**K3**

All random variables must be randomized when the class creation occurs

**K4**

Test programs must output the simulation randomization state at the very beginning of the simulation

**K5**

The testbench should have a randomized configuration file paired with a randomized testbench

3. Annexes
-------------------------------------------------------------------------------

Annex 1 System Verilog file format (different use-cases)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. References
-------------------------------------------------------------------------------
