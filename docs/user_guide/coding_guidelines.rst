.. _coding_guidelines:

ADI Testbenches coding guidelines
===============================================================================

1. Introduction
-------------------------------------------------------------------------------

This document contains coding and documentation guidelines which must be
followed by all HDL testbenches.

The coding rules are intended to be applied to testbenches written using
System Verilog.

The HDL coding guidelines :external+hdl:ref:`hdl_coding_guidelines` are also
applicable here. In addition, there are a set of rules for System Verilog,
listed below.

2. Coding style
-------------------------------------------------------------------------------

A. Naming
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**A1**

Class names should be composed in the following way:

* <class_name>_vif - Virtual Interface
* <class_name>_env - Environment
* <class_name>_wd - Watchdog
* <class_name>_api - API class for an IP
* <class_name>_agent - Agent class for an VIP
* <class_name>_driver - Driver class for an VIP
* <class_name>_monitor - Monitor class for an VIP
* <class_name>_sequencer - Sequencer class for an VIP

**A2**

File names should be composed in the following way:

* <driver_name>_api - API
* Makeinclude_<include_name> - Makefile includes
* sp_include_<include_name> - system_project.tcl includes
* adi_regmap_<ip_name>_pkg - used in registermap class definitions
* <module_name>_pkg - generic file name
* adi_<vip_name>_vip - packaged VIP top module
* adi_<vip_name>_vip_pkg - VIP agent, driver, monitor and sequencer containing package
* adi_<vip_name>_if - VIP interface
* adi_<vip_name>_if_base_pkg - abstract interface class, to be used and implemented in the VIP interface

B. General
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**B1**

Use safe-guarded thread construct when attempting to stop/kill a thread to
prevent unknown behavior.

.. _example-b1:

Incorrect:

.. code-block:: systemverilog

   fork
     ...
   join
   disable fork;

Correct:

.. code-block:: systemverilog

   fork begin
     fork
       ...
     join
    disable fork;
   end join

**B2**

Include files should be used in Makefile and system_project.tcl scripts for
classes that have multiple dependencies.

**B3**

Testbench must finish with all threads stopped, testbench done message must be
printed and the finish system function must be called afterwards.

**B4**

Forever statement must be used instead of while(1)

.. _example-b4:

Incorrect:

.. code-block::

   while(1)
     ...

Correct:

.. code-block::

   forever
     ...

**B5**

Repeat statement must be used instead of for loops, where the same operation
block is repeated with no changes.

.. _example-b5:

Incorrect:

.. code-block:: systemverilog

   int i;
   for (i=0; i<5; i++)
     ...

Correct:

.. code-block:: systemverilog

   repeat(5)
     ...

**B6**

Watchdogs must be used to ensure that the simulation doesn't get stuck during a
run.

**B7**

Test programs must use localparams instead of parameter.

.. _example-b7:

Incorrect:

.. code-block:: systemverilog

   parameter VAL = 3;

Correct:

.. code-block:: systemverilog

   localparam VAL = 3;

**B8**

Use the proper equation type for various comparisons

* == for logical equality (1 and 0 comparison only)
* === for case equality (1, 0, x and z comparison)

C. Design Under Test
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**C1**

DUT IPs with a parameterizable registermap must have a macro that is used to
import the IPs parameters.

**C2**

IP base addresses must be defined when the block design is created.

.. _example-c2:

Case 1: AXI interface not yet connected.

.. code-block:: tcl

   set RX_DMA 0x7C420000
   ad_cpu_interconnect $RX_DMA dut_rx_dma
   adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

Case 2: AXI interface already connected.

.. code-block:: tcl

   set RX_DMA 0x7C420000
   set_property offset $RX_DMA [get_bd_addr_segs {mng_axi_vip/Master_AXI/SEG_data_dut_rx_dma}]
   adi_sim_add_define "RX_DMA_BA=[format "%d" ${RX_DMA}]"

**C3**

Testbench's FPGA part must be compatible with the IPs used in the design.

.. _example-c3:

Set FPGA part number in system_project.tcl:

.. code-block:: tcl

   # VCU118 board example:
   adi_sim_project_xilinx $project_name "xcvu9p-flga2104-2L-e"

   # Xilinx 7-series FPGA example:
   adi_sim_project_xilinx $project_name "xc7z007sclg400-1"

**C4**

All configuration parameters must be defined in the ad_project_params associative
array.

.. _example-c4:

.. code-block::

   global ad_project_params

   set ad_project_params(DATA_WIDTH) 16

   set rx_dma_cfg [list \
     DMA_TYPE_SRC 1 \
     DMA_TYPE_DEST 0 \
     ID 0 \
     AXI_SLICE_SRC 1 \
     AXI_SLICE_DEST 1 \
     SYNC_TRANSFER_START 0 \
     DMA_LENGTH_WIDTH 24 \
     DMA_2D_TRANSFER 0 \
     MAX_BYTES_PER_BURST 4096 \
     CYCLIC 0 \
     DMA_DATA_WIDTH_SRC 32 \
     DMA_DATA_WIDTH_DEST 32 \
   ]

   set ad_project_params(rx_dma_cfg) $rx_dma_cfg

**C5**

In project level testbenches, the DUT block design should come from the HDL
repository.

**C6**

If multiple test programs are created, the test program's name should hint
towards the use-case of that test program.

**C7**

If multiple configurations are created, the configuration file's name should
hint towards the use-case of that configuration file.

D. Methods
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**D1**

Function method definition must be used for operations that have no relation
with simulation time.

.. _example-d1:

Incorrect:

.. code-block:: systemverilog

   task add_function(
     input int a,
     input int b,
     output int c);

     c = a + b;
   endtask: add_function

Correct:

.. code-block:: systemverilog

   function int add_function(
     input int a,
     input int b);

     return a + b;
   endfunction: add_function

**D2**

Parenthesis must be present at method calls, even if these don't require any
input value.

.. _example-d2:

Incorrect:

.. code-block:: systemverilog

   task add_function;
     ...
   endtask: add_function

Correct:

.. code-block:: systemverilog

   task add_function();
     ...
   endtask: add_function

**D3**

All method arguments must have their direction specified as input, output or ref,
except for classes.

**D4**

Every named block must end with their identifier.

.. _example-d4:

Incorrect:

.. code-block:: systemverilog

   class verifier();
     ...
   endclass

Correct:

.. code-block:: systemverilog

   class verifier();
     ...
   endclass: verifier

E. Event scheduling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**E1**

Event synchronization between multiple threads should be avoided, unless the user
is very familiar with the simulation scheduler and knows about all of the corner
cases that may arise using multiple threads.

**E2**

#0 must not be used. This would only mean that synchronization between events is
not properly handled and it's prone to error if not used exactly the way it was
intended to be used.

**E3**

Time value and scale must be specified for delaying statements.

.. _example-e3:

Incorrect:

.. code-block:: systemverilog

   #5;

Correct:

.. code-block:: systemverilog

   #5us;
   #(5*1us);

F. Reporting
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**F1**

Reporting system functions calls from the standard must only be used in VIP files
related to the block design IP.

.. _example-f1:

.. code-block:: systemverilog

   $info("Info message example");

**F2**

Reporting macros must only be used in the test programs.

.. _example-f2:

.. code-block:: systemverilog

   `INFO(("Info message example"), ADI_VERBOSITY_LOW);

**F3**

Reporting functions from the base reporting class must be used in classes that
inherit these functions.

.. _example-f3:

.. code-block:: systemverilog

   this.info($sformatf("Data received: %d", data), ADI_VERBOSITY_MEDIUM);

**F4**

Error messages should be used where the simulation may continue if something is
not working as expected. In every other instance, where the simulation must halt
immediately, use fatal messages.

.. _example-f4:

.. code-block:: systemverilog

   this.error($sformatf("Error, but can continue"));
   this.fatal($sformatf("Error and cannot continue"));

**F5**

Verbosity settings must be set as follows:

* ADI_VERBOSITY_NONE: Only for simulation randomization state and simulation done messages
* ADI_VERBOSITY_LOW: All info messages inside the test program, with the exceptions of ADI_VERBOSITY_NONE
* ADI_VERBOSITY_MEDIUM: Inside drivers
* ADI_VERBOSITY_HIGH: Inside VIP modules, regmaps, utilities

G. Classes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**G1**

Checker and scoreboard modules must be written to be parameterizable.

..
   TODO how and what exactly this means is an open question

**G2**

Data and methods inside classes should be protected from outside access using
protected and local keywords where it makes sense.

.. _example-g2:

Incorrect:

.. code-block:: systemverilog

   int class_id;
   int device_address;

   task access_device();
     ...
   endtask: access_device

Correct:

.. code-block:: systemverilog

   // always assigned by the parent, invisible to child classes
   localparam class_id;
   // both parent and child might need access to it, prevent the outside from accessing it
   protected int device_address;

   task access_device();
     ...
   endtask: access_device

**G3**

ADI_FIFO or ADI_LIFO must be used for queues to avoid push-pull/front-back style
differences and other issues (to be implemented).

.. _example-g3:

.. code-block:: systemverilog

   adi_fifo #(data_length) fifo_buffer;

   fifo_buffer = new();

**G4**

Checker or scoreboard class should be used whenever comparing data streams.

H. VIP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**H1**

VIP agents must contain a driver, monitor and sequencer modules.

.. _example-h1:

.. code-block:: systemverilog

   class vip_driver;
     ...
   endclass: vip_driver

   class vip_monitor;
     ...
   endclass: vip_monitor

   class vip_sequencer;
     ...
   endclass: vip_sequencer

   class vip_agent;
     vip_driver vip_drv;
     vip_monitor vip_mon;
     vip_sequencer vip_seq;

     ...
   endclass: vip_agent

**H2**

VIP monitors must contain a publisher module.

.. _example-h2:

.. code-block:: systemverilog

   class vip_monitor;
     adi_publisher #(<data_type>) publisher;

     ...
   endclass: vip_monitor

**H3**

VIP drivers, monitors and sequencers must have their agent parents set.

.. _example-h3:

Incorrect:

.. code-block:: systemverilog

   class vip_agent;
     vip_driver vip_drv;
     vip_monitor vip_mon;
     vip_sequencer vip_seq;

     function new();
       vip_drv = new("Driver");
       vip_mon = new("Monitor");
       vip_seq = new("Sequencer");
     endfunction: new
   endclass: vip_agent

Correct:

.. code-block:: systemverilog

   class vip_agent;
     vip_driver vip_drv;
     vip_monitor vip_mon;
     vip_sequencer vip_seq;

     function new();
       vip_drv = new("Driver", this);
       vip_mon = new("Monitor", this);
       vip_seq = new("Sequencer", this);
     endfunction: new
   endclass: vip_agent

**H4**

VIP drivers, monitors and sequencers must not be instantiated outside of the agent.

**H5**

VIP agents, drivers, monitors and sequencers should not be parameterizable.
These classes should read parameter values from the interface class, which ha
direct access to the interface parameters.

**H6**

VIP agents should have an environment as a parent.

.. _example-h6:

Incorrect:

.. code-block:: systemverilog

   class environment;
     vip_agent vip_agnt;

     function new();
       vip_agnt = new("Agent");
     endfunction: new
   endclass: environment

Correct:

.. code-block:: systemverilog

   class environment;
     vip_agent vip_agnt;

     function new();
       vip_agnt = new("Agent", this);
     endfunction: new
   endclass: environment

**H7**

VIP agents must be instantiated with an interface class and not with a virtua
interface. AMD VIPs are an exception from this rule.

.. _example-h7:

Incorrect:

.. code-block:: systemverilog

   class vip_agent;
     protected vif vif_proxy;

     function new(virtual interface vif_proxy);
       this.vif_proxy = vif_proxy;
     endfunction: new
   endclass: vip_agent

Correct:

.. code-block:: systemverilog

   class vip_agent;
     protected vif_class vif_class_proxy;

     function new(vif_class vif_class_proxy);
       this.vif_class_proxy = vif_class_proxy;
     endfunction: new
   endclass: vip_agent

I. API
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**I1**

APIs that can control an IP that has a parameterizable registermap must also be
parameterized with the same parameters using a macro.

**I2**

APIs with registermaps must have a sanity test implemented.

.. _example-i2:

.. code-block:: systemverilog

   task sanity_test();
     axi_write (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_SCRATCH), `SET_AXI_AD7616_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
     axi_read_v (`AXI_AD7616_BA + GetAddrs(AXI_AD7616_REG_SCRATCH), `SET_AXI_AD7616_REG_SCRATCH_SCRATCH(32'hDEADBEEF));
     `INFO(("Sanity Test Done"), ADI_VERBOSITY_LOW);
   endtask

**I3**

IP register access calls must only be written inside an API.

**I4**

Every ADI IP that has a registermap must have its own API driver class.

**I5**

IRQ handler class must be used when dealing with interrupt requests.

J. Environment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**J1**

An environment must only contain VIP agents, APIs and/or checkers.

**J2**

Test_harness_env should not be inherited by any environment.

.. _example-j2:

Incorrect:

.. code-block:: systemverilog

   class test_harness_env;
     ...
   endclass: test_harness_env

   class new_env extends test_harness_env;
     ...
   endclass: new_env

Correct:

.. code-block:: systemverilog

   class test_harness_env;
     ...
   endclass: test_harness_env

   class new_env;
     ...
   endclass: new_env

**J3**

New environments should be created with the intent to be reused in other
testbenches.

K. Randomization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**K1**

Constrained randomized values must be used for randomized testing.

**K2**

Variable randomization states must always be checked.

.. _example-k2:

.. code-block:: systemverilog

   class randomizer_class;
     rand bit switch;

     function void randomize_switch();
       if (!this.switch.randomize()) begin
         `FATAL(("Randomization failed!"));
       end
     endfunction: randomize_switch
   endclass: randomizer_class

**K3**

All random variables must be randomized when the class creation occurs.

.. _example-k3:

.. code-block:: systemverilog

   class randomizer_class;
     rand bit switch;

     function new();
       this.randomize_init();
     endfunction: new

     function void randomize_init();
       if (!this.randomize()) begin
         `FATAL(("Randomization failed!"));
       end
     endfunction: randomize_init
   endclass: randomizer_class

**K4**

Test programs must output the simulation randomization state at the very
beginning of the simulation.

.. _example-k4:

.. code-block:: systemverilog

   current_process = process::self();
   current_process_random_state = current_process.get_randstate();
   `INFO(("Randomization state: %s", current_process_random_state), ADI_VERBOSITY_NONE);

**K5**

The testbench should have a randomized configuration file paired with a
randomized testbench.

3. Annexes
-------------------------------------------------------------------------------

Annex 1 System Verilog file format (different use-cases)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

4. References
-------------------------------------------------------------------------------
