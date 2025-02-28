.. _processor:

Processor
================================================================================

Overview
-------------------------------------------------------------------------------

This class is designed to be used in conjunction with a publisher class. The
class is parameterized with a data_type. It is mainly used in publisher and
subscriber classes.

.. important::

  The processor base class must be inherited and a new implementation must be
  written in a subclass.

.. svg:: library/utilities/pub_sub/processor.svg
   :align: center

Variables
-------------------------------------------------------------------------------

None are available for direct external access.

Functions
-------------------------------------------------------------------------------

function new(input string name, input adi_component parent = null);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The class constructor function initializes the object with the provided name and
parent component. 

virtual function bit process_data(input adi_fifo #(data_type) data);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This function is intended to be overridden by subclasses. When a publisher or
subscriber has new data, the process_data function is called, which does some
data processing and then it returns a new fifo with the processed data.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the processor in publisher:

* Create a processor subclass
* Implement the process_data function
* Add extra functionality if needed
* Update the publisher with the processor class
* Remove the processor class from the publisher if needed

Basic usage of the processor in subscriber:

* Create a subscriber subclass
* Add processor base class to the update function to be able to process packets
* Same steps as in the publisher

.. important::

  The publisher, subscriber and processing modules must operate on the same data
  type. A processor is not needed for the publisher to work.

.. include:: ../../../common/support.rst
