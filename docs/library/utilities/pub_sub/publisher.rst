.. _publisher:

Publisher
================================================================================

Overview
-------------------------------------------------------------------------------

This class is designed to manage a list of subscribers and has the ability to
notify subscribers with the received data. The class is parameterized with a
``data_type``. It is mainly used in VIP monitors, but it can also be integrated
in other environments as well.

.. svg:: library/utilities/pub_sub/publisher.svg
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

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the publisher:

* Declare the publisher and create an instance
* Use the subscribe function to add subscribers to the list
* Create a packet that needs to be published
* Call the notify function to publish the packet
* Unsubscribe the subscribed modules if needed

.. important::

  The publisher and subscriber modules must operate on the same data type.

.. include:: ../../../common/support.rst
