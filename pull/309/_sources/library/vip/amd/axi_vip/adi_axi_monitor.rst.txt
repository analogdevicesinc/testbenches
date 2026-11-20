.. _adi_axi_monitor:

ADI AXI Monitor (VIP)
================================================================================

Overview
-------------------------------------------------------------------------------

The ADI AXI Monitor is created to efficiently capture data and broadcast it to
a set of subscribers that are monitoring the interface.

Parameters
-------------------------------------------------------------------------------

The ADI AXI Monitor parameters are inherited from the ADI AXI Agent.

Variables
-------------------------------------------------------------------------------

The publisher classes are instantiated inside the monitor, which are available
for external access. One for Write and one for Read operations. This provides a
means for other classes to subscribe to one or another.

Methods
-------------------------------------------------------------------------------

function new(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the ADI AXI Monitor object. The name string is assigned to the instance
as an Identifier when logging. The axi_monitor references the monitor class
that is in the AMD AXI VIP agent. The parent variable is optional, it is used
to narrow down the origin of this class, used in logging. The parent variable
can only reference an adi_agent.

task run();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to start up the monitor.

.. error::

   If a monitor instance is already running, it will throw an error message and
   continues the simulation.

.. attention::

   This error message can be ommitted, as this causes no harm during simulation.
   However, it is highly recommended to review the simulation stimulus and
   correct this error.

function stop();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to stop the monitor. If the monitor is not running, it will have no effect.

task get_transaction();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An infinite loop called by the run function. It is used to monitor the AXI
interface, collect data and broadcast to the modules that subscribed to it.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the ADI AXI Monitor:

* Use it through the ADI AXI Agent, declare and instantiate the agent
* Call the run function through the Agent
* Subscribe the modules that need to check data on this interface
* Run the test stimulus
* Call the stop function through the Agent before the clocks associated to the
  VIP are stopped
