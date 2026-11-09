.. _adi_axis_monitor:

ADI AXIS Monitor (VIP)
================================================================================

Overview
-------------------------------------------------------------------------------

The ADI AXIS Monitor is created to efficiently capture data and broadcast it to
a set of subscribers that are monitoring the interface.

Parameters
-------------------------------------------------------------------------------

The ADI AXIS Monitor parameters are inherited from the ADI AXIS Agent.

Variables
-------------------------------------------------------------------------------

The publisher class is instantiated inside the monitor, which is available for
external access. This provides a means for other classes to subscribe and
receive captured data.

Methods
-------------------------------------------------------------------------------

function new(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the ADI AXIS Monitor object. The name string is assigned to the instance
as an Identifier when logging. The axis_monitor references the monitor class
that is in the AMD AXIS VIP agent. The parent variable is optional, it is used
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

An infinite loop called by the run function. It is used to monitor the AXIS
interface, collect data and broadcast to the modules that subscribed to it.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the ADI AXIS Monitor:

* Use it through the ADI AXIS Agent, declare and instantiate the agent
* Call the run function through the Agent
* Subscribe the modules that need to check data on this interface
* Run the test stimulus
* Call the stop function through the Agent before the clocks associated to the
  VIP are stopped
