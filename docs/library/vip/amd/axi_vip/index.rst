.. _xilinx_axi_vip:

Xilinx AXI Verification IP (VIP)
================================================================================

.. toctree::
   :hidden:

   ADI AXI Agent <adi_axi_agent>
   ADI AXI Master Sequencer <m_axi_sequencer>
   ADI AXI Slave Sequencer <s_axi_sequencer>
   ADI AXI Monitor <adi_axi_monitor>

Overview
-------------------------------------------------------------------------------

The ADI AXI Agent uses the AMD (Xilinx) AXI VIP at its core with added 
sequencer, monitor and wrapper class.
`[1] <https://docs.amd.com/r/en-US/pg267-axi-vip>`__

Inheritance diagram for AMD AXI VIP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. svg:: ./library/vip/amd/axi_vip/amd_axi_inheritance.svg
   :align: center

Aggregation diagram for AMD AXI VIP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. svg:: ./library/vip/amd/axi_vip/amd_axi_aggregation.svg
   :align: center

Components
-------------------------------------------------------------------------------

:ref:`adi_axi_agent`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Has a master, slave and passthrough variant. Encapsulates the AMD AXI VIP, ADI
AXI Master and/or Slave Sequencers and the ADI AXI Monitor. Provides functions
to start, stop and run the classes within.

:ref:`m_axi_sequencer`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ADI AXI Master Sequencer provides functions to easily read, write and
verify data on a specified address. It is preconfigured to support only
AXI4Lite transactions.

:ref:`s_axi_sequencer`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ADI AXI Slave Sequencer provides functions to easily read, write and
verify data from a memory.

:ref:`adi_axi_monitor`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ADI AXI Monitor provides functions to monitor an AXI interface, collect
data transmitted and broadcast it to other classes using a publisher-subscriber
pattern.

References
-------------------------------------------------------------------------------

`[1] "AXI Verification IP LogiCORE IP Product Guide (PG267)", Xilinx, 2019
<https://docs.amd.com/r/en-US/pg267-axi-vip>`__

