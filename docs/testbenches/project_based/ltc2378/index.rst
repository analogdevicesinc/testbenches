.. _ltc2378:

LTC2378
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of this testbench is to validate the SPI interface functionality
of the :git-hdl:`projects/ltc2378_fmc` reference design.

The entire HDL documentation can be found here
:external+hdl:ref:`LTC2378 HDL project <ltc2378_fmc>`.

Block design
-------------------------------------------------------------------------------

The testbench block design includes part of the LTC2378-FMC HDL reference
design, along with VIPs used for clocking, reset, PS and DDR simulations.

Block diagram
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The data path and clock domains are depicted in the below diagram:

.. image:: ./ltc2378_testbench_diagram.svg
   :width: 800
   :align: center
   :alt: LTC2378/Testbench block diagram

Configuration parameters and modes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following parameters of this project can be configured:

-  DATA_WIDTH: defines the SPI data width in bits
-  DATA_DLENGTH: defines the actual data length being transferred
-  NUM_OF_CS: defines the number of chip select lines
-  THREE_WIRE: enables three-wire SPI mode:
   Options: 0 - Four-wire mode, 1 - Three-wire mode
-  CPOL: defines the SPI clock polarity:
   Options: 0 - Clock idle state is low, 1 - Clock idle state is high
-  CPHA: defines the SPI clock phase:
   Options: 0 - Data captured on first edge, 1 - Data captured on second edge
-  CLOCK_DIVIDER: defines the SPI clock divider value
-  NUM_OF_WORDS: defines the number of words per transfer
-  SDO_IDLE_STATE: defines the SDO idle state:
   Options: 0 - Low, 1 - High

Configuration files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following configuration file is available:

   +-----------------+--------------+-------------+------+------+----------+
   | Configuration   | Parameters                                          |
   | mode            +--------------+-------------+------+------+----------+
   |                 | DATA_WIDTH   | DATA_DLENGTH| CPOL | CPHA | NUM_OF_CS|
   +=================+==============+=============+======+======+==========+
   | cfg1            | 32           | 20          | 0    | 1    | 1        |
   +-----------------+--------------+-------------+------+------+----------+

Tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following test program file is available:

============ ========================================================
Test program Usage
============ ========================================================
test_program Tests the SPI Engine interface and DMA transfer
             capabilities for LTC2378 ADC data acquisition.
============ ========================================================

Available configurations & tests combinations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The test program is compatible with all of the above mentioned configurations.

CPU/Memory interconnect addresses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below are the CPU/Memory interconnect addresses used in this project:

========================  ===========
Instance                  Address
========================  ===========
axi_intc                  0x4120_0000
spi_ltc2378_axi_regmap    0x44A0_0000
ltc2378_dma               0x44A3_0000
spi_clkgen                0x44A7_0000
ltc2378_trigger_gen       0x44B0_0000
ddr_axi_vip               0x8000_0000
========================  ===========

Interrupts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below are the Programmable Logic interrupts used in this project:

===============  ===
Instance name    HDL
===============  ===
ltc2378_dma      13
spi_ltc2378      12
===============  ===

Test stimulus
-------------------------------------------------------------------------------

The test program is structured into several tests as follows:

Environment bringup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The steps of the environment bringup are:

* Create the environment
* Start the environment
* Start the clocks (including external 100MHz clock VIP for PWM generator)
* Assert the resets

Sanity test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This test verifies basic communication with the AXI register maps by:

* Reading the VERSION register from the SPI Engine AXI interface
* Testing SCRATCH register read/write functionality
* Performing sanity tests on the DMA and PWM generator interfaces

This ensures that the AXI bus communication is working correctly before
proceeding with more complex tests.

FIFO SPI test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The FIFO SPI test verifies simple serial transfers made through the SPI Engine
Execution module in FIFO mode.

The steps of this test are:

* Start the SPI clock generator (axi_clkgen) to provide the SPI interface
  clock
* Configure the conversion signal generator (axi_pwm_gen) to generate
  periodic CNV pulses:

  * PWM_0 generates the CNV signal with 1µs period (100MHz clock,
    period=100 cycles)
  * PWM_1 generates the offload trigger with appropriate timing offset
    (620ns = 62 cycles)

    * This timing accounts for tCONV + tBUSYLH + tDSOBUSYL delays

* Enable the SPI Engine and configure the Execution module with transfer
  parameters
* Set up the interrupt mask to enable SYNC and offload SYNC interrupts
* Write test data (0xDEAD) to the SDO FIFO
* Generate a FIFO transaction using SPI Engine commands:

  * Assert chip select
  * Transfer data word
  * De-assert chip select
  * Generate SYNC interrupt

* Wait for the SYNC interrupt to indicate transfer completion
* Read back the captured data from the SDI FIFO using the PEEK register
* Compare the received data with the expected pattern generated by the
  testbench BFM

Offload SPI test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Offload SPI test verifies the SPI Engine Offload module functionality
for autonomous data acquisition triggered by external events.

The steps of this test are:

* Configure the DMA for data transfer:

  * Enable DMA
  * Set flags (non-cyclic, TLAST enabled, partial reporting enabled)
  * Set transfer length (NUM_OF_TRANSFERS * 4 bytes)
  * Set destination address in DDR memory
  * Start the DMA transfer

* Configure the Offload module with SPI Engine command sequence:

  * Configuration command (INST_CFG)
  * Prescaler setting (INST_PRESCALE)
  * Data length configuration (INST_DLENGTH)
  * Assert chip select
  * Read command (INST_RD)
  * De-assert chip select
  * SYNC command with ID=2 to generate interrupt

* Start the offload module to begin autonomous operation
* Wait for all transfers (NUM_OF_TRANSFERS - 4) to complete
* Stop the offload module
* Read back the captured data from DDR memory using backdoor access
* Verify that:

  * Interrupts were properly generated (IRQ test)
  * Captured data matches the expected SDI pattern from the BFM (Offload test)

Stop the environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Stop the clocks

Building the testbench
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

Build all the possible combinations of tests and configurations, using only the
command line.

.. shell::
   :showuser:

   $cd testbenches/project/ltc2378
   $make

*Example 2*

Build all the possible combinations of tests and configurations, using the
Vivado GUI. This command will launch Vivado, will run the simulation and display
the waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/ltc2378
   $make MODE=gui

*Example 3*

Build a particular combination of test and configuration, using the Vivado GUI.
This command will launch Vivado, will run the simulation and display the
waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/ltc2378
   $make MODE=gui CFG=cfg1 TST=test_program

The built projects can be found in the ``runs`` folder, where each configuration
specific build has its own folder named after the configuration file's name.
Example: if the following command was run for a single configuration in the
clean folder (no runs folder available):

``make CFG=cfg1``

Then the subfolder under ``runs`` name will be:

``cfg1``

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
   * - AXI_CLKGEN
     - :git-hdl:`library/axi_clkgen`
     - :external+hdl:ref:`axi_clkgen`
   * - AXI_DMAC
     - :git-hdl:`library/axi_dmac`
     - :external+hdl:ref:`axi_dmac`
   * - AXI_PWM_GEN
     - :git-hdl:`library/axi_pwm_gen`
     - :external+hdl:ref:`axi_pwm_gen`
   * - AXI_SPI_ENGINE
     - :git-hdl:`library/spi_engine/axi_spi_engine`
     - :external+hdl:ref:`spi_engine axi`
   * - SPI_ENGINE_EXECUTION
     - :git-hdl:`library/spi_engine/spi_engine_execution`
     - :external+hdl:ref:`spi_engine execution`
   * - SPI_ENGINE_INTERCONNECT
     - :git-hdl:`library/spi_engine/spi_engine_interconnect`
     - :external+hdl:ref:`spi_engine interconnect`
   * - SPI_ENGINE_OFFLOAD
     - :git-hdl:`library/spi_engine/spi_engine_offload`
     - :external+hdl:ref:`spi_engine offload`

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
   * - ADI_REGMAP_CLKGEN_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_clkgen_pkg.sv`
     - ---
   * - ADI_REGMAP_DMAC_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_dmac_pkg.sv`
     - ---
   * - ADI_REGMAP_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_pkg.sv`
     - ---
   * - ADI_REGMAP_PWM_GEN_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_pwm_gen_pkg.sv`
     - ---
   * - ADI_REGMAP_SPI_ENGINE_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_spi_engine_pkg.sv`
     - ---
   * - CLK_GEN_API
     - :git-testbenches:`library/drivers/clk_gen/clk_gen_api.sv`
     - ---
   * - DMAC_API
     - :git-testbenches:`library/drivers/dmac/dmac_api.sv`
     - ---
   * - PWM_GEN_API
     - :git-testbenches:`library/drivers/pwm_gen/pwm_gen_api.sv`
     - ---
   * - SPI_ENGINE_API
     - :git-testbenches:`library/drivers/spi_engine/spi_engine_api.sv`
     - ---
   * - SPI_ENGINE_INSTR_PKG
     - :git-testbenches:`library/drivers/spi_engine/spi_engine_instr_pkg.sv`
     - ---

.. include:: ../../../common/more_information.rst

.. include:: ../../../common/support.rst
