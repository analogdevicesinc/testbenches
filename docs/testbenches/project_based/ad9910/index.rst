.. _ad9910:

AD9910
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of this testbench is to validate the Digital Ramp Generator (DRG)
functionality of the :git-hdl:`projects/ad9910` reference design.

The testbench exercises the AXI-based controller (``axi_ad9910``) that drives
the AD9910 Direct Digital Synthesizer (DDS), focusing on the DRG operating
mode. It verifies ramp generation, hold control, profile selection, and
sawtooth/burst sequencing features.

The entire HDL documentation can be found here
:external+hdl:ref:`AD9910 HDL project <ad9910>`.

Block design
-------------------------------------------------------------------------------

The testbench block design includes the ``axi_ad9910`` IP core along with VIPs
used for clocking, reset, PS and DDR simulations. The ``sync_clk`` and
``pd_clk`` signals are generated directly in the testbench at 250 MHz to
simulate the clock outputs of the AD9910 device. The AXI-Stream input of
``axi_ad9910`` is tied off (unused in DRG mode).

Block diagram
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The data path and clock domains are depicted in the below diagram:

.. image:: ./ad9910_drg_tb.svg
   :width: 800
   :align: center
   :alt: AD9910 DRG Testbench block diagram

Configuration parameters and modes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following parameter of this project can be configured:

-  MODE: Defines the operating mode of the AD9910 controller.
   Options: DRG - Digital Ramp Generator mode

Configuration files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following configuration files are available:

+----------+------------+
| Configu- | Parameters |
| ration   +------------+
| mode     | MODE       |
+==========+============+
| cfg1_drg | DRG        |
+----------+------------+

Tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following test program files are available:

==================== =============================================
Test program         Usage
==================== =============================================
test_program_drg     Tests the DRG mode of the AD9910 controller.
==================== =============================================

Available configurations & tests combinations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The test program is compatible with all of the above mentioned configurations.

=============== ==================== ==========================================
Configuration   Test                 Build command
=============== ==================== ==========================================
cfg1_drg        test_program_drg     make CFG=cfg1_drg TST=test_program_drg
=============== ==================== ==========================================

CPU/Memory interconnect addresses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below are the CPU/Memory interconnect addresses used in this project:

=========================  ===========
Instance                   Address
=========================  ===========
axi_ad9910                 0x44A0_0000
=========================  ===========

Test stimulus
-------------------------------------------------------------------------------

The testbench includes a behavioral DRG counter model that runs concurrently
with the test sequence. The model simulates the AD9910's internal 18-bit
digital ramp generator, tracking the ramp counter value, limit detection, and
drover signal generation. It supports triangle, sawtooth up, and sawtooth down
modes, as well as burst blade limiting with auto-hold.

DRG model parameters
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following parameters are fixed in the DRG behavioral model:

-  DRG_LOWER_LIMIT: 1000 (ramp lower boundary)
-  DRG_UPPER_LIMIT: 5000 (ramp upper boundary)
-  DRG_STEP_SIZE: 15 (increment/decrement per sync_clk cycle)

test_program_drg
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The test program is structured into the following tests:

Environment bringup
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The steps of the environment bringup are:

* Create the test harness environment
* Start the environment
* Assert the system reset

Sanity test (Test 1)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This test checks the communication with the ``axi_ad9910`` AXI register map:

* Read the VERSION register and log its value
* Read the ID register and log its value
* Write and read back the SCRATCH register (expected value: ``0xDEADBEEF``)

Device reset sequence (Test 2)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Write ``0x00000000`` to the CONTROL register to release all resets
* Read the SYNC_CLK_CNT register before and after a 1 µs delay to confirm the
  sync clock is running
* Verify that ``main_reset``, ``io_reset``, and ``pw_down`` are all deasserted
* Initialize and enable the DRG behavioral model

DRG mode configuration (Test 3)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Write BST_DELAY (before-start delay): 250 sync_clk cycles
* Write ALR_DELAY (after-level-reached delay): 75 sync_clk cycles
* Write BURST_DELAY (inter-burst delay): 200 sync_clk cycles
* Write RAMP_BURSTS (blades per burst): 5
* Write RAMP_CTRL: enable drctl toggle mode and set drctl_init high
  (``0x0C``: ``drctl_toggle_en=1``, ``drctl_init=1``)
* Read back and verify BST_DELAY and RAMP_CTRL registers
* Write to IO_UPDATE register and verify the ``io_update`` output pulses
  within 5 µs

Ramp operation (Test 4)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Wait up to 10 µs for ``drctl`` to assert (ramp starts automatically after
  BST_DELAY elapses following configuration)
* Wait for the DRG model to reach the upper limit (1 drover pulse)
* Log the current DRG counter value

Ramp toggle cycle (Test 4b)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Reset the DRG counter to the lower limit
* Wait for 3 drover pulses to confirm a complete up-down-up triangle cycle
* Log the final counter value and pulse count

Profile selection (Test 5)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Write value ``2`` to the PROFILE register
* Wait 5 µs for CDC propagation
* Verify the ``profile[2:0]`` output equals ``3'b010``

DRHOLD control (Test 6)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Reset the DRG counter and let it ramp for 2 µs
* Set the DRHOLD bit in RAMP_CTRL (``0x0E``)
* Wait for ``drhold`` to assert (up to 10 µs for CDC propagation)
* Record the counter value at the moment hold becomes active
* Wait 3 µs and verify the counter has not changed (counter frozen)
* Clear the DRHOLD bit (``0x0C``) and wait 2 µs for deassertion
* Verify ``drhold`` deasserts
* Wait 3 µs and verify the counter resumes or remains at a limit boundary

Sawtooth UP with inter-blade delay (Test 7)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This test verifies that after each sawtooth blade reaches the upper limit, the
DRG pauses for ALR_DELAY sync_clk cycles before the next blade begins:

* Read BST_DELAY and ALR_DELAY from the DUT registers
* Enable sawtooth UP mode (``NO_DWELL_HIGH``) with auto-hold after 1 blade
* Write RAMP_CTRL: ``no_dwell_high=1``, ``drctl_toggle_en=1``,
  ``drctl_init=1`` (``0x2C``)
* Reset the DRG counter
* Wait BST_DELAY cycles before the first blade starts
* For each of 5 blades:

  * Release the burst hold to start the blade
  * Wait for the blade to reach the upper limit (1 drover pulse)
  * Verify the model auto-held at the limit
  * Apply ALR_DELAY inter-blade delay and verify the counter stays frozen
    during the delay (except after the last blade)

* Verify that exactly 5 blades completed

Burst mode (Test 8)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This test verifies burst sequencing driven by REG_RAMP_BURSTS and
REG_BURST_DELAY register values:

* Read RAMP_BURSTS and BURST_DELAY from the DUT registers
* Enable sawtooth UP mode with auto-hold after ``blades_per_burst`` blades
* Write RAMP_CTRL: ``no_dwell_high=1``, ``drctl_toggle_en=1``,
  ``drctl_init=1`` (``0x2C``)
* Reset the DRG counter

Burst 1:

* Wait for ``blades_per_burst`` (5) sawtooth blades to complete
* Verify that exactly 5 blades occurred
* Verify the model auto-held after the burst

Burst delay:

* Wait BURST_DELAY (200) sync_clk cycles
* Verify the counter remains frozen throughout the delay

Burst 2:

* Release the burst hold and start a new burst
* Wait for ``blades_per_burst`` blades to complete
* Verify that exactly 5 blades occurred

Sawtooth DOWN mode (Test 9)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This test verifies sawtooth DOWN behavior using the ``NO_DWELL_LOW`` mode,
where the ramp always decrements and snaps back to the upper limit on reaching
the lower limit:

* Enable sawtooth DOWN mode with auto-hold after 5 blades
* Write RAMP_CTRL: ``no_dwell_low=1``, ``drctl_toggle_en=1``,
  ``drctl_init=1`` (``0x1C``)
* Reset the DRG counter to the upper limit (sawtooth down starts from the top)
* Wait for all 5 blades to complete continuously (no inter-blade delay)
* Verify the model auto-held after 5 blades
* Verify that exactly 5 blades completed

Stop the environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Stop the test harness environment
* Report overall pass/fail status

Building the testbench
-------------------------------------------------------------------------------

The testbench is built upon ADI's generic HDL reference design framework.
ADI does not distribute compiled files of these projects so they must be built
from the sources available :git-hdl:`here </>` and :git-testbenches:`here </>`,
with the specified hierarchy described :ref:`build_tb set_up_tb_repo`.
To get the source you must
`clone <https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository>`__
the HDL repository, and then build the project as follows:.

**Linux/Cygwin/WSL**

*Example 1*

Build all the possible combinations of tests and configurations, using only the
command line.

.. shell::
   :showuser:

   $cd testbenches/project/ad9910
   $make

*Example 2*

Build all the possible combinations of tests and configurations, using the
Vivado GUI. This command will launch Vivado, will run the simulation and display
the waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/ad9910
   $make MODE=gui

*Example 3*

Build a particular combination of test and configuration, using the Vivado GUI.
This command will launch Vivado, will run the simulation and display the
waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/ad9910
   $make MODE=gui CFG=cfg1_drg TST=test_program_drg

The built projects can be found in the ``runs`` folder, where each configuration
specific build has it's own folder named after the configuration file's name.
Example: if the following command was run for a single configuration in the
clean folder (no runs folder available):

``make CFG=cfg1_drg``

Then the subfolder under ``runs`` name will be:

``cfg1_drg``

Resources
-------------------------------------------------------------------------------

HDL related dependencies forming the DUT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :widths: 30 45 25
   :header-rows: 1

   * - IP name
     - Source code link
     - Documentation link
   * - AXI_AD9910
     - :git-hdl:`library/axi_ad9910`
     - :external+hdl:ref:`axi_ad9910`

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
   * - ADI_REGMAP_COMMON_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_common_pkg.sv`
     - ---
   * - ADI_REGMAP_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_pkg.sv`
     - ---
   * - AXI_VIP_PKG
     - ---
     - :xilinx:`AXI Verification IP (VIP) <products/intellectual-property/axi-vip.html>`

.. include:: ../../../common/more_information.rst

.. include:: ../../../common/support.rst
