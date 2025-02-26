.. _publisher:

Publisher
================================================================================

Overview
-------------------------------------------------------------------------------

This class is designed to manage a list of subscribers, has the ability to apply
filters, process data packets, and notify subscribers with the received data.
The class is parameterized with a data_type. It is mainly used in VIP monitors,
but it can also be integrated in other environments as well.

Variables
-------------------------------------------------------------------------------

None are available for direct external access.

Functions
-------------------------------------------------------------------------------

function new(input string name, input adi_component parent = null);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The class constructor function initializes the object with the provided name and
parent component.

function void setup_filter(input adi_filter #(data_type) filter);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Adds an implemented filter object to the publisher, which allows packet
filtering before publishing.

function void remove_filter();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Removes the added filter object from the publisher.

function void setup_processor(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Adds an implemented data processor object to the publisher, which allows packet
processing of the data before publishing.

function void remove_processor();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Removes the added data processor object from the publisher.

function void subscribe(input adi_subscriber #(data_type) subscriber);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The subscribe function adds a subscriber to the subscriber_list if it does not
already exist. Gives an error message, if the subscriber is already added to the
list.

function void unsubscribe(input adi_subscriber #(data_type) subscriber);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The unsubscribe function removes a subscriber if it exists in the list.

function void notify(input adi_fifo #(data_type) data);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The notify function is responsible for notifying all subscribers with the data.
It first checks if a filter is set and applies it to the data. If the data
passes the filter, it is then processed by the packet processor if one is set.
Finally, the processed data is sent to all subscribers in the subscriber_list.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the publisher:

* Declare the publisher and create an instance
* Use the subscribe function to add subscribers to the list
* Create a packet that needs to be published
* Call the notify function to publish the packet
* Unsubscribe the subscribed modules if needed

.. important::

  The publisher, subscriber, filter and processing modules must operate on the
  same data type. A filter and a processor is not needed for the publisher to
  work.

.. include:: ../../../common/support.rst
