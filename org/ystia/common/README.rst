******************
Ystia Common types
******************

.. contents::
    :local:
    :depth: 3

Common
------

This is a technical component that contains TOSCA types and utility scripts used by all the YSTIA components.

The TOSCA types are derived from TOSCA normative types such as *tosca.nodes.Root*, *tosca.nodes.SoftwareComponent*, *tosca.relationships.ConnectsTo*, etc....

The scripts are grouped in artifact named **utils_scripts** in order to factorize the common util scripts for whole YSTIA components.

CSAR
----

You have to generate a zip file for this component and upload it to the Alien4Cloud catalog in order to make the common YSTIA TOSCA types and utils_scripts available for all the other YSTIA components and topology templates.

```
$ cd YOUR_SANDBOX/csar-public-library/org/alien4cloud/consul/pub
$ zip -r common.zip *
```

After the zip upload, you may check in the Components vue that the following elements are presented :

 - org.ystia.common Root, SoftwareComponent, DBMS, Database Components

 - org.ystia.common CSAR


