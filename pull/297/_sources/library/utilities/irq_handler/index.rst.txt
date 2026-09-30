.. _irq_handler:

IRQ Handler
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of this class is to provide an object that can simulate a processor
interrupt handler. The class relies on the AXI Interrupt Controller from AMD and
it uses an IO VIP to monitor the IRQ pin. 

.. svg:: library/utilities/irq_handler/irq_handler.svg
   :align: center

Variables
-------------------------------------------------------------------------------

None are available for direct external access.

Functions
-------------------------------------------------------------------------------

function new();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the irq_handler object. It requires a name, a master AXI sequencer
reference object with which it accesses the interrupt controller, the address of
the controller, the IO VIP interface handler and a parent if it's the case.

function void enable_software_testing();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enables software testing.

task software_irq_testing();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Triggeres a software interrupt test, which can be used to verify certain
functions at system powerup.

task start();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Starts the IRQ handler, which configures and enables the interrupt controller.
After that, it monitors the IO VIP, waiting for the arrival of interrupts. Once
triggered, it goes over the list of triggered interrupts and signals the
responsible classes to handle their respective interrupt. If software testing is
enabled, it will automatically trigger a software interrupt after starting the
monitor.

function event register_device(input int position);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Registers an event reference for an object, that has an interrupt signal
connected to the controller. Gives a fatal error if a device is already
registered in the same location.

Usage
-------------------------------------------------------------------------------

* Declare the irq handler, set up with the required parameters
* Registers all devices that are connected to the interrupt controller
* Optionally enable software interrupt
* Start the irq handler

.. include:: ../../../common/support.rst
