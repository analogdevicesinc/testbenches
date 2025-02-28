.. _xilinx_axis_vip:

Xilinx AXIS Stream Verification IP (VIP)
================================================================================

.. toctree::
   :hidden:

   ADI AXIS Agent <adi_axis_agent>
   ADI AXIS Master Sequencer <m_axis_sequencer>
   ADI AXIS Slave Sequencer <s_axis_sequencer>
   ADI AXIS Monitor <adi_axis_monitor>

Overview
--------------------------------------------------------------------------------

The ADI AXIS Agent VIP uses the AMD (Xilinx) AXIS VIP at its core with added 
sequencer, monitor and wrapper class.
`[1] <https://docs.amd.com/v/u/en-US/pg277-axi4stream-vip>`__

Inheritance diagram for AMD AXIS VIP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. svg:: ./library/vip/amd/axis_vip/amd_axis_inheritance.svg
   :align: center

Aggregation diagram for AMD AXIS VIP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. svg:: ./library/vip/amd/axis_vip/amd_axis_aggregation.svg
   :align: center

Components
-------------------------------------------------------------------------------

:ref:`adi_axis_agent`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Has a master, slave and passthrough variant. Encapsulates the AMD AXIS VIP, ADI
AXIS Master and/or Slave Sequencers and the ADI AXIS Monitor. Provides functions
to start, stop and run the classes within.

:ref:`m_axis_sequencer`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ADI AXIS Master Sequencer provides functions to generate data on an AXI
Streaming interface.

:ref:`s_axis_sequencer`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ADI AXIS Slave Sequencer provides functions to create user specified
backpressure characteristics.

:ref:`adi_axis_monitor`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ADI AXIS Monitor provides functions to monitor an AXI Stream interface,
collect data transmitted and broadcast it to other classes using a
publisher-subscriber pattern.

References
-------------------------------------------------------------------------------

`[1] "AXI4-Stream Verification IP v1.1 LogiCORE IP Product Guide (PG277)",
Xilinx, 2019 <https://docs.amd.com/v/u/en-US/pg277-axi4stream-vip>`__
