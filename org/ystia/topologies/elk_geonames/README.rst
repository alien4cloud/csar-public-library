.. _elk_geonames_section:

*********
ELK_GEONAMES
*********

.. contents::
    :local:
    :depth: 3

Install Components and Topology template
----------------------------------------
Install the CSARs of the following YSTIA compoents to the Alien4Cloud Components catalog, and respect the order in the list:

#. **common**
#. **consul**
#. **java**
#. **kafka**
#. **elasticsearch**
#. **logstash**

Install the **elk_geonames** topology archive to the Alien4Cloud Topology template catalog.

Topology template
-----------------
The **elk_geonames** template provides the following configuration:

- Relationships between the Elasticsearch and Logstash components are created.

- ELK components are configured to be deployed on Compute hosts and appropriate Java distribution.

- Consul allows Elasticsearch cluster discovery.

- GeoNames component is hosted by the Logstash node and is already configured (see the GeoNames component's Properties list in the README associated to the Logstash component).

Create en application
---------------------
Your application can be created via the Alien4Cloud GUI using the **elk_geonames** topology shown below:

.. image:: docs/images/topology.png
   :name: elk_geonames_figure
   :scale: 100
   :align: center

Complete configuration
----------------------

- You may download the archive containing geolocation data from http://download.geonames.org/export/zip/ and install it into a local repository accessible from your application's hosts.

- Set GeoNames node's **repository** property to the local repository if used

- Note that the default value of the **filename** property is changed from "allCountries", since this file is enormous, to FR. You can change this value corresponding to the application's needs

