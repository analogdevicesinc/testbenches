.. _adi_common:

Common
================================================================================

Overview
-------------------------------------------------------------------------------

Base classes that form the base of the other ADI classes.

adi_reporter
-------------------------------------------------------------------------------

This is the top base class. It's only responsibility is to provide the
subclasses with a name, a parent container, and functions for reporting.

Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Name sets the subclass' name. The parent sets the parent class in which it
resides.

Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Info, warning, error and fatal messages are used for error reporting withing a class. Get_path function is used to gather information about the hierarchy of the subclass, which called the logging function.

adi_component
-------------------------------------------------------------------------------

Extends the adi_reporter base class. It forms the base of all other inherited
classes.

Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

No additional variables are available for this class.

Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

No additional functions are available for this class.

.. include:: ../../../common/support.rst
