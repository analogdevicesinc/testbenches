.. _subscriber:

Subscriber
================================================================================

Overview
-------------------------------------------------------------------------------

This class is designed to be used in conjunction with a publisher class. The
class is parameterized with a data_type. It is mainly used in scoreboard and
checker classes which need data inputs from various other modules. 

.. important::

  The subscriber base class must be inherited and a new implementation must be
  written in a subclass.

Variables
-------------------------------------------------------------------------------

It has a variable ID that is public, which is used to identify the current
instance. It is also used by the publisher when adding/removing the subscribing
class to/from the list.

Functions
-------------------------------------------------------------------------------

function new(input string name, input adi_component parent = null);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The class constructor function initializes the object with the provided name and
parent component. A static variable is counting the number of subscribers that
have been created up until this point, this ensures that all subscribers receive
a unique identification number.

virtual function void update(input adi_fifo #(data_type) data);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This function is intended to be overridden by subclasses. When a publisher has
new data, it calls each subscriber's update function, which ensures that each
implementation will use the published data in the way it was intended to be used
in the class where the subscriber is instantiated.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the subscriber:

* Create a subscriber subclass
* Implement the update function
* Add extra functionality if needed
* Subscribe to the publisher
* Unsubscribe from the publisher

.. important::

  The publisher, subscriber, filter and processing modules must operate on the
  same data type. A filter and a processor is not needed for the publisher to
  work.

.. include:: ../../../common/support.rst
