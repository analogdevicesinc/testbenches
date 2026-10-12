.. _test_harness:

Test Harness
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of the test harness is to create a base environment that is used by
most of our testbenches. The test harness structure is like that of UVM
environment, where it has instantiated agents alongside other simulation
related modules that to interface with the VIPs or checkers for example. In the
case of the ADI testbenches for AMD, we're leveraging what AMD offers in terms
of VIPs, which include clocking, reset, AXI and AXI-Stream. The two files
associated with the test harness are used for creating and driving the
environment.

Structure
-------------------------------------------------------------------------------

The base environment design is built using the ``test_harness_system_bd.tcl``
script when a project build is started. For the base environment, we're using 2
AXI VIPs. One is used to simulate a Processing System, while the other one is
used to simulate a DDR memory. The simulated PS is equivalent of a single core
in a real system and is set to be a 32-bit compatible. The DDR memory is set to
be able to store 2GB worth of data and has a bus width of 512 bits. The PS is
connected to an interconnect that will manage the connection between the PS and
other IPs. The DDR memory is connected to a different interconnect, that
manages all IP accesses to the memory. The PS and the DDR memory are directly
connected, which gives direct access from the PS to the DDR. 3 clocking VIPs
are used to generate clock signals for these modules. These clocking VIPs
provide the following frequencies: 100 MHz, 200 MHz and 400 MHz. A reset VIP is
used to reset the whole system at the bring up phase. Each one of the clocking
VIPs have an accompanying Processor System Reset IP, that is used for
synchronizing the reset VIPs signal with each clock domain. The PS
interconnect's base clock is set to use the 100 MHz clock signal. The DDR
memory interconnect's base clock is set to use the 400 MHz clock. An AXI
Interconnect IP from AMD is added to handle interrupt requests coming from
different IPs. The interrupt handling function is not yet implemented in our
base design.

Additional notes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* The structure used for the testbenches allows quick prototyping for our
  existing projects on a block design level.
* The implemented interconnect IPs can be the older ``AXI Interconnect`` or the
  newer ``Smart Connect``, depending on the FPGA part used in the simulation.
  If the FPGA part is a 7-series one, then the ``AXI Interconnect`` is used,
  otherwise the ``Smart Connect``. There is also a variable called
  ``use_smartconnect`` that can be set in the TCL script to force the
  interconnect type by hand if needed.
* In our simulations, we have not pushed the DDR VIP to the limits in terms of
  storage. We advise to be careful with memory management considering the
  project size, as well as the test stimulus.
* Additional clocking blocks can be added into the design if needed, while the
  already existing clocking blocks can be updated with the required
  frequencies. These changes will be project specific and won't affect the
  other testbenches.
* To simulate a multi-core system, additional AXI VIPs need to be added and
  controlled separately. Same thing goes with additional DDR memory. We haven't
  tried to instantiate multiple PS cores or DDR interfaces, as our testbench
  designs didn't need it. Architecting an extended system that supports
  multiple DDR interfaces or PS cores is up to the designer.
* We know that not all our testbench designs use the PS, the DDR or the
  Interrupt interfaces. This slows the build time of the projects that don't
  use them, however; they have little to no impact on the simulation runtime.
  Some of our testbenches have custom made test harnesses that were developed
  in the early stages  of the testbenches repository and currently they
  represent legacy testbenches that are still used for verifying our designs.

Simulation environment
-------------------------------------------------------------------------------

The simulation environment is defined in ``test_harness_env.sv`` packaged in
``test_harness_env_pkg``. The ``test_harness_env`` class is defined here, which
has a basic set of instructions for environment bring up.

Variables
-------------------------------------------------------------------------------

The base environment imports packages for the VIPs that are used in the base
design using PKGIFY macro. Each VIP has a separate package created upon
instantiation and this allows these to be imported by name. The
``test_harness_env`` class creates agents with the help of AGENT macro,
similarly to how the packages are imported for the VIPs, since each agent has
its own type definition. Parameterized sequencers are created with the intent
of higher level of abstraction. Since we're practically simulating a PS, the
functions available in the ``m_axi_sequencer`` class are specifically created
for register reads and writes. Same thing goes for the DDR memory, which uses
the ``s_axi_sequencer`` class. If the designer does not have the option to
generate a specific transaction using these sequencers, the option is still
there to access functions from the AXI VIP agent. Virtual interfaces for the
clocking and reset VIPs are also instantiated, so these can be accessed later
in the simulation.

Functions
-------------------------------------------------------------------------------

These are functions provided by the test harness environment for an easy and
fast bring up. These functions are scheduled to be updated or removed.

function new(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Created the environment object. Virtual interfaces are specified to link the
block design interfaces with their respective simulation interface. The new
function stores clocking and reset interfaces in local variables. It also
instantiates the agents and sequencers for the PS and DDR memory VIPs.

task start();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to activate the VIP agents and start the clocks.

task test();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Empty by default. Add test stimulus here if the environment class is inherited.

task post_test();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Function called after the test stimulus is completed.

task run();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used for calling test and post_test functions.

task stop();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used for stopping the VIP agents and stop the clocks.

task wait_done();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Function called after the simulation is started, waiting for it to finish.

task test_c_run();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set done variable to 1, indicating the end of test stimulus.

task sys_reset();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to assert reset for 200 ns, after which there is an 800 ns wait time.
These timings are used in accordance with the clock frequency values. The 200
ns gives enough time for each Processing System Reset IP to clock the reset
signal for at least 16 clock cycles, which is a requirement. The 800 ns time is
set arbitrarily, waiting for all the IPs to properly deassert from the reset
state before starting the test.

Usage
-------------------------------------------------------------------------------

* Declare the test harness inside the test program
* Instantiate the test harness with new, with the arguments being virtual
  interfaces that connect the block design with the test harness class
* Start the test harness
* Call the system reset function
* Add the test stimulus
* After all the testing is done, call the stop function

.. include:: ../../../common/support.rst
