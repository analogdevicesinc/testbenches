.. _i3c_controller:

I3C Controller
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of this testbench is to test the :git-hdl:`library/i3c_controller`.

The I3C Controller IP cores implement a subset of the I3C-basic specification to
interface peripherals through I3C.

The entire HDL documentation can be found at
:external+hdl:ref:`i3c_controller`.

Block design
-------------------------------------------------------------------------------

The block design is based on the test harness with the addition of the
I3C Controller Host Interface and I3C Controller Core, and a DMA for offload
transfers testing.

Block diagram
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. image:: ./block_diagram.svg
   :width: 500
   :align: center
   :alt: I3C Controller/Testbench block diagram

Configuration parameters and modes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following parameter of this project that can be configured:

- CLK_MOD: defines the I3C Controller Core clock cycles per bus bit.

Build parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The parameter mentioned above can be configured when starting the build, like
in the following example:

.. shell::
   :showuser:

   $make CLK_MOD=1

Configuration files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following configuration files are available:

+-----------------------+------------+
| Configuration mode    | Parameters |
|                       +------------+
|                       | CLK_MOD    |
+=======================+============+
| cfg1                  | 0          |
+-----------------------+------------+
| cfg2                  | 1          |
+-----------------------+------------+

Tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following test program file is available:

======================== ========================================================
Test program             Usage
======================== ========================================================
test_program             Test the I3C Controller core.
======================== ========================================================

Available configurations & tests combinations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The cfg1 and cf2 are compatible with test_program.

CPU/Memory interconnects addresses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

=============== ===========
Instance        Address
=============== ===========
ddr_axi_vip     0x8000_0000
i3c_controller  0x44A0_0000
=============== ===========

Interrupts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+---------------+-----+
| Instance name | HDL |
+===============+=====+
| i3c           | 12  |
+---------------+-----+

Test stimulus
-------------------------------------------------------------------------------

The test program provides the instructions, test data
and I3C Bus stimulus directly.
There is no I3C Bus VIP or I3C API on the test bench.

Environment Bring up
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The steps of the environment bring up are:

* Create the environment
* Start the environment
* Start the clocks
* Assert the resets

I3C Controller testing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Initializes the sequencers, monitors and scoreboards.
* Do sanity test on I3C Controller's version, id, and scratch register.
* Enable I3C Controller.
* Write device characteristics to the I3C Controller memory
  (in hardware handled by the software driver).
* Test individual I3C transfers:

  - Dynamic Address Assignment (DAA).
  - Common Command Codes (CCC).
  - Private I3C transfer.
  - Private I2C transfer (backwards compatibility).
  - Offload operation (SDI data is streamed to the DMA).
  - In-band interrupt (IBI)

* Stops the watchdog

Due to the lack of a I3C Controller VIP, the monitoring and mocking and generate
by the `test_program.sv` itself.

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

   $cd testbenches/ip/i3c_controller
   $make

*Example 2*

Building and simulating the testbench using the Vivado GUI. This command will
launch Vivado, will run the simulation and display the waveforms.

.. shell::
   :showuser:

   $cd testbenches/ip/i3c_controller
   $make MODE=gui

*Example 3*

Build a particular combination of test and configuration, using the Vivado GUI.
This command will launch Vivado, will run the simulation and display the
waveforms.

.. shell::
   :showuser:

   $cd testbenches/ip/dma_flock
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

There are no testbench specific dependencies.

.. include:: ../../../common/more_information.rst

.. include:: ../../../common/support.rst
