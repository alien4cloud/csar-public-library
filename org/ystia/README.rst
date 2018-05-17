###############
The Ystia Forge
###############

.. contents::
	:local:
	:depth: 4


.. *********************************************************************************************************************

.. _introduction_section:

********
Overview
********

**Ystia Forge** provides TOSCA Components and Topology templates to easily create Big Data application clusters on demand.

Deployment of Big Data applications can be done on a public Cloud (such as Amazon), or on a private cloud (such as OpenStack), on Bare-Metal or on HPC.

The TOSCA Components and Topology templates currently contained in this repository which belongs to the **Ystia Forge**,
can be used to construct different application categories :

- Log Analysis applications based on Elastic_ components and on the Kafka_ message broker

- Applications using MySQL_ database server,

- Stream processing development and execution environment based on Flink_

- Data science development and execution environments (RStudio_, Jupyter_)

- Moreover, technical components such as *Java* and Consul_ (Consensus Systems), allow detailed application architectures to be designed.

The components are connected together in application topologies.
To simplify topology creation, Ystia Forge provides **topology templates** that can be extended by your applications.


.. _Cloudera: https://www.cloudera.com/
.. _Consul: https://www.consul.io/
.. _Elastic: https://www.elastic.co/products
.. _Flink: https://flink.apache.org/
.. _Hortonworks: https://hortonworks.com/
.. _Jupyter: http://jupyter.org/
.. _Kafka: https://kafka.apache.org/
.. _MapR: https://mapr.com/
.. _MongoDB: https://www.mongodb.com/
.. _MySQL: http://www.mysql.com/
.. _NiFi: https://nifi.apache.org/
.. _PostgreSQL: https://www.postgresql.org/
.. _RStudio: https://www.rstudio.com/


The current version of **Ystia Forge** is **2.0.0**.


.. *********************************************************************************************************************
.. _getting_license_section:

*******
License
*******

*Copyright (C) 2018 Bull S. A. S. - Bull, Rue Jean Jaures, B.P.68, 78340, Les Clayes-sous-Bois, France.*

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


.. *********************************************************************************************************************
.. _getting_started_section:

***************
Getting Started
***************

This section describes how to set up a basic application cluster using Ystia Forge components.

Ystia contains the following products:

- Alien4Cloud_, is the Ystia Studio for the end-users.
  It allows them to define application architectures and to deploy those applications on pre-configured locations.
- Ystia_Orchestrator_ is an engine allowing to orchestrate application deployment.

.. _Ystia_Orchestrator: http://TODO_TO_BE_COMPLETED/
.. _Alien4Cloud: http://alien4cloud.github.io/


.. _getting_started_requirements_section:

Requirements
============

To create and run application using Ystia Forge components require:

- A running instance of **Alien4Cloud**, version **2.0.0**.
- A running instance of **Ystia Orchestrator**, version **3.0.0**.
- The components and topology templates from **Ystia Forge**, version **2.0.0**, must be imported to the Alien4Cloud catalog.

.. _getting_started_build_section:

How to import Ystia Forge components in the catalog
===================================================

There are two possibilities to import the Ystia Forge TOSCA components and topology templates in the catalog:

#. Build a CSAR archive for every necessary components and topologies, then import them in a precise order based on the possible dependencies between them.
#. Import all the Ystia Forge components and topologies hosted in the present repository using the Alien4Cloud's *CSAR Git Integration*.

For the first method, see the example provided below for the *Welcome* sample.

For the second method:

- you need to configure a Git Location corresponding to the Ystia Forge in Alien4Cloud.

  - Repository URL: https://github.com/alien4cloud/csar-public-library.git
  - Credentials: *none*
  - Tag: **v2.0.0**
  - Archive to import: **org/ystia**

- and then execute the import operation.

.. image:: docs/images/ystia_import_via_git.png
    :scale: 100
    :align: center

Using this second method, dependencies are automatically resolved when importing CSARs with *Git integration*.

Finally, you can browse the archives list, but also the components and the topologies list to check that all the Ystia Forge is imported.

.. _getting_started_samples_section:

Welcome sample
==============

The **welcome** Ystia Forge component implements a simple HTTP server.
It can be used to create and deploy your first Alien4Cloud application and to check the Ystia installation.
An application topology called **welcome_basic** is also provided for this sample.

Detailed information can be found under:

- **org/ystia/samples/welcome** and
- **org/ystia/samples/topologies/welcome_basic**

To create the sample application you need to have in the Alien4Cloud catalog the CSARs for the welcome component and the welcome_basic topology.
Moreover, some basic Ystia Forge TOSCA types have to be available in the catalog. These types are brought by the a component called **common**.

Suppose that none of the necessary components, nor topology template are imported to the Alien4CLoud catalog.
You have to generate CSARs for *common* and *welcome* components, and *welcome_basic* topology.::

  $ cd YOUR_SANDBOX/csar-public-library/org/ystia/common
  $ zip -r common-csar.zip *
  $ cd YOUR_SANDBOX/csar-public-library/org/ystia/samples/welcome/linux/bash
  $ zip -r welcome-csar.zip *
  $ cd YOUR_SANDBOX/csar-public-library/org/ystia/samples/topologies/welcome
  $ zip -r welcome_basic-csar.zip *


Then you have to import the generated archives to the Alien4Cloud catalog by drag and drop respecting following order:

#. ``common-csar.zip``
#. ``welcome-csar.zip``
#. ``welcome_basic-csar.zip``

Finally, you can browse the archives list, but also the components and the topologies list, to check that the imported elements are presented:

- ``org.ystia.common`` ``Root``, ``SoftwareComponent``, ``DBMS`` and ``Database`` components,
- ``org.ystia.samples.welcome.linux.bash.Welcome`` component,
- ``org.ystia.samples.welcome_basic`` topology.


.. *********************************************************************************************************************

.. _components_section:

**********
Components
**********

This section lists the TOSCA components provided by Ystia Forge.

Consensus systems
=================

+------------+--------------------+---------------+
| **Consul** | *org/ystia/consul* | version 0.5.2 |
+------------+--------------------+---------------+

ELK components
==============

+-------------------+---------------------------+-----------------------+
| **Elasticsearch** | *org/ystia/elasticsearch* | versions 5.6.8, 6.2.2 |
+-------------------+---------------------------+-----------------------+
| **Logstash**      | *org/ystia/logstash*      | versions 5.6.8, 6.2.2 |
+-------------------+---------------------------+-----------------------+
| **Kibana**        | *org/ystia/kibana*        | versions 5.6.8, 6.2.2 |
+-------------------+---------------------------+-----------------------+
| **Beats**         | *org/ystia/beats*         | versions 5.6.8, 6.2.2 |
+-------------------+---------------------------+-----------------------+

****

**Note**:
  In a topology, choose the same version for all these ELK components.

****

Geolocation components
======================

+--------------+----------------------+
| **GeoNames** | *org/ystia/logstash* |
+--------------+----------------------+


Social network connectors
=========================

+----------------------+----------------------+
| **TwitterConnector** | *org/ystia/logstash* |
+----------------------+----------------------+


Message brokers
===============

+-----------+-------------------+------------------------------+
| **Kafka** | *org/ystia/kafka* | version 0.10.2.1 or 0.11.0.2 |
+-----------+-------------------+------------------------------+
| **NiFi**  | *org/ystia/nifi*  | version 1.1.2                |
+-----------+-------------------+------------------------------+


Stream & real-time processing
=============================

+-----------+-------------------+---------------+
| **Flink** | *org/ystia/flink* | version 1.1.3 |
+-----------+-------------------+---------------+


Studios for data scientists
===========================

+-------------+---------------------+-----------------+
| **Jupyter** | *org/ystia/jupyter* | version 4.3     |
+-------------+---------------------+-----------------+
| **RStudio** | *org/ystia/rstudio* | version 1.1.383 |
+-------------+---------------------+-----------------+


Database Servers
================

+-----------+-------------------+-------------+
| **MySQL** | *org/ystia/mysql* | version 5.6 |
+-----------+-------------------+-------------+


Utilities
=========

+-------------+---------------------+-----------------------------------+
| **HAProxy** | *org/ystia/haproxy* |                                   |
+-------------+---------------------+-----------------------------------+
| **Java**    | *org/ystia/java*    |                                   |
+-------------+---------------------+-----------------------------------+
| **Python**  | *org/ystia/python*  | version 2.7.14 (Anaconda 2.5.1.0) |
+-------------+---------------------+-----------------------------------+
| **XFS**     | *org/ystia/xfs*     |                                   |
+-------------+---------------------+-----------------------------------+


.. *********************************************************************************************************************

.. _topologies_section:

**********
Topologies
**********

Ystia Forge provides various topology templates, which can be used for development, demos or production applications.


.. _topologies_elk_section:

Topologies for Log Analysis based on Elastic Stack
==================================================

+-------------------+----------------------------------------------+
| **elk_basic**     | *org/ystia/topologies/elk_basic*             |
+-------------------+----------------------------------------------+
| **elk_broker**    | *org/ystia/topologies/elk_broker*            |
+-------------------+----------------------------------------------+
| **elk_ha**        | *org/ystia/topologies/elk_ha*                |
+-------------------+----------------------------------------------+
| **elk_geonames**  | *org/ystia/topologies/elk_geonames*          |
+-------------------+----------------------------------------------+

+-------------------+----------------------------------------------+
| **elk_beats**     | *org/ystia/samples/topologies/elk_beats*     |
+-------------------+----------------------------------------------+
| **elk_heartbeat** | *org/ystia/samples/topologies/elk_heartbeat* |
+-------------------+----------------------------------------------+
| **elk_dummylogs** | *org/ystia/samples/topologies/elk_dummylogs* |
+-------------------+----------------------------------------------+
| **elk_nifi**      | *org/ystia/samples/topologies/elk_nifi*      |
+-------------------+----------------------------------------------+
| **elk_twitter**   | *org/ystia/samples/topologies/elk_twitter*   |
+-------------------+----------------------------------------------+

Topologies for Flink
====================

+-----------+------------------------------+
| **flink** | *org/ystia/topologies/flink* |
+-----------+------------------------------+

Topologies for Studios for data scientists
==========================================

+-------------+--------------------------------+
| **jupiter** | *org/ystia/topologies/jupyter* |
+-------------+--------------------------------+
| **rstudio** | *org/ystia/topologies/rstudio* |
+-------------+--------------------------------+


Topologies for MySQL
====================

+------------------+-------------------------------------+
| **mysql_single** | *org/ystia/topologies/mysql_single* |
+------------------+-------------------------------------+


.. *********************************************************************************************************************

.. _recovery_section:

********
Recovery
********

This section describes how to recover manually Ystia components.
This will be useful, for example, after a reboot of VMs that host Ystia components.

The start/stop scripts of Ystia components are integrated as **services** into the Linux init system **systemd**.

Some Ystia components/services are automatically started at boot, while others are not.

Useful **systemd** basic commands:

- To start a service::

    $ sudo systemctl start <service-name>

- To stop a service::

    $ sudo systemctl stop <service-name>

- To get the status of a service, followed by most recent log data from the journal::

    $ sudo systemctl status <service-name>

- To show the messages for the service::

    $ journalctl -u <service-name>

  or::

    $ journalctl -u <service-name> --no-pager

Consul
======

The Consul component (agent and server) matches the **consul** systemd service.

The **consul** service is not started at boot.

The **consul** service corresponding to the server must be started first, then the **consul** services corresponding
to the agents can be started.

ELK and Kafka
=============

Elasticsearch
-------------

The Elasticsearch component matches the **elasticsearch** systemd service.

The **elasticsearch** service is not started at boot.

If the Elasticsearch component depends on a Consul agent, the associated **consul** service must be started first.

Logstash
--------

The Logstash component matches the **logstash** systemd service.

The **logstash** service is not started at boot.

If the Logstash component depends on a Consul agent, the associated **consul** service must be started first.

Kibana
------

The Kibana component matches two systemd services:

- **kibana** service
- **elasticsearch** service corresponding to the Elasticsearch client associated to Kibana.

When the **kibana** service is started, the **elasticsearch** service is automatically started.

When the **kibana** service is stopped, the **elasticsearch** service is not automatically stopped.

So, to start Kibana component, just start the **kibana** service. To stop Kibana component,
stop the **elasticsearch** service, then the **kibana** service .

The **kibana** service is not started at boot.

If the Kibana component depends on a Consul agent, the associated **consul** service must be started first.

Beats
-----

Each Beats component matches one systemd service :

- FileBeat: **filebeat** service
- PacketBeat: **packetbeat** service
- TopBeat: **topbeat** service

The beat services are not started at boot.

Kafka
-----

The Kafka component matches two systemd services:

- **zookeeper** service
- **kafka** service

To start Kafka component, start first the **zookeeper** service, then the **kafka** service.

To stop Kafka component, stop first the **kafka** service, then the **zookeeper** service.

The **zookeeper** and **kafka** services are not started at boot.

If the Kafka component depends on a Consul agent, the associated **consul** service must be started first.

For a Kafka cluster, **zookeeper** services must be started first on all the nodes of the cluster,
then **kafka** services can be started.

ELK topologies
--------------

For **elk-basic** topology, the start order of the services is the following:

- Start consul server on Compute_CS
- Start consul agents on Compute_ES, Compute_KBN, and Compute_LS
- Start elasticsearch service on Compute_ES
- Start kibana service on Compute_KBN (elasticsearch client service is automatically started)
- Sart logstash service on Compute_LS.

For **elk-broker** topology, the start order of the services is the following:

- Start consul server on Compute_CS
- Start consul agents on Compute_ES, Compute_KBN, Compute_KFK, Compute_LI and Compute_LS
- Start elasticsearch service on Compute_ES
- Start kibana service on Compute_KBN (elasticsearch client service is automatically started)
- Start zookeeper service, then kafka service on Compute_KFK
- Start logstash service on Compute_LI
- Start logstash service on Compute_LS.

For **elk-ha** topology:

- Mount the **LinuxFileSystem** on the nodes of Elasticsearch cluster and Kafka cluster. For example::

    $ sudo mount /dev/vdb1 /mountedStorageES
    $ sudo mount /dev/vdb1 /mountedStorageKFK

- Start services in the same order as for **elk-broker** topology except for Kafka cluster.
  Indeed, **zookeeper** services must be started first on all the nodes of the cluster,
  then **kafka** services can be started.

Studios for data scientists
===========================

RStudio
-------

The RStudio component matches the **rstudio-server** systemd service.

The **rstudio-server** service is automatically started at boot.

Jupyter
-------

The Jupyter component matches the **jupyter** systemd service.

The **jupyter** service is not started at boot.


.. *********************************************************************************************************************

.. _monitoring_toubleshooting_section:

******************************
Monitoring and troubleshooting
******************************

Alien4Cloud
===========

Logs
----

Logs path depends on how you have started Alien4Cloud.

For more information about Alien4Cloud Logs, refer to
http://alien4cloud.github.io/#/documentation/2.0.0/admin_guide/installation_configuration.html

Backup / Restore procedure
--------------------------

For more information about Alien4Cloud Backup/Restore, refer to
http://alien4cloud.github.io/#/documentation/2.0.0/admin_guide/backup_restore.html


Known issues
============

Elasticsearch: Limit of total fields in index may be exceeded
-------------------------------------------------------------

Using the TwitterConnector on Logstash and storing those events in Elasticsearch may causevthe exceeding of the limit
of total fields in index.
In this case, this log appears in *elasticsearch* Logstash output logs::

  [WARN ][logstash.outputs.elasticsearch] Failed action. {:status=>400, :action=>[“index”, ...], :response=>{“index”=>{“_index”=>”logstash-2017.01.26”, ...,”reason”=>”Limit of total fields [1000] in index [logstash-2017.01.26] has been exceeded”}}}}


**Workaround**

See Elasticsearch documentation for details:

- https://www.elastic.co/guide/en/elasticsearch/reference/5.1/mapping.html#mapping-limit-settings

- https://www.elastic.co/guide/en/elasticsearch/reference/5.1/indices-templates.html

You can update this limit after the index has been created as for example::

    PUT my_index/_setting
    {
        "index.mapping.total_fields.limit": 2000
    }

or using index templates before the index creation as for example::

    PUT _template/my_template
    {
        "template" : "logstash-*",
        "order" : my_order
        "settings" : {"index.mapping.total_fields.limit": 2000 }
    }


.. *********************************************************************************************************************

.. _references_section:

**********
References
**********

Alien4Cloud documentation
  https://alien4cloud.github.io/#/documentation/2.0.0/index.html

Ystia Orchestrator documentation
  https://TODO_to_be_completed


