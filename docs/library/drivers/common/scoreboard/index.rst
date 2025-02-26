.. _scoreboard:

Scoreboard
================================================================================

Overview
-------------------------------------------------------------------------------

The scoreboard class is designed for transaction comparison in a verification
environment. This class extends adi_component and is parameterized by a
datatype data_type, which allows the verification of different datatypes without
the need of inheriting this class. The scoreboard class contains an inner class
subscriber_class which extends adi_subscriber and is responsible for receiving
and storing data streams. The scoreboard can operate in oneshot or in
cyclic mode, which allows the verification of repeating sequence verification.

Variables
-------------------------------------------------------------------------------

The scoreboard class itself has two instances of subscriber_class, named
subscriber_source and subscriber_sink, which represent the source and sink of
the data streams. These are subscribed to a publisher, which calls the
respective functions when new data is available.

Functions
-------------------------------------------------------------------------------

function new(input string name, input adi_component parent = null);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the scoreboard object. The name gives the scoreboard a name that is
relevant in the current environment it is instantiated in and the parent sets
the parent object in which it resides.

task run();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enables the scoreboard and clears the data streams.

task stop();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Disables the scoreboard and clears the data streams.

function void set_sink_type(input bit sink_type);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Allows the setting of the sink type, which defines if the output data may or may
not repeat. If set to oneshot, then the source data is verified only once. If
set to cyclic, then the source data is verified against the sink data as long as
new data is coming in on the sink side. This value can only be set when the
scoreboard is disabled.

function bit get_sink_type();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get the sink type.

protected function void clear_streams();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Clear the source and sink data streams.

task wait_until_complete();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wait until the source and the sink datastreams are clear of data, which means
that all source data was verified against all sink data.

virtual function void compare_transaction();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Compares the source and the sink datastreams against each other. This method is
called by the subscriber when new data arrives. If the scoreboard is disabled,
the comparison is ommited.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the scoreboard:

* Declare the scoreboard
* Link the source and sink subscribers to the publishers where you want to
  verify data
* Optional: set the sink type; default is oneshot
* Call the run function to start the verification
* Wait until the scoreboard completes verification
* Stop the scoreboard

.. important::

  * The scoreboard must be started before the data transmission begins,
    otherwise, data will be lost and the verification will fail!

Other use-cases:

* The scoreboard can be dynamically reconfigured to use other inputs. Stop the
  scoreboard, unsubscribe the subscribers from the publishers and subscribe them
  to the other publisher where you want to verify data.

.. important::

  * The datatype cannot be changed during runtime, only the publisher, to which
    they are subscribed to.

.. include:: ../../../../common/support.rst
