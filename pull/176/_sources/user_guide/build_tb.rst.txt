.. _build_tb:

Build a testbench
===============================================================================

**Please note that ADI only provides the source files necessary to create and
build the designs. This means that you are responsible for modifying and
building these projects.**

Here, we are giving you a quick rundown on how we build things. That said,
the steps below are **not a recommendation**, but a suggestion.
How you want to build these projects is entirely up to you.
The only catch is that if you run into problems, you have to resolve them independently.

The build process depends on certain software and tools, which you could use in
many ways. We use **command line** and mostly **Linux systems**. On Windows, we
use **Cygwin**.

.. _build_tb set_up_tb_repo:

Set up the Testbenches repository
-------------------------------------------------------------------------------

.. important::

   Before building any testbench, you **must**:

   #. Clone the :git-hdl:`HDL repository </>`

   #. Check the Vivado version needed by entering the
      :git-hdl:`hdl/scripts/adi_env.tcl <scripts/adi_env.tcl>` file. If you do
      not want to use that (although **we strongly advise you to use it**)
      then you have the alternative of setting ``export ADI_IGNORE_VERSION_CHECK=1``
      before building the project. Otherwise your project will fail.

   #. :external+hdl:ref:`Set up the HDL repository <build_hdl>`


The :git-testbenches:`Testbenches repository </>` can be cloned anywhere
relative to the :git-hdl:`HDL repository </>`. Our recommendation is to clone
the testbenches repository next to the HDL repository:

.. shell::
   :showuser:

   $git clone git@github.com:analogdevicesinc/testbenches.git

The above command clones the **default** branch, which is the **main** for
Testbenches. The **main** branch always points to the latest stable release
branch, but it also has features **that are not fully tested**. If you
want to switch to any other branch you need to checkout that branch:

.. shell::
   :showuser:

   $cd testbenches/
   $git branch
   $git checkout 2022_r2

Environment
-------------------------------------------------------------------------------

Our recommended build flow is to use ``make`` and the command line version of
the tools. This method facilitates our overall build and release process as it
automatically builds the required libraries and dependencies. Before running
any testbench, the environment in which your working must be prepared.

Linux environment setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All major distributions should have ``make`` installed by default. If not,
if you try the command, it should tell you how to install it with the
package name.

You may have to install ``git`` (``sudo apt-get install git``)
and the AMD tools. These tools come with certain **settings*.sh** scripts that
you may source in your **.bashrc** file to set up the environment.
You may also do this manually (for better or worse); the following snippet is
from a **.bashrc** file. Please note that unless you are an expert at manipulating
these things, it is best to leave it to the tools to set up the environment.

For Vivado versions of 2025 and later, use the following command:

.. shell::
   :showuser:

   $export PATH=$PATH:/opt/Xilinx/202x.x/Vivado/bin:/opt/Xilinx/202x.x/Vitis/bin

For Vivado versions prior to 2025, use the following command:

.. shell::
   :showuser:

   $export PATH=$PATH:/opt/Xilinx/Vivado/202x.x/bin:/opt/Xilinx/Vitis/202x.x/bin

Windows environment setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The best option on Windows is to use
`Cygwin <https://www.cygwin.com>`__. When installing it, select the
``make`` and ``git`` packages. You should do changes to your **.bashrc** in a
similar manner to the Linux environment.

For Vivado versions of 2025 and later, use the following command:

.. shell::
   :showuser:

   $export PATH=$PATH:/cygdrive/d/Xilinx/202x.x/Vivado/bin:/cygdrive/d/Xilinx/202x.x/Vitis/bin

For Vivado versions prior to 2025, use the following command:

.. shell::
   :showuser:

   $export PATH=$PATH:/cygdrive/d/Xilinx/Vivado/202x.x/bin:/cygdrive/d/Xilinx/Vitis/202x.x/bin

A very good alternative to Cygwin is
`WSL <https://learn.microsoft.com/en-us/windows/wsl/install/>`__. The
manual changes to your **.bashrc** should look like:

For Vivado versions of 2025 and later, use the following command:

.. shell::
   :showuser:

   $export PATH=$PATH:/opt/path_to/202x.x/Vivado/bin:/opt/202x.x/Vitis/bin

For Vivado versions prior to 2025, use the following command:

.. shell::
   :showuser:

   $export PATH=$PATH:/opt/path_to/Vivado/202x.x/bin:/opt/Vitis/202x.x/bin

If you do not want to install Cygwin, there might still be some
alternative. There are ``make`` alternatives for **Windows Command
Prompt**, minimalist GNU for Windows (**MinGW**), or the **Cygwin
variations** installed by the tools itself.

Some of these may not be fully functional with our scripts and/or projects.
If you are an AMD user, use the **gnuwin** installed as part of the SDK,
usually at ``C:\Xilinx\202x.x\Vitis\gnuwin\bin`` for Vitis versions of 2025 and
later, or ``C:\Xilinx\Vitis\202x.x\gnuwin\bin`` for prior versions.

Repository path setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The make script must know where the cloned HDL and Testbenches repositories are
located. One variable must be exported, which specifies the target directory:

.. shell::
   :showuser:

   $export ADI_HDL_DIR=<path to cloned HDL directory>

Building a testbench
-------------------------------------------------------------------------------

.. important::

   Before building any testbench, you must have the environment prepared each
   time a new terminal session is started, following the environment setup guide
   from above!

The way of building a testbench in Cygwin and WSL is almost the same.
In this example, it is building the **Base** testbench.

.. shell::
   :showuser:

   $cd testbenches/ip/base
   $make

The ``make`` builds all the libraries first and then builds the testbench. The
testbench build folder is in the testbench project's location under ``runs/``
with the configuration's name as Vivado project name. This assumes that you have
the tools and licenses set up correctly and the build finishes with no errors.
If the make fails to build one or more targets, there is no useful information
you can gather from the ``make`` output (other than which target failed to
build). The actual information about the failure is in a log file inside
the target's directory. By default, ``make`` builds all of the available
configurations and runs all of the ``test programs`` that are predefined
in the ``Makefile``.

There are multiple ``make`` parameters that can be used to build and run a
simulation.

**Examples**

The ``all`` keyword is the same as running ``make`` by itself with no additional
configuration/test program parameter. Often used in combination with ``clean``
parameter.

.. shell::
   :showuser:

   $make all

Another build option is to use the configuration file's name as a make parameter
without any other input. This will build the configuration and run all test
programs on it.

.. shell::
   :showuser:

   $make cfg

Some projects support adding additional ``make`` parameters to configure
the project. This option gives you the ability to build only the configuration
that you're interested in, without building the rest of the available
configurations, as well as running the chosen test program. ``CFG`` specifies
the configuration file's name, while ``TST`` specifies the test program's name.

.. shell::
   :showuser:

   $make CFG=cfg1 TST=test_program

.. caution::

   Trying to run incompatible configuration and test program combinations will
   result in simulation error! Please refer to the projects guide to check
   compatibility.

.. note::

   When running the ``make`` command with one of the above mentioned 3 options,
   please choose only 1 of them! Using multiple options may lead to building
   multiple designs and running multiple test programs.

The ``clean`` keyword removes the ``runs`` and ``results`` folders, as well as
the log files created by Vivado.

.. shell::
   :showuser:

   $make clean

There's an option to use Vivado's XSim GUI, so that at the end of the build it
will launch Vivado and start the simulation with the waveform viewer started as
well. By default, ``make`` launches Vivado in batch mode, meaning that it won't
provide a GUI, only a result in the terminal at the end of the simulation.

.. shell::
   :showuser:

   $cd testbenches/ip/base
   $make MODE=gui

The ``STOP_ON_ERROR`` parameter is mainly used for continuous integration
purposes, which allows the user to build and run all testbenches even if one
fails. The only exception to this is when a library fails to build, as this will
prevent any of the testbench designs to be run. The default value is ``y``,
which halts the simulation once it runs into an error. The other option to run
all testbenches is ``n``. This is useful for checking which configuration and
test program configurations are failing.

.. shell::
   :showuser:

   $make STOP_ON_ERROR=y

Rerunning a simulation
-------------------------------------------------------------------------------

If you want to rerun a simulation, you can do it in a couple of different ways,
depending on what you're trying to do.

The most straightforward and easiest way is to rerun the ``make`` command with
the parameters it was ran initially if it is the case. This will rebuild any
libraries and/or the testbench block design if any of them changed and then run
the simulation. If there are changes that affect the architecture of the
testbench, then design is going to be rebuilt. If only the simulation files are
updated, which don't affect the testbench block design, then only the simulation
will be run. This is the recommended way to run the testbench to avoid any
issues if the source files are modified.

.. attention::

   Vivado must be closed before rerunning the ``make`` command!

In GUI mode, if the simulation was already run, there are a couple of options
for restarting it.

* The first option is to run the simulation again, with the ``Restart`` button
  or by running the ``restart`` TCL command. This will reset the simulation and
  start it again without recompiling the files.
* The second option is to recompile the project and then run the simulation.
  This is done by clicking the ``Relaunch Simulation`` button. This will not
  close the simulation window, but it will recompile the project and start the
  simulation.
* The third option is to close the simulation window and use the ``Run
  simulation`` option from the Flow Navigator. This will recompile the project
  and start the simulation. This is needed when project simulation parameters
  are changed after the build was created or when the block design is changed
  manually. When the simulation seed is changed or randomized, and you want to
  rerun the simulation with an updated seed value, this is the option that must
  be used.

.. note::

   When rerunning a simulation in GUI mode, there is a slight chance that
   Vivado crashes. The reason for this is unknown, and it usually happens when
   the restarting process is going and the user tries putting the process in the
   background via the pop-up window.

Opening a testbench
-------------------------------------------------------------------------------

If you want to open the testbench and check the block design and/or the
waveform, there are two options:

- Build the testbench using ``make MODE=gui`` and it will open Vivado in GUI
  mode right after it builds the block design.

.. shell::
   :showuser:

   $cd testbenches/ip/base
   $make MODE=gui

- Build the testbench using ``make`` and open Vivado manually after the block
  design is built and the simulation is finished. In the project folder, after
  running ``make``, a ``runs/`` folder will be created. Under ``runs/`` you'll
  find one or more configuration folder, depending on how you ran the ``make``
  command. Under the folder named after the configuration is the Vivado project
  that can be opened.

.. shell::
   :showuser:

   $cd testbenches/ip/base
   $make
   $cd runs/cfg1
   $vivado ./cfg1.xpr

.. _AMD Xilinx Vivado: https://www.xilinx.com/support/download.html
