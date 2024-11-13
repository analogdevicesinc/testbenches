.. _ad738x:

AD738x
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of this testbench is to validate the serial interface functionality
of the :git-hdl:`projects/ad738x_fmc` reference design.

The entire HDL documentation can be found here
:external+hdl:ref:`AD738x-FMC HDL project <ad738x_fmc>`.

Block design
-------------------------------------------------------------------------------

The testbench block design includes part of the AD738x-FMC HDL reference design,
along with VIPs used for clocking, reset, PS and DDR simulations.

Block diagram
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The data path and clock domains are depicted in the below diagram:

.. image:: ./ad738x_tb.svg
   :width: 800
   :align: center
   :alt: AD738x/Testbench block diagram

Configuration parameters and modes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following parameters of this project that can be configured:

-  ALERT_SPI_N: defines if a known pin will operate as a serial data output pin
   or alert indication pin:
   Options: 0 - Serial Data Output Pin, 1 - Alert Indication Ouput Pin
-  NUM_OF_SDI: defines the number of MOSI lines of the SPI interface:
   Options: 1 - Interleaved mode, 2 - 1 lane per channel,
   4 - 2 lanes per channel
   
Build parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 
The parameters mentioned above can be configured when starting the build, like in
the following example:

.. shell::
   :showuser:

   $make ALERT_SPI_N=0 NUM_OF_SDI=2
   
but we recommend using the already tested build configuration modes, that can be
found in the ``cfg`` section.
 
Configuration files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following configuration files are available:

   +-----------------------+--------------------------+
   | Configuration mode    | Parameters               |
   |                       +----------+---------------+
   |                       | ALERT_SPI_N | NUM_OF_SDI |
   +=======================+=============+============+
   | cfg1                  | 0           | 2          | 
   +-----------------------+-------------+------------+

Tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following test program file is available:

============ ========================================
Test program Usage
============ ========================================
test_program Tests the serial interface capabilities.
============ ========================================

Available configurations & tests combinations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The test program is compatible with the above mentioned configuration.

CPU/Memory interconnect addresses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below are the CPU/Memory interconnect addresses used in this project:

=========================  ===========
Instance                   Address
=========================  ===========
spi_ad738x_adc_axi_regmap  0x44A0_0000
axi_ad738x_dma             0x44A3_0000
spi_clkgen                 0x44A7_0000
spi_trigger_gen            0x44B0_0000
=========================  ===========

Interrupts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below are the Programmable Logic interrupts used in this project:

===============  ===
Instance name    HDL
===============  ===
axi_ad738x_dma   13
spi_ad738x_adc   12
===============  ===

Test stimulus
-------------------------------------------------------------------------------

The test program is structured into several tests as follows:

Environment Bringup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The steps of the environment bringup are:
* Create the environment
* Start the environment
* Start the clocks
* Assert the resets

Sanity Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This test is used to check the communication with the AXI REGMAP module of the
AD738X SPI Engine interface, by reading the core VERSION register, along with 
writing and reading the SCRATCH register.

FIFO SPI Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The FIFO SPI Test verifies the simple serial transfers, made through the
Execution module.

The steps of this test are:

* Start the SPI clock generator (axi_clkgen)
* Enable SPI Engine & configure the Execution module
* Set up the interrupts
* Generate a FIFO transaction
* Capture and compare the results, using the PEEK register of the AXI SPI Engine

Offload SPI Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Offload SPI Test verifies the Offload module functionality.

The steps of this test are:

* Configure the conversion signal generator (axi_pwmgen)
* Configure the DMA
* Configure the Offload module
* Start the Offload module
* Capture and compare the Offload SDI data

Building the test bench
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

   $cd testbenches/project/ad738x
   $make

*Example 2*

Build all the possible combinations of tests and configurations, using the
Vivado GUI. This command will launch Vivado, will run the simulation and display
the waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/ad738x
   $make MODE=gui

*Example 3*

Build a particular combination of test and configuration, using the Vivado GUI.
This command will launch Vivado, will run the simulation and display the
waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/ad738x
   $make MODE=gui CFG=cfg1 TST=test_program

The built projects can be found in the ``runs`` folder, where each configuration
specific build has it's own folder named after the configuration file's name.
Example: if the following command was run for a single configuration in the
clean folder (no runs folder available):

``make CFG=cfg1``

Then the subfolder under ``runs`` name will be:

``cfg1``

Resources
-------------------------------------------------------------------------------

HDL related dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :widths: 30 45 25
   :header-rows: 1

   * - IP name
     - Source code link
     - Documentation link
   * - AD738x_DATA_CAPTURE
     - :git-hdl:`library/ad738x_data_capture`
     - ---
   * - AXI_CLKGEN
     - :git-hdl:`library/axi_clkgen`
     - :external+hdl:ref:`here <axi_clkgen>`
   * - AXI_DMAC
     - :git-hdl:`library/axi_dmac`
     - :external+hdl:ref:`here <axi_dmac>`
   * - AXI_HDMI_TX
     - :git-hdl:`library/axi_hdmi_tx`
     - :external+hdl:ref:`here <axi_hdmi_tx>`
   * - AXI_I2S_ADI
     - :git-hdl:`library/axi_i2s_adi`
     - ---
   * - AXI_PWM_GEN
     - :git-hdl:`library/axi_pwm_gen`
     - :external+hdl:ref:`here <axi_pwm_gen>`
   * - AXI_SPDIF_TX
     - :git-hdl:`library/axi_spdif_tx`
     - ---
   * - AXI_SPI_ENGINE
     - :git-hdl:`library/spi_engine/axi_spi_engine`
     - :external+hdl:ref:`here <spi_engine axi>`
   * - SPI_AXIS_REORDER
     - :git-hdl:`library/spi_engine/spi_axis_reorder`
     - ---
   * - SPI_ENGINE_EXECUTION
     - :git-hdl:`library/spi_engine/spi_engine_execution`
     - :external+hdl:ref:`here <spi_engine execution>`
   * - SPI_ENGINE_INTERCONNECT
     - :git-hdl:`library/spi_engine/spi_engine_interconnect`
     - :external+hdl:ref:`here <spi_engine interconnect>`
   * - SPI_ENGINE_OFFLOAD
     - :git-hdl:`library/spi_engine/spi_engine_offload`
     - :external+hdl:ref:`here <spi_engine offload>`
   * - SYSID_ROM
     - :git-hdl:`library/sysid_rom`
     - :external+hdl:ref:`here <axi_sysid>`
   * - UTIL_I2C_MIXER
     - :git-hdl:`library/util_i2c_mixer <library/util_i2c_mixer>`
     - ---

Testbenches related dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
   * - DMA_TRANS
     - :git-testbenches:`library/drivers/dmac/dma_trans.sv`
     - ---
   * - DMAC_API
     - :git-testbenches:`library/drivers/dmac/dmac_api.sv`
     - ---
   * - LOGGER_PKG
     - :git-testbenches:`library/utilities/logger_pkg.sv`
     - ---     
   * - M_AXI_SEQUENCER
     - :git-testbenches:`library/vip/amd/m_axi_sequencer.sv`
     - ---
   * - M_AXIS_SEQUENCER
     - :git-testbenches:`library/vip/amd/m_axis_sequencer.sv`
     - ---
   * - REG_ACCESSOR
     - :git-testbenches:`library/regmaps/reg_accessor.sv`
     - ---                            
   * - S_AXI_SEQUENCER
     - :git-testbenches:`library/vip/amd/s_axi_sequencer.sv`
     - ---
   * - S_AXIS_SEQUENCER
     - :git-testbenches:`library/vip/amd/s_axis_sequencer.sv`
     - ---     
   * - UTILS
     - :git-testbenches:`library/utilities/utils.svh`
     - ---

.. include:: ../../common/more_information.rst

.. include:: ../../common/support.rst
