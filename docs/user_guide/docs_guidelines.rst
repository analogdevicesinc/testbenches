.. _docs_guidelines:

Documentation guidelines
================================================================================

This documentation is built with `Sphinx <https://www.sphinx-doc.org>`_ and
all source code is available at the path :git-testbenches:`docs`.

To contribute to it, open a pull request with the changes to
:git-testbenches:`this repository </>`, just make sure to read the general
:ref:`doctools:docs_guidelines` first **and** the additional guidelines
below specific to the Testbenches repository.

Templates
--------------------------------------------------------------------------------

Templates are available:

* :git-testbenches:`docs/projects/ip_based/template` (:ref:`rendered <ip_based_template>`).
* :git-testbenches:`docs/projects/project_based/template` (:ref:`rendered <project_based_template>`).

Remove the ``:orphan:`` in the first line, it is to hide the templates from the
`TOC tree <https://www.sphinx-doc.org/en/master/usage/restructuredtext/directives.html#directive-toctree>`_,
and make sure to remove any placeholder text and instructive comment.

.. note::

   The old wiki uses `dokuwiki <https://www.dokuwiki.org/dokuwiki>`_. When
   importing text from there, consider ``pandoc`` and the tips accross the
   :ref:`doctools:docs_guidelines` to convert it to reST.

Common sections
--------------------------------------------------------------------------------

The **More information** and **Support** sections that are present in
the Testbenches documentation, are actually separate pages inserted as links.
They're located at testbenches/projects/common/more_information.rst and /support.rst,
and cannot be referenced here because they don't have an ID at the beginning
of the page, so not to have warnings when the documentation is rendered that
they're not included in any toctree.

They are inserted like this:

.. code-block::

   .. include:: ../projects/common/more_information.rst

   .. include:: ../projects/common/support.rst

And they will be rendered as sections of the page.
