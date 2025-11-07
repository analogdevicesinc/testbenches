.. _adrv9009:

ADRV9009
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of this testbench is to validate the serial interface functionality
of the :git-hdl:`projects/adrv9009` reference design.

The entire HDL documentation can be found here
:external+hdl:ref:`ADRV9009 HDL project <adrv9009>`.

Block design
-------------------------------------------------------------------------------

The testbench block design includes part of the ADRV9009 HDL reference design,
along with JESD exercisers and VIPs used for clocking, reset, PS and DDR
simulations.

Block diagram
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The data path and clock domains are depicted in the below diagram:

.. image:: ./adrv9009_tb.svg
   :width: 800
   :align: center
   :alt: adrv9009/Testbench block diagram

Configuration parameters and modes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following parameters of this testbench that can be configured:

- LINK_MODE: the JESD204B link mode (1: JESD_8B10B encoding; 2: JESD_64B66B
  encoding)
- REF_CLK_RATE: the rate of the reference clock in MHz
- LANE_RATE: the JESD204B lane rate in Gbps
- DAC_OFFLOAD_TYPE: the type of DAC offload
- DAC_OFFLOAD_SIZE: the size of DAC offload
- PLDDR_OFFLOAD_DATA_WIDTH: the data width of the PL DDR offload interface
- [RX/TX/RX_OS]_JESD_M: number of converters per link
- [RX/TX/RX_OS]_JESD_L: number of lanes per link
- [RX/TX/RX_OS]_JESD_S: number of samples per frame
- [RX/TX/RX_OS]_JESD_NP: number of bits per sample
- [RX/TX/RX_OS]_JESD_F: number of octets per frame per lane
- [RX/TX/RX_OS]_JESD_K: number of framer per multiframe

Configuration files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following configuration files are available:

.. list-table::
   :header-rows: 1

   * - Parameter
     - cfg1
     - cfg2 
     - cfg3
     - cfg4
   * - LINK_MODE
     - 1
     - 1
     - 1
     - 1
   * - REF_CLK_RATE 
     - 500
     - 500
     - 500
     - 500
   * - LANE_RATE
     - 10
     - 10
     - 10
     - 10 
   * - DAC_OFFLOAD_TYPE
     - 0
     - 0
     - 0
     - 0
   * - DAC_OFFLOAD_SIZE
     - [expr 2*1024*1024]
     - [expr 2*1024*1024]
     - [expr 2*1024*1024]
     - [expr 2*1024*1024]
   * - PLDDR_OFFLOAD_DATA_WIDTH
     - 0
     - 0
     - 0
     - 0
   * - TX_JESD_M
     - 2
     - 2
     - 4
     - 4
   * - TX_JESD_L 
     - 1
     - 2
     - 2
     - 4
   * - TX_JESD_S
     - 1
     - 1
     - 1
     - 1
   * - TX_JESD_NP
     - 16
     - 16
     - 16
     - 16
   * - TX_JESD_F
     - 4
     - 2
     - 4
     - 2
   * - TX_JESD_K
     - 32
     - 32
     - 32
     - 32
   * - RX_JESD_M
     - 4
     - 4
     - 4
     - 4
   * - RX_JESD_L
     - 1
     - 1
     - 2
     - 2
   * - RX_JESD_S
     - 1
     - 1
     - 1
     - 1
   * - RX_JESD_NP
     - 16
     - 16
     - 16
     - 16
   * - RX_JESD_F
     - 8
     - 8
     - 4
     - 4
   * - RX_JESD_K
     - 32
     - 32
     - 32
     - 32
   * - RX_OS_JESD_M
     - 2
     - 2
     - 4
     - 2
   * - RX_OS_JESD_L
     - 1
     - 1
     - 2
     - 2
   * - RX_OS_JESD_S
     - 1
     - 1
     - 1
     - 1
   * - RX_OS_JESD_NP
     - 16
     - 16
     - 16
     - 16
   * - RX_OS_JESD_F
     - 4
     - 4
     - 4
     - 2
   * - RX_OS_JESD_K
     - 32
     - 32
     - 32
     - 32

Tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following test program file is available:

============ ========================================
Test program Usage
============ ========================================
test_program Tests the adrv9009 project capabilities.
============ ========================================

Available configurations & tests combinations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The test program is compatible with the above mentioned configurations.

CPU/Memory interconnect addresses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below are the CPU/Memory interconnect addresses used in this project:

==============================  ===========
Instance                        Address
==============================  ===========
axi_intc                        0x4120_0000
axi_adrv9009_tx_clkgen          0x43C0_0000
axi_adrv9909_rx_clkgen          0x43C1_0000
axi_adrv9009_rs_os_clkgen       0x43C2_0000
rx_adrv9009_tpl_core            0x44A0_0000
tx_adrv9009_tpl_core            0x44A0_4000
rx_os_adrv9009_tpl_core         0x44A0_8000
rx_jesd_exerciser/axi_jesd      0x44A1_0000
rx_jesd_exerciser/axi_xcvr      0x44A2_0000
rx_jesd_exerciser/rx_tpl_core   0x44A3_0000
tx_jesd_exerciser/axi_jesd      0x44A4_0000
axi_adrv9009_rx_os_xcvr         0x44A5_0000
axi_adrv9009_rx_xcvr            0x44A6_0000
tx_jesd_exerciser/axi_xcvr      0x44A7_0000
axi_adrv9009_tx_xcvr            0x44A8_0000
axi_adrv9009_tx_jesd            0x44A9_0000
axi_adrv9009_rx_jesd            0x44AA_0000
axi_adrv9009_rx_os_jesd         0x44AB_0000
tx_jesd_exerciser/tx_tpl_core   0x44AC_0000
tx_os_exerciser/axi_jesd        0x44AD_0000
tx_os_exerciser/axi_xcvr        0x44AE_0000
tx_os_exerciser/tx_tpl_core     0x44AF_0000
axi_adrv9009_rx_dma             0x7C40_0000
axi_adrv9009_tx_dma             0x7C42_0000
adrv9009_data_offload           0x7C43_0000
axi_adrv9009_rx_os_dma          0x7C44_0000
ddr_axi_vip                     0x8000_0000
==============================  ===========

Interrupts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Below are the Programmable Logic interrupts used in this project:

=======================  ===
Instance name            HDL
=======================  ===
axi_adrv9009_rx_jesd     15
axi_adrv9009_rx_os_dma   14
axi_adrv9009_tx_dma      13
axi_adrv9009_rx_dma      12
axi_adrv9009_rx_os_jesd  8
axi_adrv9009_tx_jesd     7
=======================  ===

Test stimulus
-------------------------------------------------------------------------------

The test program is structured into several tests as follows:

Environment bringup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The steps of the environment bringup are:

* Create the environment
* Start the environment
* Assert the resets

JESD objects initialization, link-layer and transceiver interface setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Create and configure the JESD204 link objects used in the testbench: TX, RX,
  and RX_OS. Each link is instantiated and its key parameters are set based on
  the project configuration macros.
* Instantiate and initialize AXI-accessible verification components that model
  both the DUT and the external (EX) JESD204 interfaces. Each component is
  connected to the common AXI master sequencer within the base environment and
  linked to its corresponding JESD link configuration object.
* The `probe()` method is called for each instance to read and verify initial
  register states, confirming correct connectivity to the mapped AXI address
  regions.

Clock frequency configuration and JESD device clock setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* The reference clock (`REF_CLK`) is initialized based on the project’s
  configured reference rate (`REF_CLK_RATE`), converted to Hz.
* Each JESD link-layer model (RX, TX, TX_OS) computes its respective device
  clock frequency using its internal parameters via `calc_device_clk()`.
* The calculated device clocks are then applied to the corresponding clock
  interface handles in the test harness (`TH`), ensuring that all simulated
  clock domains (RX, TX, TX_LINK, TX_OS) run at frequencies consistent with
  the configured JESD link settings.
* Similarly, each link-layer model computes its SYSREF clock via
  `calc_sysref_clk()`, providing the synchronized SYSREF timing used for
  deterministic latency alignment in JESD204 systems.

Clock startup, transceiver configuration, and test execution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* SYSREF clock assignment
   - The common SYSREF frequency is applied to the SYSREF clock interface.
* Start all clocks
   - All relevant clock domains (REF_CLK, RX/TX/TX_LINK/TX_OS device clocks,
     and SYSREF) are started to begin simulation timing.
* Transceiver clock setup
   - External (ex_*) and DUT (dut_*) transceivers are configured via
     `setup_clocks()` using the lane rate and reference clock.
   - DUT transceivers also specify the PLL type (CPLL/QPLL) where required.

Test execution
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Template pattern tests for TX, RX, and RX_OS paths are executed. These tasks
configure and execute JESD204 template pattern tests for the TX, RX, and RX
observation (RX_OS) paths in the testbench. They support both DDS-generated
tones and DMA-based stimulus depending on the `use_dds` parameter (`int use_dds`
– if non-zero, the external DAC uses DDS-generated tones; otherwise, DMA data
is used).

TX TPL test
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* **Initialize DMA-based stimulus (if use_dds == 0)**

  - Write a deterministic pattern to DDR memory using the ``BackdoorWrite32`` 
    interface of the DDR slave sequencer.
  - Configure the TX DMA engine by writing to its registers:

    - Enable DMA.
    - Set TLAST flag. 
    - Set transfer length.
    - Set source address to DDR base.
    - Submit DMA transfer.
    - Wait for 5 µs to ensure the DMA is configured.

* **Configure DAC TPL channels**

  - Iterate over each TX lane:

    - If ``use_dds`` is enabled:

      - Select DDS as the data source.
      - Configure tone amplitude (``DDS_SCALE_1``) and frequency
        (``DDS_INCR_1``).
    
    - Otherwise:

      - Select DMA as the source for the DAC template pattern.

* **Enable external ADC TPL channels**

  - Iterate over all TX lanes and enable the corresponding ADC TPL channels via
    ``CHAN_CNTRL`` register.

* **Release DAC and ADC resets**

  - Write ``RSTN = 1`` to ``DAC_COMMON_REG_RSTN`` and ``ADC_COMMON_REG_RSTN``.

* **Synchronize DDS cores (if use_dds == 1)**

   - Write to the DAC common control register to trigger synchronization.

* **Bring up the DUT TX path and external RX path**

   - Start the TX clock generator (`AXI_CLKGEN_TX_BA`) and bring up the DUT TX
     transceiver.
   - Bring up the external RX transceiver and link.
   - Wait for both DUT and external link layers to report link-up status.

* **Simulation delay**

   - Wait for 10 µs to allow data flow and link stabilization.

* **Bring down the links**

   - Shut down the transceivers to conclude the test.

RX TPL test
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* **Configure external DAC TPL channels**

   - Iterate over all RX lanes (`i = 0..RX_JESD_M-1`):

     - If `use_dds` is enabled:

       - Select DDS as the data source for the DAC TPL channel.
       - Set the tone amplitude (`DDS_SCALE_1`) and frequency increment
         (`DDS_INCR_1`).

     - Otherwise:

       - Select DMA as the data source for the DAC TPL channel.

* **Enable ADC TPL Channels**

   - Iterate over all RX lanes and enable the corresponding ADC channels via
     `CHAN_CNTRL` register.

* **Release DAC and ADC Resets**

   - Deassert reset (`RSTN = 1`) for both the external DAC TPL and ADC TPL
     common blocks.

* **Bring up DUT RX and External TX Paths**

   - Start the RX clock generator (`AXI_CLKGEN_RX_BA`) for the DUT.
   - Bring up the external TX transceiver and link.
   - Bring up the DUT RX transceiver and link.
   - Wait for both DUT and external link layers to report link-up.

* **Simulation delay**

   - Wait for 10 µs to allow data flow and link stabilization.

* **Configure RX DMA (if `use_dds == 0`)**

   - Enable the RX DMA engine and configure:

     - Control register (enable DMA).
     - Flags (TLAST).
     - Transfer length.
     - Destination address in DDR.
     - Submit DMA transfer.

   - Wait for 5 µs to allow DMA to start.

* **Check Captured Data**

   - Call the `check_captured_data` function to verify that the data received
     from the TX path is correctly captured in DDR:

     - Parameters: address, length, step, max_sample.

* **Shutdown RX Path**

   - Bring down the DUT RX and external TX transceivers to conclude the test.

RX OS TPL test
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* **Configure External DAC OS TPL Channels**

   - Iterate over all RX_OS lanes (`i = 0..RX_OS_JESD_M-1`):

     - If `use_dds` is enabled:

       - Select DDS as the data source for each DAC OS TPL channel.
       - Set the tone amplitude (`DDS_SCALE_1`) and frequency increment
         (`DDS_INCR_1`).

     - Otherwise:

       - Select DMA as the source for DAC OS TPL channels.

* **Enable ADC OS TPL Channels**

   - Iterate over all RX_OS lanes and enable the corresponding ADC OS channels
     via `CHAN_CNTRL` register.

* **Release DAC and ADC OS Resets**

   - Deassert reset (`RSTN = 1`) for both the external DAC OS TPL and ADC OS TPL
     common blocks.

* **Bring up DUT RX Observation and External TX Observation Paths**

   - Start the RX OS clock generator (`AXI_CLKGEN_RX_OS_BA`) for the DUT.
   - Bring up the external TX OS transceiver and link.
   - Bring up the DUT RX OS transceiver and link.
   - Wait for both DUT and external RX OS links to report link-up.

* **Simulation Delay**

   - Wait 10 µs for data flow and link stabilization.

* **Configure RX OS DMA (if `use_dds == 0`)**

   - Enable the RX OS DMA engine and configure:
     - Control register (enable DMA).
     - Flags (TLAST).
     - Transfer length.
     - Destination address in DDR.
     - Submit DMA transfer.
   - Wait 5 µs to allow DMA to start.

* **Check Captured Data**

   - Call the `check_captured_data` task to verify that the RX OS data captured
     in DDR matches the expected template:
     - Parameters: address, length, step, max_sample.

* **Shutdown RX OS Path**

   - Bring down the DUT RX OS and external TX OS transceivers.

Stop the environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Environment Stop
   - The base testbench environment is stopped to end the test.
* Stop All Clocks
   - All clocks started previously are stopped to ensure clean shutdown.
* Reporting
   - A final informational message indicates that the test has completed.

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

   $cd testbenches/project/adrv9009
   $make

*Example 2*

Build all the possible combinations of tests and configurations, using the
Vivado GUI. This command will launch Vivado, will run the simulation and display
the waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/adrv9009
   $make MODE=gui

*Example 3*

Build a particular combination of test and configuration, using the Vivado GUI.
This command will launch Vivado, will run the simulation and display the
waveforms.

.. shell::
   :showuser:

   $cd testbenches/project/adrv9009
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

HDL related dependencies forming the DUT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :widths: 30 45 25
   :header-rows: 1

   * - IP name
     - Source code link
     - Documentation link
   * - AXI_ADXCVR
     - :git-hdl:`library/xilinx/axi_adxcvr`
     - :external+hdl:ref:`axi_adxcvr amd`
   * - AXI_CLKGEN
     - :git-hdl:`library/axi_clkgen`
     - :external+hdl:ref:`axi_clkgen`  
   * - AXI_DMAC
     - :git-hdl:`library/axi_dmac`
     - :external+hdl:ref:`axi_dmac`
   * - AXI_JESD204_RX
     - :git-hdl:`library/jesd204/axi_jesd204_rx`
     - :external+hdl:ref:`axi_jesd204_rx`
   * - AXI_JESD204_TX
     - :git-hdl:`library/jesd204/axi_jesd204_tx`
     - :external+hdl:ref:`axi_jesd204_tx`
   * - DATA_OFFLOAD
     - :git-hdl:`library/data_offload`
     - :external+hdl:ref:`data_offload`
   * - JESD204_TPL_ADC
     - :git-hdl:`library/jesd204/ad_ip_jesd204_tpl_adc`
     - :external+hdl:ref:`ad_ip_jesd204_tpl_adc`
   * - JESD204_TPL_DAC
     - :git-hdl:`library/jesd204/ad_ip_jesd204_tpl_dac`
     - :external+hdl:ref:`ad_ip_jesd204_tpl_dac`
   * - UTIL_ADXCVR
     - :git-hdl:`library/xilinx/util_adxcvr`
     - :external+hdl:ref:`util_adxcvr`
   * - UTIL_CPACK2
     - :git-hdl:`library/util_pack/util_cpack2`
     - :external+hdl:ref:`util_cpack2`
   * - UTIL_HBM
     - :git-hdl:`library/util_hbm`
     - ---
   * - UTIL_UPACK2
     - :git-hdl:`library/util_pack/util_upack2`
     - :external+hdl:ref:`util_upack2`
   * - UTIL_DO_RAM
     - :git-hdl:`library/util_do_ram`
     - :external+hdl:ref:`data_offload`


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
   * - ADI_REGMAP_DMAC_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_dmac_pkg.sv`
     - ---
   * - ADI_REGMAP_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_pkg.sv`
     - ---
   * - ADI_REGMAP_ADC_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_adc_pkg.sv`
     - ---
   * - ADI_REGMAP_COMMON_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_common_pkg.sv`
     - ---
   * - ADI_REGMAP_DAC_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_dac_pkg.sv`
     - ---
   * - ADI_REGMAP_JESD_RX_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_jesd_rx_pkg.sv`
     - ---
   * - ADI_REGMAP_JESD_TX_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_jesd_tx_pkg.sv`
     - ---
   * - ADI_REGMAP_JESD_TPL_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_jesd_tpl_pkg.sv`
     - ---
   * - ADI_REGMAP_XCVR_PKG
     - :git-testbenches:`library/regmaps/adi_regmap_xcvr_pkg.sv`
     - ---
   * - DMA_TRANS
     - :git-testbenches:`library/drivers/dmac/dma_trans.sv`
     - ---
   * - DMAC_API
     - :git-testbenches:`library/drivers/dmac/dmac_api.sv`
     - ---
   * - JESD_EXERCISER
     - :git-testbenches:`library/drivers/jesd/jesd_exerciser.tcl`
     - ---

.. include:: ../../../common/more_information.rst

.. include:: ../../../common/support.rst
