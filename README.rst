=============================================================================
``pipreqs`` - Generate requirements.txt file for any project based on imports
=============================================================================

.. image:: https://github.com/JOravetz/pipreqs/actions/workflows/tests.yml/badge.svg
        :target: https://github.com/JOravetz/pipreqs/actions/workflows/tests.yml


.. image:: https://img.shields.io/pypi/v/pipreqs.svg
        :target: https://pypi.python.org/pypi/pipreqs


.. image:: https://codecov.io/gh/JOravetz/pipreqs/branch/main/graph/badge.svg
        :target: https://codecov.io/gh/JOravetz/pipreqs

.. image:: https://img.shields.io/pypi/l/pipreqs.svg
        :target: https://pypi.python.org/pypi/pipreqs


**Documentation**: `Installation <https://github.com/JOravetz/pipreqs/blob/main/INSTALL.md>`_ | `Usage Guide <https://github.com/JOravetz/pipreqs/blob/main/USAGE.md>`_ | `UV Integration <https://github.com/JOravetz/pipreqs/blob/main/UV_INTEGRATION.md>`_ | `AI/Agentic Development <https://github.com/JOravetz/pipreqs/blob/main/AGENTIC_DEVELOPMENT.md>`_ | `Contributing <https://github.com/JOravetz/pipreqs/blob/main/CONTRIBUTING.md>`_

Installation
------------

.. code-block:: sh

    pip install pipreqs

For more installation options (development install, pipx, virtual environments, etc.), see `INSTALL.md <https://github.com/JOravetz/pipreqs/blob/main/INSTALL.md>`_.

Obs.: if you don't want support for jupyter notebooks, you can install pipreqs without the dependencies that give support to it. 
To do so, run:

.. code-block:: sh

    pip install --no-deps pipreqs
    pip install yarg==0.1.9 docopt==0.6.2

Usage
-----

For comprehensive usage examples and best practices, see `USAGE.md <https://github.com/JOravetz/pipreqs/blob/main/USAGE.md>`_.

Quick start::

    pipreqs /path/to/project

::

    Usage:
        pipreqs [options] [<path>]

    Arguments:
        <path>                The path to the directory containing the application files for which a requirements file
                              should be generated (defaults to the current working directory)

    Options:
        --use-local           Use ONLY local package info instead of querying PyPI
        --pypi-server <url>   Use custom PyPi server
        --proxy <url>         Use Proxy, parameter will be passed to requests library. You can also just set the
                              environments parameter in your terminal:
                              $ export HTTP_PROXY="http://10.10.1.10:3128"
                              $ export HTTPS_PROXY="https://10.10.1.10:1080"
        --debug               Print debug information
        --ignore <dirs>...    Ignore extra directories, each separated by a comma
        --no-follow-links     Do not follow symbolic links in the project
        --ignore-errors       Ignore errors while scanning files
        --encoding <charset>  Use encoding parameter for file open
        --savepath <file>     Save the list of requirements in the given file
        --print               Output the list of requirements in the standard output
        --force               Overwrite existing requirements.txt
        --diff <file>         Compare modules in requirements.txt to project imports
        --clean <file>        Clean up requirements.txt by removing modules that are not imported in project
        --mode <scheme>       Enables dynamic versioning with <compat>, <gt> or <non-pin> schemes
                              <compat> | e.g. Flask~=1.1.2
                              <gt>     | e.g. Flask>=1.1.2
                              <no-pin> | e.g. Flask
        --scan-notebooks      Look for imports in jupyter notebook files.

Example
-------

::

    $ pipreqs /home/project/location
    Successfully saved requirements file in /home/project/location/requirements.txt

Contents of requirements.txt

::

    wheel==0.23.0
    Yarg==0.1.9
    docopt==0.6.2

Why not pip freeze?
-------------------

- ``pip freeze`` only saves the packages that are installed with ``pip install`` in your environment.
- ``pip freeze`` saves all packages in the environment including those that you don't use in your current project (if you don't have ``virtualenv``).
- and sometimes you just need to create ``requirements.txt`` for a new project without installing modules.

Works great with UV
-------------------

pipreqs + `UV <https://github.com/astral-sh/uv>`_ = Lightning-fast Python development:

.. code-block:: sh

    # Generate minimal requirements
    pipreqs . --force
    
    # Install with UV (10-100x faster than pip)
    uv pip install -r requirements.txt
