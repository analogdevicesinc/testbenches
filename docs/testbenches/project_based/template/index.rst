:orphan:

.. _project_based_template:

Project based test bench template
================================================================================

Overview
-------------------------------------------------------------------------------

**\*This section must contain: the purpose of the testbench/ type of interface
it's validating, the corresponding hdl project and the HDL Github documentation
page.**\ \*

Block design
-------------------------------------------------------------------------------

**\*Mention the HDL and SV components of the testbench .**\ \*

Block diagram
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If the testbench has multiple ways of configuration, then make subsections to
this section and show the default configuration and some other popular modes.

\**\* KEEP THIS PARAGRAPH \**\*
The data path and clock domains are depicted in the below diagram:

.. image:: ../template/project_based_template_bd.svg
   :width: 800
   :align: center
   :alt: Template/Testbench block diagram

\*\* MUST: Use SVG format for the diagram \*\*

\*\* TIP: Block diagrams should contain subtitles only if there are at least two
different diagrams \*\*

Configuration parameters and modes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\**\* MENTION IF ANY MODES ARE AVAILABLE FOR CONFIGURATION \**\*

Build parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

\**\* THIS IS JUST AN EXAMPLE \**\*

The following are the parameters of this project that can be configured:

-  CLK_MODE: defines clocking mode of the device's digital interface:
   Options: 0 - SPI mode, 1 - Echo-clock or Master clock mode
-  NUM_OF_SDI: defines the number of MOSI lines of the SPI interface:
   Options: 1 - Interleaved mode, 2 - 1 lane per channel,
   4 - 2 lanes per channel, 8 - 4 lanes per channel
-  CAPTURE_ZONE: defines the capture zone of the next sample.
   There are two capture zones: 1 - from negative edge of the BUSY line
   until the next CNV positive edge -20ns, 2 - from the next consecutive CNV
   positive edge +20ns until the second next consecutive CNV positive edge -20ns
-  DDR_EN: defines the type of data transfer. In echo and master clock mode
   the SDI lines can have Single or Double Data Rates.
   Options: 0 - MISO runs on SDR, 1 - MISO runs on DDR.

Configuration files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

\**\* MENTION IF ANY CONFIGURATION FILES ARE AVAILABLE\**\*
   
\**\* THIS IS JUST AN EXAMPLE \**\*   

The following are available configurations for the test bench:

   +-----------------------+-----------------------------------------------+
   | Configuration mode    | Parameters                                    |
   |                       +----------+------------+--------------+--------+
   |                       | CLK_MODE | NUM_OF_SDI | CAPTURE_ZONE | DDR_EN |
   +=======================+==========+============+==============+========+
   | cfg_cm0_sdi2_cz1_ddr0 | 0        | 2          | 1            | 0      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm0_sdi2_cz2_ddr0 | 0        | 2          | 2            | 0      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm0_sdi4_cz2_ddr0 | 0        | 4          | 2            | 0      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm0_sdi8_cz2_ddr0 | 0        | 8          | 2            | 0      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm1_sdi1_cz2_ddr0 | 1        | 1          | 2            | 0      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm1_sdi2_cz2_ddr0 | 1        | 2          | 2            | 0      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm1_sdi2_cz2_ddr1 | 1        | 2          | 2            | 1      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm1_sdi4_cz2_ddr0 | 1        | 4          | 2            | 0      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm1_sdi4_cz2_ddr1 | 1        | 4          | 2            | 1      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm1_sdi8_cz2_ddr0 | 1        | 8          | 2            | 0      |
   +-----------------------+----------+------------+--------------+--------+
   | cfg_cm1_sdi8_cz2_ddr1 | 1        | 8          | 2            | 1      |
   +-----------------------+----------+------------+--------------+--------+

Tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

..
   MENTION IF ANY MODES ARE AVAILABLE FOR TESTS

The following test program files are available:

=============== ==========================================
Test program    Usage
=============== ==========================================
test_program_si Tests the parallel interface capabilities.
test_program_pi Tests the serial interface capabilities.
=============== ==========================================

Available configurations & tests combinations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

============= =============== ===================================
Configuration Test            Build command
============= =============== ===================================
cfg_si        test_program_si make CFG=cfg_si TST=test_program_si
cfg_pi        test_program_pi make CFG=cfg_pi TST=test_program_pi
============= =============== ===================================

.. warning::

    Mixing a wrong pair of CFG and TST will result in a building errror.
    Please checkout the proposed combinations before running a custom test.

Clock scheme
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\**\* MENTION IF ANY CLOCKING CONFIGURATIONS ARE BEING USED\**\*

CPU/Memory interconnects addresses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\**\* THIS IS JUST AND EXAMPLE \**\*

Below are the CPU/Memory interconnect addresses used in this project:

=====================  ===========
Instance               Address
=====================  ===========
spi_ad7616_axi_regmap  0x44A0_0000
axi_ad7606x_dma        0x44A3_0000
spi_clkgen             0x44A7_0000
ad7606_pwm_gen         0x44B0_0000
=====================  ===========

Interrupts
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\**\* THIS IS JUST AND EXAMPLE \**\*

Below are the Programmable Logic interrupts used in this project:

===============  ===
Instance name    HDL
===============  ===
axi_ad7606_dma   13
spi_ad7606       12
===============  ===

Test stimulus
-------------------------------------------------------------------------------

\**\* LIST AND EXPLAIN ALL THE TESTS COMPRISED IN THE test_program FILE \**\*

\**\* THIS IS JUST AND EXAMPLE \**\*

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
AD7606 SPI Engine interface, by reading the core VERSION register, along with 
writing and reading the SCRATCH register.

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

   $cd testbenches/ad7616
   $make

*Example 2*

Build all the possible combinations of tests and configurations, using the
Vivado GUI. This command will launch Vivado, will run the simulation and display
the waveforms.

.. shell::
   :showuser:

   $cd testbenches/ad7616
   $make MODE=gui

*Example 3*

Build a particular combination of test and configuration, using the Vivado GUI.
This command will launch Vivado, will run the simulation and display the
waveforms.

.. shell::
   :showuser:

   $cd testbenches/ad7616
   $make MODE=gui CFG=cfg_pi TST=test_program_pi

The built projects can be found in the ``runs`` folder, where each configuration specific
build has it's own folder named after the configuration file's name.
Example: if the following command was run for a single configuration in the clean folder
(no runs folder available):

``make CFG=cfg_pi``

Then the subfolder under ``runs`` name will be:

``cfg_pi``

Resources
-------------------------------------------------------------------------------

HDL related dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

\**\* THIS IS JUST AND EXAMPLE \**\*

.. list-table::
   :widths: 30 45 25
   :header-rows: 1

   * - IP name
     - Source code link
     - Documentation link
   * - SYNC_BITS
     - :git-hdl:`library/util_cdc/sync_bits.v <library/util_cdc/sync_bits.v>` **
     - ---
   * - AD_EDGE_DETECT
     - :git-hdl:`library/common/ad_edge_detect.v <library/common/ad_edge_detect.v>`
     - ---
   * - AXI_AD7606x
     - :git-hdl:`library/axi_ad7606x <library/axi_ad7606x>` *
     - :dokuwiki:`[Wiki] <resources/fpga/docs/axi_ad7606x>`
   * - AXI_CLKGEN
     - :git-hdl:`library/axi_clkgen <library/axi_clkgen>`
     - :external+hdl:ref:`here <axi_clkgen>`
   * - AXI_DMAC
     - :git-hdl:`library/axi_dmac <library/axi_dmac>`
     - :external+hdl:ref:`here <axi_dmac>`
   * - AXI_HDMI_TX
     - :git-hdl:`library/axi_hdmi_tx <library/axi_hdmi_tx>`
     - :external+hdl:ref:`here <axi_hdmi_tx>`
   * - AXI_I2S_ADI
     - :git-hdl:`library/axi_i2s_adi <library/axi_i2s_adi>`
     - ---
   * - AXI_PWM_GEN
     - :git-hdl:`library/axi_pwm_gen <library/axi_pwm_gen>`
     - :external+hdl:ref:`here <axi_pwm_gen>`
   * - AXI_SPDIF_TX
     - :git-hdl:`library/axi_spdif_tx <library/axi_spdif_tx>`
     - ---
   * - AXI_SYSID
     - :git-hdl:`library/axi_sysid <library/axi_sysid>`
     - :external+hdl:ref:`here <axi_sysid>`
   * - AXI_SPI_ENGINE
     - :git-hdl:`library/spi_engine/axi_spi_engine <library/spi_engine/axi_spi_engine>`  **
     - :external+hdl:ref:`here <spi_engine axi>`
   * - SPI_ENGINE_EXECUTION
     - :git-hdl:`library/spi_engine/spi_engine_execution <library/spi_engine/spi_engine_execution>` **
     - :external+hdl:ref:`here <spi_engine execution>`
   * - SPI_ENGINE_INTERCONNECT
     - :git-hdl:`library/spi_engine/spi_engine_interconnect <library/spi_engine/spi_engine_interconnect>` **
     - :external+hdl:ref:`here <spi_engine interconnect>`
   * - SPI_ENGINE_OFFLOAD
     - :git-hdl:`library/spi_engine/spi_engine_offload <library/spi_engine/spi_engine_offload>` **
     - :external+hdl:ref:`here <spi_engine offload>`
   * - SYSID_ROM
     - :git-hdl:`library/sysid_rom <library/sysid_rom>`
     - :external+hdl:ref:`here <axi_sysid>`
   * - UTIL_I2C_MIXER
     - :git-hdl:`library/util_i2c_mixer <library/util_i2c_mixer>`
     - ---
   * - UTIL_CPACK2
     - :git-hdl:`library/util_pack/util_cpack2 <library/util_pack/util_cpack2>` *
     - :external+hdl:ref:`here <util_cpack2>`
     
.. admonition:: Legend
   :class: note

   -   ``*`` instantiated only for INTF=0 (parallel interface)
   -   ``**`` instantiated only for INTF=1 (serial interface)
     

Testbenches related dependencies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. include:: ../../common/dependency_common.rst

Testbench specific dependencies:

\**\* THIS IS JUST AND EXAMPLE \**\*

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

.. include:: ../../../common/more_information.rst

.. include:: ../../../common/support.rst
