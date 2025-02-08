.. _create_edit_tb:

Creation and Editing of HDL Testbenches
===============================================================================

Creating a new testbench
-------------------------------------------------------------------------------

-  Create the ``Makefile`` and list all of the currently known dependencies
-  Create the ``system_project.tcl`` script and add the currently known
   simulation dependencies there as well
-  Create at least one ``configuration file`` (it can be left empty)
-  Create the ``system_bd.tcl`` script, which creates the block design (consider
   using Verification IPs as these are created to make testing easier and facilitates
   faster testbench bring-up as well as less bugs in general)
-  Create the ``system_tb.sv`` file that connects the testbench with the block design
-  Consider creating ``classes`` that encapsulate the variables and functions, so it
   can be used in other testbenches
-  Create the ``test_program.sv`` to run the simulation
-  Update the ``Makefile`` and ``system_project.tcl`` with the new dependencies
   if needed.

Adding a new configuration to a test bench
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   Simple, all of the configurations are compatible with all of the test programs.

Requirements:

-  New ``configuration`` doesn't change the connections between the block design and
   the ``test program``.
-  ``Test program`` can be used with the new ``configuration`` without modifications.

Process:

-  Create a ``new configuration`` in ``cfg`` folder.
-  Check if the ``Makefile`` automatically includes the newly created ``configuration``,
   otherwise add it to the list manually.
-  If a ``new parameter`` needs to be added, make sure all of the other ``configuration``
   files are updated with the new parameter name and a new value as well
-  Test the configuration with the existing test program.

Adding a new test program to a test bench
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   Simple, all of the configurations are compatible with all of the test programs.

Requirements:

-  Connections between the block design and the test program don't change.
-  All of the existing ``configurations`` must be compatible with the new
   ``test program``.

Process:

-  Create a ``new test program`` in tests folder.
-  Check if the ``Makefile`` automatically includes the newly created
   ``configuration``, otherwise add it to the list manually.
-  Test the program with the existing configurations.

Creating a modified block design in the same project folder
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. warning::

   Advanced, not all configurations are compatible with the test programs.

Requirements:

-  New ``configuration file(s)`` must be created for the new block design.

Process:

-  Create a new parameter that tells the ``system_bd.tcl`` what to build.
        -   this parameter must be included in all of the existing and new
            configuration files;
        -   if the design already has multiple variations of the block design,
            update the existing parameter with the new value which corresponds
            to the new block design
-  Modify the ``system_bd.tcl`` script to use the created parameter to create the
   old or new block design.
-  In ``system_tb.sv`` use the parameter to connect the new block design with a
   new ``test program``.
-  Create the ``new test program``.
-  In the ``Makefile``, modify the TESTS list to not be automatically generated
   and add the test program:config options to the list that you want to run.
-  In the ``system_project.tcl`` add a switch that chooses between the test programs
   based on the parameter.
-  Write and test the new ``test program``.

Edit a testbench efficiently
-------------------------------------------------------------------------------

When designing a testbench, it's crucial to comprehend the steps involved
to ensure the testbench runs swiftly and exhibits predictable behavior.

By default, we link the original source file in the project, with exceptions
for VIPs and IPs source files, which are copied over to the ``cfg*.ip_user_files``
and ``cfg*.gen/sources`` paths under the testbench project directory.

A grey area exists regarding the VIP ``*_pkg.sv`` files because they are not
referenced by any VIP module but serve as auxiliary files to interact with them.
As such, they are not compiled in the IP Packager project by default, resulting
in linting not being performed because they are not listed in ``*_vlog.prj``.

Compile VIP files within the VIP project
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is possible to force Vivado to compile ``*_pkg.sv`` files by setting the
compilation order to manual (and specifying the top module since it will no
longer be discovered):

.. code:: tcl

   set_property source_mgmt_mode DisplayOnly [current_project]
   set_property top my_vip [get_filesets sim_1]
   launch_simulation -scripts_only

Change from ``DisplayOnly`` to ``None`` to revert.

After this change, ``xvlog`` will start linting the ``*_pkg.sv`` files.

If you prefer not to use the Vivado GUI, you can call ``xvlog`` directly:

.. shell::

   /path/testbenches/library/vip/adi/my_vip
   $xvlog -prj ./*.sim/sim_1/behav/xsim/*_vlog.prj \
   $    -i ../../../utilities/

And for a specific file:

.. shell::

   /path/testbenches/library/vip/adi/my_vip
   $xvlog -work xil_defaultlib --sv -i ../../../utilities \
   $    -i ../../../utilities/ \
   $    my_vip_pkg.sv

.. note::

   Ensure to call xvlog in the correct compilation order,
   to add them to ``xil_defaultlib``, otherwise call ``*_vlog.prj`` first.

Update VIP files of an open simulation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When launching a simulation, Vivado always recompiles all files.
However, VIP source files are not automatically updated, but trigger the
"Upgrade IP" mechanism, which is slow (or if using ``make``, will rebuild the
entire testbench project).

A technique to significantly speed up testing is to exploit that Vivado always
recompiles all files by patching the ``cfg*.ip_user_files`` and
``cfg*.gen/sources`` paths with the edited sources.

The following bash script demonstrates how this can be achieved, for a VIP
called `my_vip` and testbench called `my_ip_testbench`:

.. code:: bash

   # Patch VIP source files of an open simulation
   #./patch_tb.sh ; make

   my_vip_path=$ADI_TB_DIR/library/vip/adi/my_vip
   tb_path=$ADI_TB_DIR/testbenches/ip/my_ip_testbench

   my_vip_files=$(command cd $my_vip_path ; find . -maxdepth 1 -name "*.v" -or -name "*.vh" -or -name "*.sv")

   for f in $my_vip_files
   do
	f=$(basename $f)
	tee $(find $tb_path -wholename "$tb_path/runs/cfg*/cfg*.ip_user_files/bd/test_harness/ipshared/*/$f") < $my_vip_path/$f > /dev/null
	tee $(find $tb_path -wholename "$tb_path/runs/cfg*/cfg*.gen/sources_1/bd/test_harness/ipshared/*/$f") < $my_vip_path/$f > /dev/null
   done

Then, simply relaunch the simulation.
The snippet above also works with IP projects, just modify the paths.
