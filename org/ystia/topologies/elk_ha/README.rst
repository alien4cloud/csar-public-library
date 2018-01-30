.. _elk_ha_section:

******
ELK_HA
******

.. contents::
    :local:
    :depth: 3


Import Components and Topology template
----------------------------------------

  This step may be skipped in case you use Alien4Cloud's git integration for CSARs management

Upload the following Ystia components' CSARs to the Alien4Cloud catalog, and respect the order in the list:

#. **common**
#. **consul**
#. **java**
#. **kafka**
#. **elasticsearch**
#. **logstash**
#. **kibana**

Upload the **elk_broker** topology archive to the Alien4Cloud Topology template catalog.


Topology template
-----------------
The **elk_ha** topology template provides even higher resilience to Log Analysis applications then the *elk_broker**.
It enriches this template by attaching a **BlockStorage** component to the Elasticsearch and Kafka instances Compute node.
This ensures no data loss even in case all the Elasticsearch or Kafka cluster nodes go down.

Create en application
---------------------
A Log Analysis application can be created via the Alien4Cloud GUI using the **elk_ha** topology shown below:

.. image:: docs/images/topology.png
   :name: elk_ha_figure
   :scale: 100
   :align: center

Complete configuration
----------------------

- You will probably need to upload **Logstash** nodes' configuration files (at least **input_conf** and **filter_conf** artifacts).

- Create a **Kibana Dashboard** to present the specific data items corresponding to the application needs.

- **Elasticsearch cluster** may need to be configured, as described in the **Elasticsearch** component's documentation.
