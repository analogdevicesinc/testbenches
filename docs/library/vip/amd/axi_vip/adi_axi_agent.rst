.. _adi_axi_agent:

ADI AXI Agent (VIP)
================================================================================

Overview
-------------------------------------------------------------------------------

The ADI AXI Agent uses the AMD (Xilinx) AXI VIP at its core with added
sequencer, monitor and wrapper class. Has a master, slave and passthrough
variant. Provides functions to start, stop and run the classes within. Its
purpose is to create and contain everything under a single construct and not
have the user to create and manage each of these modules separately.

Parameters
-------------------------------------------------------------------------------

The ADI AXI Agent parameters ``must`` be compatible with the VIP used in the
design. The virtual interface that is defined must be of the same type that
the VIP is using. The AMD AXI VIP must also be compatible with the specified
parameters. The axi_definitions.svh header file has useful macros to create
and build the required parameter list.

Variables
-------------------------------------------------------------------------------

The core components are available for access depending on the agent type that
is instantiated.

adi_axi_master_agent variant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 * axi_mst_agent agent
 * m_axi_sequencer sequencer
 * adi_axi_monitor monitor

adi_axi_slave_mem_agent variant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 * axi_slv_mem_agent agent
 * s_axi_sequencer sequencer
 * adi_axi_monitor monitor

adi_axi_passthrough_mem_agent variant
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 * axi_passthrough_mem_agent agent
 * m_axi_sequencer master_sequencer
 * s_axi_sequencer slave_sequencer
 * adi_axi_monitor monitor

Methods
-------------------------------------------------------------------------------

function new(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the ADI AXI Agent object. The name string is assigned to the instance
as an Identifier when logging. The vip_if is a Virtual Interface that is
instantiated inside the AXI VIP when created. This is used to connect the VIP
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

Used to run the monitor.

task stop();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to stop the agent, the sequencer(s) and the monitor.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the ADI AXI Agent:

* Declare the ADI AXI Agent, preferably inside an environment with the correct
  parameters, give a name and if it's inside an environment, set the parent as
  well
* Call the start function before resetting the entire system
* Call the run function
* Run the test stimulus
* Call the stop function before the clocks associated to the VIP are stopped
