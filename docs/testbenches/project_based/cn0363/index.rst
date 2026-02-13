.. _cn0363:

CN0363
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of this testbench is to validate the SPI interface functionality
of the :git-hdl:`projects/cn0363` reference design.

The entire HDL documentation can be found here
:external+hdl:ref:`CN0363 HDL project <cn0363>`.

Block design
-------------------------------------------------------------------------------

The testbench block design includes part of the CN0363 HDL reference
design, along with VIPs used for clocking, reset, PS and DDR simulations.

Block diagram
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The data path and clock domains are depicted in the below diagram:

.. image:: ./cn0363_testbench_diagram.svg
   :width: 800
   :align: center
   :alt: CN0363/Testbench block diagram

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
   | cfg1            | 8            | 8           | 0    | 1    | 2        |
   +-----------------+--------------+-------------+------+------+----------+

Tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following test program file is available:

============ ========================================================
Test program Usage
============ ========================================================
test_program Tests the SPI Engine interface and DMA transfer
             capabilities for CN0363 colorimeter data acquisition.
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
axi_adc                   0x43C0_0000
spi_cn0363_axi_regmap     0x44A0_0000
cn0363_dma                0x44A3_0000
ddr_axi_vip               0x8000_0000
========================  ===========

Interrupts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below are the Programmable Logic interrupts used in this project:

===============  ===
Instance name    HDL
===============  ===
cn0363_dma       13
spi_cn0363       12
===============  ===

Test stimulus
-------------------------------------------------------------------------------

The test program is structured into several tests as follows:

Environment bringup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The steps of the environment bringup are:

* Create the environment
* Start the environment
* Start the clocks
* Assert the resets

Sanity test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This test verifies basic communication with the AXI register maps by:

* Reading the VERSION register from the SPI Engine AXI interface
* Testing SCRATCH register read/write functionality
* Performing sanity tests on the DMA interface

This ensures that the AXI bus communication is working correctly before
proceeding with more complex tests.

FIFO SPI test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The FIFO SPI test verifies simple serial transfers made through the SPI Engine
Execution module in FIFO mode.

The steps of this test are:

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
  testbench SDI data generator

Offload SPI test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Offload SPI test verifies the SPI Engine Offload module functionality
for autonomous data acquisition triggered by the util_sigma_delta_spi
data_ready signal.

The CN0363 design uses the util_sigma_delta_spi module to detect ADC
conversion completion and generate a trigger for the SPI Engine Offload.
The testbench simulates periodic data_ready pulses to drive the offload
transfers.

The steps of this test are:

* Configure the DMA for data transfer:

  * Enable DMA
  * Set flags (non-cyclic, TLAST enabled, partial reporting enabled)
  * Set transfer length (NUM_OF_TRANSFERS * 4 * 2 bytes)
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
* Simulate periodic ADC data_ready triggers via hierarchical reference to
  util_sigma_delta_spi
* Count completed transfers using offload SYNC IRQ events
* Wait for all transfers (NUM_OF_TRANSFERS) to complete
* Stop the offload module
* Verify that:

  * Interrupts were properly generated (IRQ test)
  * Captured SDI data at the offload output matches the expected pattern
    from the SDI data generator (Offload test)

.. note::

   In the CN0363 design, offload SDI data passes through a processing
   pipeline (phase_data_sync, HPF, CORDIC demodulator, LPF, DMA sequencer)
   before reaching DDR memory. Therefore, offload data verification is
   performed by tapping the SPI Engine Offload module's SDI output directly,
   rather than reading back from DDR.

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

   $cd testbenches/project/cn0363
   $make

*Example 2*

Build all the possible combinations of tests and configurations, using the
Vivado GUI. This command will launch Vivado, will run the simulation and display
the waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/cn0363
   $make MODE=gui

*Example 3*

Build a particular combination of test and configuration, using the Vivado GUI.
This command will launch Vivado, will run the simulation and display the
waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/cn0363
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
   * - AXI_GENERIC_ADC
     - :git-hdl:`library/axi_generic_adc`
     - ---
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
   * - UTIL_SIGMA_DELTA_SPI
     - :git-hdl:`library/util_sigma_delta_spi`
     - :external+hdl:ref:`util_sigma_delta_spi`
   * - CN0363_PHASE_DATA_SYNC
     - :git-hdl:`library/cn0363/cn0363_phase_data_sync`
     - :external+hdl:ref:`cn0363_phase_data_sync`
   * - CN0363_DMA_SEQUENCER
     - :git-hdl:`library/cn0363/cn0363_dma_sequencer`
     - :external+hdl:ref:`cn0363_dma_sequencer`
   * - CORDIC_DEMOD
     - :git-hdl:`library/cordic_demod`
     - ---

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
   * - DMAC_API
     - :git-testbenches:`library/drivers/dmac/dmac_api.sv`
     - ---
   * - SPI_ENGINE_API
     - :git-testbenches:`library/drivers/spi_engine/spi_engine_api.sv`
     - ---
   * - SPI_ENGINE_INSTR_PKG
     - :git-testbenches:`library/drivers/spi_engine/spi_engine_instr_pkg.sv`
     - ---

.. include:: ../../../common/more_information.rst

.. include:: ../../../common/support.rst
