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


For example, the `org.alien4cloud.apache.pub` archive describe an abstract node type for apache and it's capabilities. `org.alien4cloud.apache.linux`_ans and `org.alien4cloud.apache.linux_sh` are two different implementations that inherit from the same abstract type and expose the same public capabilities. They both can be exposed as service and so be matched as their common abstract type.


CSAR
----

You have to generate a zip archive file for this component and upload it to the Alien4Cloud catalog in order to make the common Ystia TOSCA types and utils_scripts available for all the other Ystia components and topology templates.

::

  $ cd YOUR_SANDBOX/csar-public-library/org/alien4cloud/consul/pub
  $ zip -r common-csar.zip *


After the upload, you may check in the Components vue that the following elements are presented :

 - `org.ystia.common` `Root`, `SoftwareComponent`, `DBMS` and `Database` Components

 - `org.ystia.common` CSAR



For example, the `org.alien4cloud.apache.pub` archive describe an abstract node type for apache and it's capabilities. `org.alien4cloud.apache.linux`_ans and `org.alien4cloud.apache.linux_sh` are two different implementations that inherit from the same abstract type and expose the same public capabilities. They both can be exposed as service and so be matched as their common abstract type.

```
component_version:
  type: version
  default: 7.0.51
  constraints:
    - valid_values: [ "7.0.51" ]
```