.. _build_tb:

Build a test bench
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

.. caution::

   Before building any testbench, you **must**:

   #. Clone the :git-hdl:`HDL repository </>`

   #. Check the Vivado version needed by entering the
      :git-hdl:`hdl/scripts/adi_env.tcl <scripts/adi_env.tcl>` file. If you do
      not want to use that (although **we strongly advise you to use it**)
      then you have the alternative of setting ``export ADI_IGNORE_VERSION_CHECK=1``
      before building the project. Otherwise your project will fail.

   #. :external+hdl:ref:`Set up the HDL repository <build_hdl>`


The :git-testbenches:`Testbenches repository </>` has to be cloned under the
:git-hdl:`HDL repository </>` as follows:

.. shell::

   $cd hdl
   $git clone git@github.com:analogdevicesinc/testbenches.git

The above command clones the **default** branch, which is the **main** for
Testbenches. The **main** branch always points to the latest stable release
branch, but it also has features **that are not fully tested**. If you
want to switch to any other branch you need to checkout that branch:

.. shell::

   $cd testbenches/
   $git branch
   $git checkout 2022_r2

Building a test bench
-------------------------------------------------------------------------------

.. caution::

   Before building any test bench, you must have the environment prepared each
   time a new terminal session is started:

   #. Set the HDL repository path with ``export ADI_HDL_DIR=<path to dir>``.

   #. Set the Testbenches repository path with ``export ADI_TB_DIR=<path to dir>``.

The way of building a test bench in Cygwin and WSL is almost the same.
In this example, it is building the **AD7616** test bench.

.. shell::

   $cd ad7616
   $make

The ``make`` builds all the libraries first and then builds the test bench.
This assumes that you have the tools and licenses set up correctly. If
you don't get to the last line, the make failed to build one or more
targets: it could be a library component or the project itself. There is
nothing you can gather from the ``make`` output (other than which one
failed). The actual information about the failure is in a log file inside
the project directory. By default, ``make`` builds all of the available
configurations and runs all of the ``test programs`` that are predefined
in the ``Makefile``.

Also, there's an option to use ``make`` using GUI, so that at the end of the
build it will launch Vivado and start the simulation with the waveform viewer
started as well.

.. shell::

   $make MODE=gui

Some projects support adding additional ``make`` parameters to configure
the project. This option gives you the ability to build only the configuration
that you're interested in, without building the rest of the available
configurations, as well as running the chosen test program, if it is the case.

If parameters were used, the result of the build will be in a folder under
``runs/``, named by the configuration used.

**Example**

Running the command below will create a folder named
**cfg_si** for the following file combination: **cfg_si** configuration file and
the **test_program_si** test program.

.. shell::

   $make MODE=gui CFG=cfg_si TST=test_program_si

Environment
-------------------------------------------------------------------------------

As mentioned above, our recommended build flow is to use ``make`` and the
command line version of the tools. This method facilitates our
overall build and release process as it automatically builds the
required libraries and dependencies.

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

.. shell::

   $export PATH=$PATH:/opt/Xilinx/Vivado/202x.x/bin:/opt/Xilinx/Vitis/202x.x/bin

Windows environment setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The best option on Windows is to use
`Cygwin <https://www.cygwin.com>`__. When installing it, select the
``make`` and ``git`` packages. You should do changes to your **.bashrc** in a
similar manner to the Linux environment.

.. shell::

   $export PATH=$PATH:/cygdrive/d/Xilinx/Vivado/202x.x/bin:/cygdrive/d/Xilinx/Vitis/202x.x/bin

A very good alternative to Cygwin is
`WSL <https://learn.microsoft.com/en-us/windows/wsl/install/>`__. The
manual changes to your **.bashrc** should look like:

.. shell::

   $export PATH=$PATH:/opt/path_to/Vivado/202x.x/bin:/opt/Vitis/202x.x/bin

If you do not want to install Cygwin, there might still be some
alternative. There are ``make`` alternatives for **Windows Command
Prompt**, minimalist GNU for Windows (**MinGW**), or the **Cygwin
variations** installed by the tools itself.

Some of these may not be fully functional with our scripts and/or projects.
If you are an AMD user, use the **gnuwin** installed as part of the SDK,
usually at ``C:\Xilinx\Vitis\202x.x\gnuwin\bin``.

Opening a testbench
-------------------------------------------------------------------------------

If you want to open the testbench and check the block design and/or the
waveform, there are two options:

- Build the testbench using ``make MODE=gui`` and it will open Vivado in GUI
  mode right after it builds the block design.

.. shell::

   $cd ad7616
   $make MODE=gui

- Build the testbench using ``make`` and open Vivado manually after the block
  design is built and the simulation is finished. In the project folder, after
  running ``make``, a ``runs/`` folder will be created. Under ``runs/`` you'll
  find one or more configuration folder, depending on how you ran the ``make``
  command. Under the folder named after the configuration is the Vivado project
  that can be opened.

.. shell::

   $cd ad7616
   $make
   $cd runs/cfg_si
   $vivado ./cfg_si.xpr

.. _AMD Xilinx Vivado: https://www.xilinx.com/support/download.html
