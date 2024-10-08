.. _git_repository:

Testbenches Git repository
===============================================================================

This repository contains testbenches and verification components for system level
projects or components connected at block level from the HDL repository.

This repository is not a stand alone one. It must be cloned or linked as a
submodule inside the HDL repository you want to test.

All the **HDL** sources can be found in the following git repository:
:git-hdl:`/`

All the **Testbenches** sources can be found in the following git repository:
:git-testbenches:`/`

We assume that the user is familiar with `git <https://git-scm.com/>`__.
Knows how to
`clone <https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository>`__
the repository, how to check its
`status <https://git-scm.com/docs/git-status>`__ or how to
`switch <https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging>`__
between branches.

.. note::

   A basic git knowledge is required in order to work with these source files,
   if you do not have any, don't worry!

   There are a lot of great resources and tutorials about git all over the
   `web <http://lmgtfy.com/?q=git+tutorial>`__.

If you want to pull down the sources as soon as possible, just do the
following few steps:

#. Install Git from `here <https://git-scm.com/>`__
#. Open up Git bash, change your current directory to a place where you
   want to keep the hdl source
#. Clone the repository using
   `these <https://help.github.com/articles/cloning-a-repository/>`__
   instructions

Folder structure
-------------------------------------------------------------------------------

The root of the Testbenches repository has the following structure:

.. code-block::

   .
   +-- .github
   +-- docs
   +-- library
   +-- scripts
   +-- testbenches
   +-- Makefile
   +-- README.md
   +-- LICENSE

The repository is divided into 5 separate sections:

-  **.github** with all our automations regarding coding checks, GitHub actions
-  **docs** with our GitHubIO documentation and regmap source files
-  **library** with all the Analog Devices Inc. proprietary IP cores and
   hdl modules, which are required to build the projects
-  **scripts** with scripts and makefiles to build and run the testbench
-  **testbenches** with all the currently supported testbenches


The file **.gitattributes** is used to properly `handle
different <https://help.github.com/articles/dealing-with-line-endings/>`__
line endings. And the **.gitignore** specifies intentionally untracked
files that Git should ignore. The root **Makefile** can be used to build
all the project of the repository. To learn more about hdl **Makefiles**
visit the :external+hdl:ref:`Building & Generating programming files <build_hdl>` section.

Repository releases and branches
-------------------------------------------------------------------------------

The repository may contain multiple branches and tags. The
:git-testbenches:`main </>` branch is the development branch (latest sources,
but not stable). If you check out this branch, some builds may fail. If you are
not into any kind of experimentation, you should only check out one of the
release branch.

All our release branches have the following naming convention:
[year_of_release]\ **\_r**\ [1 or 2]. (e.g.
:git-testbenches:`2022_r2 <2022_r2:>`)

ADI does two releases each year when all the projects get an update to
support the latest tools and get additional new features. \*\* The
main branch is always synchronized with the latest release. \*\* If you
are in doubt, ask us on :ez:`fpga`.

.. note::

   You can find the release notes on the GitHub page of the
   repository:

   https://github.com/analogdevicesinc/testbenches/releases

   The latest version of tools used on main can be found at:
   :git-hdl:`scripts/adi_env.tcl` (*required_vivado_version* variable).
