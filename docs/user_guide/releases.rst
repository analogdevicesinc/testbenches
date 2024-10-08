.. _releases:

Releases
===============================================================================

The Testbenches repository is released as git branches bi-annually. The release
branches are created first and then tested before being made official. That is,
the existence of a branch does not mean it is a fully tested release.

Also, the release branch is tested **only** on certain versions of the tools
and may **not** work with other versions of the tools.
The projects that are tested and supported in a release branch are listed
along with the ADI library cores that are used.

The release branch may contain other projects that are in development;
one must assume these are **not** tested, therefore **not** supported by this
release.

Porting a release branch to another Tool version
-------------------------------------------------------------------------------

It is possible to port a release branch to another tool version, though
not recommended. The ADI libraries should work across different versions
of the tools, but the projects may not. The issues are most likely with
the AMD Xilinx cores. If you must still do this, note the following:

First, disable the version check of the scripts.

The ADI build scripts are making sure that the releases are being run on
the validated tool version. It will promptly notify the user if he or
she trying to use an unsupported version of tools. You need to disable
this check by setting the environment variable ``ADI_IGNORE_VERSION_CHECK``.

Second, make AMD IP cores version change.

The Vivado projects are a bit tricky. The GUI automatically updates the
cores, but the **Tcl flow does not**.

Thus, it may be easier to create the project file with the supported version
first, then opening it with the new version.
After which, update the Tcl scripts accordingly.

The versions are specified in the following format.

.. code-block:: tcl
   :linenos:

   set sys_mb [create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:9.5 sys_mb]

You should now be able to build the design and test things out. In most
cases, it should work without much effort. If it doesn't, do an
incremental update and debug accordingly.

Release branches
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :header-rows: 1

   * - Releases
     - AMD Xilinx
     - Release notes
   * - :git-testbenches:`main <main:/>`
     - Vivado 2023.1
     -
   * - :git-testbenches:`2022_r2 <2022_r2:/>`
     - Vivado 2022.2
     - `Release notes 2022_R2 <https://github.com/analogdevicesinc/testbenches/releases/tag/2022_R2>`_


About the tools we use
-------------------------------------------------------------------------------

When AMD has a new release, we usually follow them and update our tools in a
timely manner.

Changing the version of tool used on a branch is done by updating the
:git-hdl:`adi_env.tcl <scripts/adi_env.tcl>` script.