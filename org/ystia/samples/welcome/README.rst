**************
Welcome sample
**************

.. contents::
    :local:
    :depth: 3

Welcome component
-----------------

The **Welcome** Ystia component is a very sample HTTP server.
It can be used to create and deploy your first Alien4Cloud application and to check the Ystia installation.

The following figure shows a *Compute* node hosting *Welcome*

.. image:: docs/images/welcome_component.png
    :scale: 80
    :align: center

The *Welcome* HTTP server index page looks like:

.. image:: docs/images/welcome_index_page.png
    :scale: 100
    :align: center

Properties
^^^^^^^^^^

- **component_version**: Version of the component.

- **port**: Port number of the Welcome HTTP server.

Attributes
^^^^^^^^^^

- **url**: The URL to access the Welcome home page.

Requirements
^^^^^^^^^^^^

- **host**: Welcome component has to be hosted on a Compute.

Artifacts
^^^^^^^^^

- **scripts**: Welcome required scripts.

- **utils_scripts**: Common util scripts for whole Ystia components.


CSAR
----

You have to generate a zip archive file for this component and upload it to the Alien4Cloud Catalog.
::

  $ cd YOUR_SANDBOX/csar-public-library/org/ystia/samples/welcome/linux/bash
  $ zip -r welcome-csar.zip *


After the csar upload, you may check in the Alien4Cloud Components vue that the following elements are presented :

- ``org.ystia.samples.welcome.linux.bash.Welcome`` component

- ``org.ystia.samples.welcome.linux.bash`` CSAR
