******************
Ystia Common types
******************

.. contents::
    :local:
    :depth: 3

Common
------

This is a technical component that contains TOSCA types and utility scripts used by all the Ystia components.

The TOSCA types are derived from TOSCA normative types such as `tosca.nodes.Root`, `tosca.nodes.SoftwareComponent`, `tosca.relationships.ConnectsTo`, etc....

The scripts are grouped in artifact named **utils_scripts** in order to factorize the common util scripts for whole Ystia components.

CSAR
----

You have to generate a zip archive file for this component and upload it to the Alien4Cloud catalog in order to make the common Ystia TOSCA types and utils_scripts available for all the other Ystia components and topology templates.


  $ cd YOUR_SANDBOX/csar-public-library/org/alien4cloud/consul/pub

  $ zip -r common-csar.zip *


After the upload, you may check in the Components vue that the following elements are presented :

 - `org.ystia.common` `Root`, `SoftwareComponent`, `DBMS` and `Database` Components

 - `org.ystia.common` CSAR


