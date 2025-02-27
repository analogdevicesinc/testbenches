.. _adi_datatypes:

Datatypes
================================================================================

Overview
-------------------------------------------------------------------------------

Provides abstract and implemented classes for datatypes.

adi_fifo
-------------------------------------------------------------------------------

The intent was to have a data queue that has a fixed set of function for push
and pull, simular to the built-in queues. This way simple push and pull function
can be used for data manipulation, instead of choosing between the back-front
options for push and pull functions, avoiding confusion between different
implementations. The parent can be any adi_component subclass.

Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A data queue, that is used for storing data, and it is an actual SystemVerilog
queue. The depth specifies the depth of the queue. When set to 0, the queue
depth is unlimited.

Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* When calling the constructor, a name and depth are mandatory inputs. A parent
  may also be set.
* It has a push, pull function, which is implemented in way to resemble a FIFO
  (First In, First Out).
* It has the delete, insert and size functions implemented similar to the
  queue.
* Additionally, a room function is implemented to check for the remaining space
  in the FIFO.

adi_lifo
-------------------------------------------------------------------------------

The intent was to have a data queue that has a fixed set of function for push
and pull, simular to the built-in queues. This way simple push and pull function
can be used for data manipulation, instead of choosing between the back-front
options for push and pull functions, avoiding confusion between different
implementations. The parent can be any adi_component subclass.

Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A data queue, that is used for storing data, and it is an actual SystemVerilog
queue. The depth specifies the depth of the queue. When set to 0, the queue
depth is unlimited.

Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* When calling the constructor, a name and depth are mandatory inputs. A parent
  may also be set.
* It has a push, pull function, which is implemented in way to resemble a LIFO
  (Last In, First Out).
* It has the delete, insert and size functions implemented similar to the
  queue.
* Additionally, a room function is implemented to check for the remaining space
  in the LIFO.

.. include:: ../../../common/support.rst
