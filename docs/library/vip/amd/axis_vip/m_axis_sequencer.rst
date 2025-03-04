.. _m_axis_sequencer:

ADI AXIS Master Sequencer (VIP)
================================================================================

Overview
-------------------------------------------------------------------------------

The ADI AXIS Master Sequencer is created to easily generate AXI Stream
transfers.

Parameters
-------------------------------------------------------------------------------

The ADI AXIS Master Sequencer parameters are inherited from the ADI AXIS Agent.

Variables
-------------------------------------------------------------------------------

None are available for direct external access.

Methods
-------------------------------------------------------------------------------

function new(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the ADI AXIS Master Sequencer object. The name string is assigned to the
instance as an Identifier when logging. The write and read drivers reference
the driver classes that are in the AMD AXIS VIP agent. The parent variable is
optional, it is used to narrow down the origin of this class, used in logging.
The parent variable can only reference an adi_agent.

virtual task set_inactive_drive_output_0();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the AMD AXIS VIP to drive the outputs of the AXIS interface with 0s when
inactive.

virtual function bit check_ready_asserted();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Provides a way through the sequencer to check if the slave interface asserts
ready.

virtual task wait_clk_count(input int wait_clocks);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Waits for the specified amount of clock cycles that is associated with the VIP.

virtual protected task packetize();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Packetizes the data before sending it to the driver.

virtual protected task sender();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When the packetize method finished creating a packet, it notifies the sender.
The sender gets the data and transfers it to the driver. When finished, it
notifies the other methods that the transfer is complete and a new packet can
be created.

virtual function void add_xfer_descriptor_packet_size(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to set the number of samples that each packet is going to have using the
VIP's parameters.

virtual task beat_sent();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Function provided to the sequencer to wait until a data beat is sent. If the
driver module is already inactive, it means that no transfer is being processed
and the sequencer can be safely disabled.

virtual task packet_sent();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Function provided to the sequencer to wait until a data packet is sent. If the
driver module is already inactive and the last signal has been sent, it means
that no transfer is being processed and the last sample in the packet was also
sent, so the sequencer can be safely disabled.

function void set_stop_policy(input stop_policy_t stop_policy);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the stop policy to data beat, packet or queue finished. If the sequencer
is already enabled, it will throw an error message.

function void set_data_gen_mode(input data_gen_mode_t data_gen_mode);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the data generation mode. It can be a ramp, randomly generated data, or
user specified data. If the sequencer is already enabled, it will throw an
error message.

.. caution::

   If the data is user specified, the user must make sure that the packetizer
   is fed with enough data to complete a packet, otherwise the packet will not
   be transfered to the driver.

function void set_descriptor_gen_mode(input bit descriptor_gen_mode);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the packet generation mode. If set to 0, it will only create the packets
that are in the queue. If set to 1, it will repeat all of the packets that are
in the queue in a round-robin mode. If the sequencer is already enabled, it
will throw an error message.

function void set_data_beat_delay(input int data_beat_delay);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets a specified amount of inactive clock cycles between each data beat.

function void set_descriptor_delay(input int descriptor_delay);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets a specified amount of inactive clock cycles between each packet transfer.

function void set_keep_all();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the generated data to be all valid bytes. Automatically adjusts the packet
length, increasing its size, if the specified number of bytes don't fill all
samples with data. If the sequencer is already enabled, it will throw an error
message.

function void set_keep_some();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the generated data to have not valid bytes. If the sequencer is already
enabled, it will throw an error message.

function void add_xfer_descriptor(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to set the number of bytes to be sent to the driver.

protected task descriptor_delay_subroutine();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used by the generator function to wait for a specified amount of clock cycles
before transferring the next packet.

task wait_empty_descriptor_queue();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Function provided to the sequencer to wait until the transfer queue is empty.
If the queue is already empty, it will automatically return.

task clear_descriptor_queue();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Clears the transfer queue. Transfers that are already being processed by the
packetizer will be finished regardless.

protected task generator();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The generator checks the status of the sequencer and if it's enabled, it will
call the packetize task to create a transfer based on the packets description
in queue. If the queue is empty, it generates an event, notifying that all of
the data has been processed. When a new packet description is added to the
queue it resumes its operation.

function void push_byte_for_stream(xil_axi4stream_data_byte byte_stream);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used when the data descriptor mode is set for user generated data. In this mode,
the user must specify a byte, which is put into a byte stream. The byte stream
is processed by the packetizer when it is ready to prepare a new transfer.

protected task data_beat_delay_subroutine();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used by the packetize method to set the transfer wait time between data beats.

task start();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enables the sequencer.

task stop();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Disables the sequencer.

task run();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Starts the generator and the sender functions.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the ADI AXIS Master Sequencer:

* Use it through the ADI AXIS Agent, declare and instantiate the agent
* Configure the sequencer
* Call the run function
* Call the sequencer's start function
* Generate data packets
* Call the stop function to stop the sequencer if needed
* Call the stop function through the Agent before the clocks associated to the
  VIP are stopped
