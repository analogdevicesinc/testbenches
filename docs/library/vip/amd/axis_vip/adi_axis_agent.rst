.. _adi_axis_agent:

ADI AXIS Agent (VIP)
================================================================================

Overview
-------------------------------------------------------------------------------

The ADI AXIS Agent uses the AMD (Xilinx) AXIS VIP at its core with added 
sequencer, monitor and wrapper class. Has a master, slave and passthrough
variant. Provides functions to start, stop and run the classes within. Its
purpose is to create and contain everything under a single construct and not
have the user to create and manage each of these modules separately.

Parameters
-------------------------------------------------------------------------------

The ADI AXIS Agent parameters ``must`` be compatible with the VIP used in the
design. The virtual interface that is defined must be of the same type that
the VIP is using. The AMD AXIS VIP must also be compatible with the specified
parameters. The axis_definitions.svh header files has useful macros to create
and build the required parameter list.

Variables
-------------------------------------------------------------------------------

The core components are available for access depending on the agent type that
is instantiated.

adi_axis_master_agent variant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 * axi4stream_mst_agent agent
 * m_axis_sequencer sequencer
 * adi_axis_monitor monitor

adi_axis_slave_agent variant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 * axi4stream_slv_agent agent
 * s_axis_sequencer sequencer
 * adi_axis_monitor monitor

adi_axis_passthrough_agent variant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 * axi4stream_passthrough_agent agent
 * m_axis_sequencer master_sequencer
 * s_axis_sequencer slave_sequencer
 * adi_axis_monitor monitor

Methods
-------------------------------------------------------------------------------

function new(input string name, virtual interface axis_vip_if vip_if, input adi_environment parent);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the ADI AXIS Agent object. The name string is assigned to the instance
as an Identifier when logging. The vip_if is a Virtual Interface that is
instantiated inside the AXIS VIP when created. This is used to connect the VIP
(in block design) to the simulation. The parent variable is optional, it is
used to narrow down the origin of this class, used in logging. The parent
variable can only reference an adi_environment.

task start();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to start the master or slave agent when not in passthrough mode. In
passthrough mode it throws a warning, since in the passthrough agent can only
work in master, slave or passthrough mode at a given time.

.. important::

   This warning message can be ommitted, as this causes no harm during
   simulation. Its main use is to notify the user that the VIP in passthrough
   mode is only monitoring and it must be changed manually to master or slave
   mode if needed.

task run();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to run the sequencer(s) and the monitor.

task stop();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to stop the agent, the sequencer(s) and the monitor.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the ADI AXIS Agent:

* Declare the ADI AXIS Agent, preferably inside an environment with the correct
  parameters, give a name and if it's inside an environment, set the parent as
  well
* Call the start function before resetting the entire system
* Configure the sequencer(s)
* Call the run function
* Call the start function in the case of master mode
* Run the test stimulus
* Call the stop function before the clocks associated to the VIP are stopped
