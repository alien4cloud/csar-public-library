.. _cloudera_section:

********
Cloudera
********

.. contents::
    :local:
    :depth: 3

Cloudera Overview
-----------------

**Cloudera Manager** is an end-to-end application for easily deploying and managing **Cloudera Distribution Hadoop (CDH)** clusters
(complete CDH stack and other managed services).

The **Cloudera Manager Server** is the heart of Cloudera Manager.
This Server hosts the Admin Console Web Server, and is responsible, together with the agents,
for installing software, configuring, starting and stopping services, and managing the cluster on which the services run.

.. image:: docs/images/cloudera_manager_architecture.png
    :scale: 100
    :align: center


The Cloudera Manager Server uses the following components:

- **Agent**: installed on every host, the agent starts and stops processes, unpack configurations, trigger installations, and monitor the host.

- **Management Service**: a set of roles that perform various monitoring, alerting, and reporting functions.

- **Database**: stores configuration and monitoring information.

- **Cloudera Repository**: software repository for distribution by Cloudera Manager.

- **Clients**: interfaces with the server:

  - **Admin Console**: Web-based UI used by administrators to manage clusters and Cloudera Manager.

  - **API**: used by developers to create custom Cloudera Manager applications.


Ystia provides two components for Cloudera, both being packed in the same Ystia CSAR:

#. **ClouderaServer**, which includes the Cloudera Manager Server and an embedded database, and runs on the main node.
#. **ClouderaAgent**, which includes the Cloudera Manager Agent, and runs on each cluster node.


ClouderaServer Component
------------------------

*ClouderaServer* provides the Cloudera Manager Server with an embedded PostgreSQL database. It requires a CentOS 7 Linux system.

.. image:: docs/images/cloudera_server.png
    :scale: 80
    :align: center

Attributes
^^^^^^^^^^

- **url**: URL of the Cloudera Manager Admin console (default user/password: admin/admin).

Properties
^^^^^^^^^^

- **component_version:** Version of the component.

- **cloudera_manager_repository** : Alternative download repository for Cloudera Manager Server.

  - Default : https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/5.14.1/


- **ntp_server**: IP address or name of the NTP server to use.

  - Default : fr.pool.ntp.org

Requirements
^^^^^^^^^^^^

- **host**: ClouderaServer requires to be hosted on a Compute with **linux** type and **centos** distribution.

- **consul**: ClouderaServer must be connected to a Consul agent hosted on the same Compute.

Capabilities
^^^^^^^^^^^^

- **cloudera_server_endpoint**: Allows ClouderaAgent to connect to this ClouderaServer

Artifacts
^^^^^^^^^

- **data**: Data files for setting up the yum repositories files.

- **scripts**: ClouderaServer required scripts.

- **utils_scripts**: Common util scripts for whole Ystia components.


ClouderaAgent Component
-----------------------

ClouderaAgent provides the Cloudera Manager Agent. It requires a CentOS 7 Linux system.

.. image:: docs/images/cloudera_agent.png
    :scale: 80
    :align: center

Properties
^^^^^^^^^^

- **component_version:** Version of the component.

- **cloudera_manager_repository** : Alternative download repository for Cloudera Manager Server.

  - Default : https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/5.14.1/

- **cdh_version:** Version of Cloudera Distribution Hadoop (CDH).

- **cdh_repository** : Alternative download repository for CDH.

  - Default : https://archive.cloudera.com/cdh5/redhat/7/x86_64/cdh/5/

- **cdh_kafka_repository** : Alternative download repository for CDH Kafka.

  - Default : http://archive.cloudera.com/kafka/redhat/7/x86_64/kafka/3.0.0/

- **ntp_server**: IP address or name of the NTP server to use.

  - Default : fr.pool.ntp.org

Requirements
^^^^^^^^^^^^

- **host**: ClouderaAgent requires to be hosted on a Compute with **linux** type and **centos** distribution.

- **consul**: ClouderaAgent must be connected to a Consul agent hosted on the same Compute.

- **server_endpoint**: ClouderaAgent must be connected to a ClouderaServer.

Artifacts
^^^^^^^^^

- **data**: Data files for setting up the yum repositories files.

- **scripts**: ClouderaAgent required scripts.

- **utils_scripts**: Common util scripts for whole Ystia components.

