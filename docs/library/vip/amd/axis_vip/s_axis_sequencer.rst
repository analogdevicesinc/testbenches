.. _s_axis_sequencer:

ADI AXIS Slave Sequencer (VIP)
================================================================================

Overview
-------------------------------------------------------------------------------

The ADI AXIS Slave Sequencer is created to configure the AXI Stream
backpressure.

Parameters
-------------------------------------------------------------------------------

The ADI AXIS Slave Sequencer parameters are inherited from the ADI AXIS Agent.

Variables
-------------------------------------------------------------------------------

None are available for direct external access.

Methods
-------------------------------------------------------------------------------

function new(input string name, input axi4stream_slv_driver driver, input adi_agent parent);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the ADI AXIS Master Sequencer object. The name string is assigned to the
instance as an Identifier when logging. The write and read drivers reference
the driver classes that are in the AMD AXIS VIP agent. The parent variable is
optional, it is used to narrow down the origin of this class, used in logging.
The parent variable can only reference an adi_agent.

function void set_use_variable_ranges();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the variable ranges variable value to 1. This will mean that the sequencer
will generate backpressure based on a range of variables.

function void clr_use_variable_ranges();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the variable ranges variable value to 1. This will mean that the sequencer
will generate a repeating sequence of backpressure.

function void set_mode(input xil_axi4stream_ready_gen_policy_t mode);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the ready generation policy to the specified mode. This value is defined
in the AMD AXIS VIP ready generation policies.

function xil_axi4stream_ready_gen_policy_t get_mode();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get the current ready generation policy. This value is defined in the AMD AXIS
VIP ready generation policies.

function void set_high_time(input xil_axi4stream_uint high_time);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the high signal clock cycles of the ready signal when the sequencer has a
repeating sequence of backpressure.

function xil_axi4stream_uint get_high_time();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get the high signal clock cycles of the ready signal.

function void set_high_time_range(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the high signal clock cycles ranges of the ready signal when the sequencer
has varying backpressure.

function void set_low_time(input xil_axi4stream_uint low_time);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the low signal clock cycles of the ready signal when the sequencer has a
repeating sequence of backpressure.

function xil_axi4stream_uint get_low_time();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get the low signal clock cycles of the ready signal.

function void set_low_time_range(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the low signal clock cycles ranges of the ready signal when the sequencer
has varying backpressure.

task run();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Calls the user generated tready function.

virtual task user_gen_tready();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates a ready generation data structure based on the provided configuration
and then it sends to the driver.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the ADI AXIS Master Sequencer:

* Use it through the ADI AXIS Agent, declare and instantiate the agent
* Configure the sequencer
* Call the run function
* If the sequencer needs to be reconfigured during simulation, then reconfigure
  the parameters and then call the run function again
