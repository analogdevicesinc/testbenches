.. _adi_api:

API
================================================================================

Overview
-------------------------------------------------------------------------------

API related base classes. It also defined the register access types for the
fields.

adi_api
-------------------------------------------------------------------------------

Extends the adi_component base class. It forms the base of all other inherited
classes. For the partent, only adi_environments are valid, as it doesn't make
sense for other classes to contain an adi_api class.

Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It stores a local reference to an AXI sequencer, which is used to configure the
IP registers.

Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Axi_read, axi_write and axi_verify are used to access the registers. For input,
these functions require a register handle.

adi_api_legacy
-------------------------------------------------------------------------------

This is the old form of the APIs that are used without registermaps. Extends
the adi_component base class. It forms the base of all other inherited classes.
For the partent, only adi_environments are valid, as it doesn't make sense for
other classes to contain an adi_api_legacy class.

Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It stores a local reference to an AXI sequencer, which is used to configure the
IP registers. It also has a base address for the API, and version registers.

Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The axi_read, axi_write and axi_verify require an address and a data variable to
read from or write to. The probe function is used to probe the version
registers.

adi_regmap
-------------------------------------------------------------------------------

Extends the adi_component base class. It forms the base of all other inherited
classes. For the partent, only adi_apis are valid, as it doesn't make sense for
other classes to contain an adi_regmap class.

Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It stores the address value of the register map.

Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It provides function to get the address value, used by the adi_api when
accessing the registerspace.

register_base
-------------------------------------------------------------------------------

Extends the adi_component base class. It forms the base of all other inherited
classes. For the partent, only adi_regmaps are valid, as it doesn't make sense
for other classes to contain a register_base class.

Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Stores an address for the register relative to the register map base address, an
initialization_done flag bit, which is set at the end of instantiation of all
fields in the register. It stores a reset value, which is also set at the end of
instantiation.

Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* The get, set values are used to manipulate the register's current value.
* The get_reset_value is used to get the register default reset value.
* The set_reset_value is used to set the reset value at initialization. This
  function throws a fatal error if called after the initialization phase is
  completed.
* The get_address is used to retrive the register's address.
* The get_name returns the register name.

field_base
-------------------------------------------------------------------------------

Extends the adi_component base class. It forms the base of all other inherited
classes. For the partent, only register_bases are valid, as it doesn't make
sense for other classes to contain a field_base class.

Variables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It stores values for the most, least significat bit position, the field access
type, the field's reset_value as well as a handle to the register.

Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* The constructor sets the variable values, calculates the reset value and
  updates the register value.
* The set and get function manipulate the registers value at the field location.
* The get_reset_value returns the registers default value at the field location.

.. include:: ../../../common/support.rst
