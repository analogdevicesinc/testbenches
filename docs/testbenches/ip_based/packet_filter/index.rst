.. _packet_filter:

Packet filter
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of this testbench is to give engineers a sandbox testbench, where
they can check out how to implement and use a filter.

Block design
-------------------------------------------------------------------------------

The block design is based on the test harness with the addition of two AXI4
Stream VIPs from AMD. This testbench does not require the presence of the test
harness, as it can work without it, but since it was created based on the base
design, this was inherited. One of the VIPs is configured as master, while the
other one is configured as slave. The TREADY, TLAST and TKEEP signals are set to
be enabled for the VIPs.

Block diagram
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. image:: ../axis_sequencers/axis_sequencers_tb.svg
   :width: 800
   :align: center
   :alt: Scoreboard/Testbench block diagram

Configuration parameters and modes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are no parameters that can be configured in the testbench configuration
files.

Build parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

There are no build parameters for this testbench.

Configuration files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As this is a sandbox testbench, engineers are encouraged to change parameters
and see what happens in the simulation. Since there are no parameters available
for edit, the coniguration file's purpose is to give the testbench instance a
name.

Tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following test program file is available:

============ ==============================
Test program Usage
============ ==============================
test_program Creates a basic test stimulus.
============ ==============================

Available configurations & tests combinations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The test program is compatible with the configuration.

Test stimulus
-------------------------------------------------------------------------------

The test program is responsible for configuring and running the sequencers,
while checking the data with a scoreboard. A filter class is implemented that is
used to filter data.

Environment Bringup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The steps of the environment bringup are:

* Create the environment
* Start the environment
* Start the clocks
* Assert the resets

Packet filtering testing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Filter class is implemented which is a simple data filter
* Before the resets are asserted, the filter is instantiated
* The filter is connected with the publisher filters
* The master and slave sequencers are configured and then the resets are
  asserted
* The scoreboard is subscribed to the master and slave sequencers' publisher
* The scoreboard is started
* The sequencers are started
* Scoreboard waits until the verification is complete

.. warning::

   Depending on the packet size and amount, the simulation may end before all of
   the data is verified, which may cause runtime errors!

Building the test bench
-------------------------------------------------------------------------------

The testbench is built upon ADI's generic HDL reference design framework.
ADI does not distribute compiled files of these projects so they must be built
from the sources available :git-hdl:`here </>` and :git-testbenches:`here </>`,
with the specified hierarchy described :ref:`build_tb set_up_tb_repo`.
To get the source you must
`clone <https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository>`__
the HDL repository, and then build the project as follows:

**Linux/Cygwin/WSL**

*Example 1*

Building and simulating the testbench using only the command line.

.. shell::
   :showuser:

   $cd testbenches/ip/packet_filter
   $make

*Example 2*

Building and simulating the testbench using the Vivado GUI. This command will
launch Vivado, will run the simulation and display the waveforms.

.. shell::
   :showuser:

   $cd testbenches/ip/packet_filter
   $make MODE=gui

*Example 3*

Build a particular combination of test and configuration, using the Vivado GUI.
This command will launch Vivado, will run the simulation and display the
waveforms.

.. shell::
   :showuser:

   $cd testbenches/ip/packet_filter
   $make MODE=gui CFG=cfg1 TST=test_program

The built project can be found in the ``runs`` folder, where each configuration
specific build has its own folder named after the configuration file's name.
Example: if the following command was run for a single configuration in the
clean folder (no runs folder available):

``make CFG=cfg1``

Then the subfolder under ``runs`` name will be:

``cfg1``

Resources
-------------------------------------------------------------------------------

Testbenches related dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. include:: ../../common/dependency_common.rst

Testbench specific dependencies:

.. list-table::
   :widths: 30 45 25
   :header-rows: 1

   * - SV dependency name
     - Source code link
     - Documentation link
   * - FILTER
     - :git-testbenches:`library/utilities/filter_pkg.sv`
     - ---
   * - M_AXIS_SEQUENCER
     - :git-testbenches:`library/vip/amd/m_axis_sequencer.sv`
     - ---
   * - PUBLISHER-SUBSCRIBER
     - :git-testbenches:`library/utilities/pub_sub_pkg.sv`
     - ---
   * - S_AXIS_SEQUENCER
     - :git-testbenches:`library/vip/amd/s_axis_sequencer.sv`
     - ---
   * - SCOREBOARD
     - :git-testbenches:`library/drivers/common/scoreboard.sv`
     - ---

.. include:: ../../../common/more_information.rst

.. include:: ../../../common/support.rst
