.. _io_vip:

IO VIP
================================================================================

.. hdl-component-diagram::

This IO VIP is meant to allow users to control and monitor each pin individually
or group of pins, synchronously or asynchronously.

Features
--------------------------------------------------------------------------------

* Support Master, Slave and Passthrough modes
* Support runtime switching when in Passthrough mode
* Bus width of up to 1024 bits
* IO synchronization to a clock source

Files
--------------------------------------------------------------------------------

.. list-table::
   :header-rows: 1

   * - Name
     - Description
   * - :git-testbenches:`library/vip/adi/io_vip/io_vip.sv`
     - Connects the VIP module with the interface.
   * - :git-testbenches:`library/vip/adi/io_vip/io_vip_if.sv`
     - SystemVerilog source for the VIP interface.
   * - :git-testbenches:`library/vip/adi/io_vip/io_vip_base_pkg.sv`
     - SystemVerilog source for the VIP interface base class.
   * - :git-testbenches:`library/vip/adi/io_vip/io_vip_top.v`
     - Verilog source file for the top module.

Configuration parameters
--------------------------------------------------------------------------------

.. hdl-parameters::

Interface
--------------------------------------------------------------------------------

.. hdl-interfaces::

Detailed Description
--------------------------------------------------------------------------------

The IO VIP is designed to control and/or monitor a single signal that has 1 or
more bits. The VIP has an initial configuration phase when integrating in a
block design and a runtime configuration phase when in passthrough mode.
The VIP can be switched to runtime master, slave or passthrough mode when the
VIP if configured as passthrough, by calling one of the VIP functions described
below.

VIP functions for runtime configuration
--------------------------------------------------------------------------------

function void set_master_mode();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Configures the Passthrough VIP to be a master. In this mode the VIP drives the
output signal.

function void set_slave_mode();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Configures the Passthrough VIP to be a slave. In this mode the VIP monitors the
input signal.

function void set_passthrough_mode();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Configures the Passthrough VIP to be a passthrough. In this mode the VIP
monitors the signal that goes through the VIP.

VIP interface class functions
--------------------------------------------------------------------------------

function void set_io(input logic [1023:0] o);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sets the output value of the VIP to the specified value. Must be in runtime
master mode.

function logic [1023:0] get_io();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Gets the input value of the VIP. Must be in runtime slave mode.

task wait_io_change();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wait until a change occurs on the input signal.

task wait_posedge_clk();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wait for a positive edge on the clock. Works only in synchronous mode.

task wait_negedge_clk();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Wait for a negative edge on the clock. Works only in synchronous mode.

function int get_width();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Returns the bitwidth set for the VIP.

References
--------------------------------------------------------------------------------

* VIP IP code at :git-testbenches:`library/vip/adi/io_vip/`
