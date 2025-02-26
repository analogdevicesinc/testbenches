.. _filter:

Filter
================================================================================

Overview
-------------------------------------------------------------------------------

This class is designed to be used in conjunction with a publisher class. The
class is parameterized with a data_type. It is mainly used in publisher and
subscriber classes.

.. important::

  The filter base class must be inherited and a new implementation must be
  written in a subclass.

Variables
-------------------------------------------------------------------------------

None are available for direct external access.

Functions
-------------------------------------------------------------------------------

function new(input string name, input adi_component parent = null);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The class constructor function initializes the object with the provided name and
parent component. 

virtual function bit filter(input adi_fifo #(data_type) data);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This function is intended to be overridden by subclasses. When a publisher or subscriber has new data, the filter function is called, which checks if the
received packet must be processed or dropped. It returns 1 if it filters.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the filter in publisher:

* Create a filter subclass
* Implement the filter function
* Add extra functionality if needed
* Update the publisher with the filter class
* Remove the filter class from the publisher if needed

Basic usage of the filter in subscriber:

* Create a subscriber subclass
* Add filter base class to the update function to be able to filter packets
* Same steps as in the publisher

.. important::

  The publisher, subscriber and filter modules must operate on the same data
  type. A filter is not needed for the publisher to work.

.. include:: ../../../common/support.rst
