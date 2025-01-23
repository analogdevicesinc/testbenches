.. _m_axi_sequencer:

ADI AXI Master Sequencer (VIP)
================================================================================

Overview
-------------------------------------------------------------------------------

The ADI AXI Master Sequencer is created to easily generate AXI4Lite transfers,
mimicing a processing system.

Parameters
-------------------------------------------------------------------------------

The ADI AXI Master Sequencer parameters are inherited from the ADI AXI Agent.

Variables
-------------------------------------------------------------------------------

None are available for direct external access.

Methods
-------------------------------------------------------------------------------

function new(input string name, input axi_mst_wr_driver wr_driver, input axi_mst_rd_driver rd_driver, input adi_agent parent);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the ADI AXI Master Sequencer object. The name string is assigned to the
instance as an Identifier when logging. The write and read drivers reference
the driver classes that are in the AMD AXI VIP agent. The parent variable is
optional, it is used to narrow down the origin of this class, used in logging.
The parent variable can only reference an adi_agent.

virtual task RegWrite32(input xil_axi_ulong addr, input bit [31:0] data);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Writes the data at the specified address. When multiple writes are initiated,
only one transfer is processed at a given time. The other transfers will wait
for the previous one to finish. There is no priority between the transfers and
the processing order is subject to the event scheduling.

virtual task RegRead32(input xil_axi_ulong addr, output bit [31:0] data);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Reads the data at the specified address. When multiple reads are initiated,
only one transfer is processed at a given time. The other transfers will wait
for the previous one to finish. There is no priority between the transfers and
the processing order is subject to the event scheduling.

virtual task RegReadVerify32(input xil_axi_ulong addr, input bit [31:0] data);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Reads the data at the specified address and compares it with the data
specified. When multiple reads are initiated, only one transfer is processed at
a given time. The other transfers will wait for the previous one to finish.
There is no priority between the transfers and the processing order is subject
to the event scheduling.

task single_write_transaction_api(...)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to create a transaction for the AMD AXI VIP write driver. After the
transaction is created based on the parameters given, sends the transaction
object to the driver to send the data. Does not wait for a response from the
slave side

task single_write_transaction_readback_api(...)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Same as single_write_transaction_api with the addition of waiting for a
response from the slave side. It is used by RegWrite32.

task single_read_transaction_api(...)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to create a transaction for the AMD AXI VIP read driver. After the
transaction is created based on the parameters given, sends the transaction
object to the driver to send the data. Does not wait for a response from the
slave side

task single_read_transaction_readback_api(...)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Same as single_read_transaction_api with the addition of waiting for a
response from the slave side. It is used by RegRead32 and RegReadVerify32.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the ADI AXI Master Sequencer:

* Use it through the ADI AXI Agent, declare and instantiate the agent
* Initiate the transactions whenever needed
* Call the stop function through the Agent before the clocks associated to the
  VIP are stopped
