.. _scoreboard_pack:

Scoreboard Pack
================================================================================

Overview
-------------------------------------------------------------------------------

This class is a specialized version of a generic scoreboard class, parameterized
by the data type and packer mode. The scoreboard pack class is designed to
handle and compare data streams in a verification environment.

.. svg:: library/drivers/common/scoreboard_pack/scoreboard_pack.svg
   :align: center

Variables
-------------------------------------------------------------------------------

No additional variables are available for direct external access.

Functions
-------------------------------------------------------------------------------

function new(...);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the scoreboard object. The name gives the scoreboard a name that is
relevant in the current environment it is instantiated in, the channels set the
number of channels that are present on the packer module, the sample value sets
the number of samples that are set in the converter, the width specifies the
width of one sample for one channel, the mode is set based on the current pack
module, which can be a packer or unpacker and the parent sets the parent object
in which it resides.

virtual function void compare_transaction();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The compare module's base functionality is the same as the base class, but it
specifically verifies the input and output of the packer and unpacker modules.

Usage and recommendations
-------------------------------------------------------------------------------

Same as the base class.

.. include:: ../../../../common/support.rst
