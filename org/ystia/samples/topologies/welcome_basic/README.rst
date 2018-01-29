**************
Welcome sample
**************

.. contents::
    :local:
    :depth: 3

welcome_basic topology
----------------------

The **welcome_basic** Ystia topology is useful to easily create an Alien4Cloud application with the **Welcome** component.
It can be used to create and deploy your first Alien4Cloud application and to check the Ystia installation.

welcome_basic CSAR
------------------

  This step may be skipped in case you use Alien4Cloud's git integration for CSARs management

Generate a zip archive file for this topology (it will be uploaded to the catalog in the next step)
::

  $ cd YOUR_SANDBOX/csar-public-library/org/ystia/samples/topologies/welcome
  $ zip -r welcome_basic-csar.zip *

Upload CSARs to the catalog
---------------------------

  This step may be skipped in case you use Alien4Cloud's git integration for CSARs management

Upload the following CSARs to the Alien4Cloud catalog, and respect the order in the list:

#. **common-csar.zip** (**common** component's CSAR)
#. **welcome-csar.zip** (**welcome** component's CSAR)
#. **welcome_basic-csar.zip**

After the CSARs upload, you may check in the Alien4Cloud Topology templates vue that the ``org.ystia.samples.welcome_basic`` template is present.


Create application
------------------

The sample application can now easily created using the ``org.ystia.samples.welcome_basic`` topology template.

.. image:: docs/images/welcome_basic_topo.png
    :scale: 100
    :align: center

Deploy the application
----------------------

The created application can now be deployed to the location of your choice.

The deployment should success if the orchestrator and the location are correctly configured (see the Alien4Cloud documentation and the orchestrator's documentation) and if the target infrastructure is available.

Now you can connect to the Welcome application using the **url** output property.

Outputs
^^^^^^^

- **url**: The URL to access the Welcome HTTP server home page

This output property can be used to easily connect to the Welcome HTTP server home page.

.. image:: docs/images/welcome_url_output_property.png
    :scale: 100
    :align: center

