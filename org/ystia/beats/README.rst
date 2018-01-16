.. _beats_section:

****************
Beats components
****************

.. contents::
    :local:
    :depth: 3

Beats are data shippers for many types of data that can enrich Logstash, be searched and analyzed in Elasticsearch, and visualized in Kibana.
Currently in BDCF, three Beats are available:

- **FileBeat** which ships file contents (typically log files)
- **MetricBeat** which ships metrics about process/system/filesystem
- **PacketBeat** which ships information about network traffic

FileBeat
--------

The following figure shows a FileBeat topology example.

.. image:: docs/images/FileBeat.png
   :name: FileBeat_figure
   :scale: 100
   :align: center

Properties
^^^^^^^^^^

- **component_version:** Version of the component.

- **files**: A coma separated list of files to monitor

  - Default: /var/log/\*.log
- **debug**: Enable debug logs for this beat. Logs are located under ~/<Component_Name>/beat.log

  - Default: false


Requirements
^^^^^^^^^^^^

- **host**: FileBeat component requires to be hosted on a Compute.
- **search_endpoint**: FileBeat component may be connected to ElasticSearch.
- **logstash_endpoint**: FileBeat component may be connected to Logstash.

****

**Notes**
  FileBeat component should be connected to at least one of ElasticSearch or Logstash.

  If FileBeat component is connected to ElasticSearch, it should also be connected to Consul in order to discover the ElasticSearch cluster. Exception: if FileBeat is on the same compute than ElasticSearch, Consul is not mandatory.

****

Artifacts
^^^^^^^^^

- **beat_bin**: Binary distribution of FileBeat. This artifact can be used to update FileBeat binaries to a newer version.
  Only the packaged version is supported, in *tar.gz* archive format.

- **beat_config**: Default configuration file. This artifact can be used to overwrite the default configuration for FileBeat. In this case, to keep the automatic connection to ElasticSearch, a placeholder *#ELASTIC_SEARCH_OUTPUT_PLACEHOLDER#* should be present
  in the configuration file where the ElasticSearch output configuration should be inserted. Likewise, for automatic connection to Logstash,
  a placeholder *#LOGSTASH_OUTPUT_PLACEHOLDER#* should be present. The files property of the component is inserted under the
  *#FILES_PLACEHOLDER#* placeholder as a YAML list.

- **scripts**: Beats required scripts.

- **consul_scripts**: Scripts required by the Consul component.

- **utils_scripts**: Common util scripts for whole YSTIA components.


MetricBeat
----------

The following figure shows a MetricBeat topology example.

.. image:: docs/images/MetricBeat.png
   :name: TopBeat_figure
   :scale: 100
   :align: center

Properties
^^^^^^^^^^

- **component_version:** Version of the component.

- **period**: In seconds, defines how often to read server statistics.

  - Default: 10
- **debug**: Enable debug logs for this beat. Logs are located under ~/<Component_Name>/beat.log

  - Default: false


Requirements
^^^^^^^^^^^^

- **host**: MetricBeat component requires to be hosted on a Compute.

- **search_endpoint**: MetricBeat component may be connected to ElasticSearch.

- **logstash_endpoint**: MetricBeat component may be connected to Logstash.

****

**Notes**
  MetricBeat component should be connected to at least one of ElasticSearch or Logstash.
  If MetricBeat component is connected to ElasticSearch, it should also be connected to Consul in order to discover the ElasticSearch cluster. Exception: if TopBeat is on the same compute than ElasticSearch, Consul is not mandatory.

****

Artifacts
^^^^^^^^^

- **beat_bin**: Binary distribution of TopBeat. This artifact can be used to update TopBeat binaries to a newer version.
  Only the packaged version is supported, in *tar.gz* archive format.

- **beat_config**: Default configuration file. This artifact can be used to overwrite the default configuration for TopBeat. In this case, to keep the automatic connection to ElasticSearch, a placeholder *#ELASTIC_SEARCH_OUTPUT_PLACEHOLDER#* should be present
  in the configuration file where the ElasticSearch output configuration should be inserted. Likewise, for automatic connection to Logstash
  a placeholder *#LOGSTASH_OUTPUT_PLACEHOLDER#* should be present.

- **scripts**: Beats required scripts.

- **consul_scripts**: Scripts required by the Consul component.

- **utils_scripts**: Common util scripts for whole YSTIA components.

PacketBeat
----------

The following figure shows a PacketBeat topology example.

.. image:: docs/images/PacketBeat.png
   :name: PacketBeat_figure
   :scale: 100
   :align: center

Properties
^^^^^^^^^^

- **component_version:** Version of the component.

- **device**: Select the network interfaces to sniff the data. You can use the 'any' keyword to sniff on all connected interfaces.

  - Default: any
- **debug**: Enable debug logs for this beat. Logs are located under ~/<Component_Name>/beat.log

  - Default: false


Requirements
^^^^^^^^^^^^

- **host**: PacketBeat component requires to be hosted on a Compute.

- **search_endpoint**: PacketBeat component may be connected to ElasticSearch.

- **logstash_endpoint**: PacketBeat component may be connected to Logstash.

****

**Notes**
  PacketBeat component should be connected to at least one of ElasticSearch or Logstash.
  If PacketBeat component is connected to ElasticSearch, it should also be connected to Consul in order to discover the ElasticSearch cluster. Exception: if PacketBeat is on the same compute than ElasticSearch, Consul is not mandatory.

****

Artifacts
^^^^^^^^^

- **beat_bin**: Binary distribution of PacketBeat. This artifact can be used to update PacketBeat binaries to a newer version.
  Only the packaged version is supported, in *tar.gz* archive format.

- **beat_config**: Default configuration file. This artifact can be used to overwrite the default configuration for PacketBeat. In this case, to keep the automatic connection to ElasticSearch, a placeholder *#ELASTIC_SEARCH_OUTPUT_PLACEHOLDER#* should be present
  in the configuration file where the ElasticSearch output configuration should be inserted. Likewise, for automatic connection to Logstash,
  a placeholder *#LOGSTASH_OUTPUT_PLACEHOLDER#* should be present.

- **scripts**: Beats required scripts.

- **component_version:** Version of the component.

- **consul_scripts**: Scripts required by the Consul component.

- **utils_scripts**: Common util scripts for whole YSTIA components.




























A Kafka broker is represented by a Kafka node hosted on a Java node, which is hosted itself by a Compute node. A Kafka node requires to be related to a Consul agent
hosted on its Compute node as shown in the following figure. On top of this stack you can deploy as many different kafka topics as you need.
Each topic has its own configuration.

.. image:: docs/images/kafka.png
    :scale: 80
    :align: center

Properties
^^^^^^^^^^

- **component_version:** Version of the component.

- **scala_version:** Version of Scala used to build Kafka.

- **repository** : Download repository for this component artifacts. Providing a different value allows to specify an alternative repository.
  It is your responsibility to provide an accessible download url and to store required artifacts on it. You should specify only the base
  repository url. Artifacts names will be appended to it, so this property could be shared among several components using the inputs
  feature.

  - Default : "http://mirrors.standaloneinstaller.com/apache/"
- **kf_heap_size**: Heap memory size allocated to Kafka java process. The same value is allocated to both initial and maximum values (ie -Xms and -Xmx java options).

  - Default: 1G
- **zk_heap_size**: Heap memory size allocated to Zookeeper java process. The same value is allocated to both initial and maximum values (ie -Xms and -Xmx java options).

  - Default : 500M
- **log_cleaner_enable**: Enable the default Kafka log cleaner. The default policy for the cleaner is to delete the log segments older than 7 days.

  - Default : false


Requirements
^^^^^^^^^^^^

- **host**: Kafka should be hosted on a Java component. Java 7 or greater is required.
- **consul**: Kafka component requires to be connected to a local Consul Agent. This is required to perform cluster
  discovery.
- **filesystem_endpoint**: Kafka may be connected to a filesystem in order to store its runtime data on it. A typical use case would be
  to link this filesystem to a block storage in order to achieve data resilience and recovery.


Capabilities
^^^^^^^^^^^^

- **host**: Kafka can host KafkaTopic components.


Artifacts
^^^^^^^^^

- **scripts**:  Kafka required scripts.

- **consul_scripts**: Scripts required by the Consul component.

- **utils_scripts**: Common util scripts for whole Ystia components.


KafkaTopic
-----------
A KafkaTopic should be hosted on a Kafka component.
You can specify per-topic configuration as shown in the following figure.

.. image:: docs/images/kafka_topic.png
    :scale: 80
    :align: center

Properties
^^^^^^^^^^

- **topic_name**: Topic name (this value should match the following pattern: [-_A-Za-z0-9]+).

- **partitions**: Number of partitions for this topic.

  - Default : 1
- **replicas** : Number of replicas for this topic. Should be at most the number of hosting Kafka Component instances.

  - Default : 1
- **min_in_sync_replicas** : When a producer sets **request_required_acks** to **in_syncs**, min_insync_replicas specifies the minimum
  number of replicas that must acknowledge a write, for the write to be considered successful. If this minimum cannot be met, then the
  producer will raise an exception (either NotEnoughReplicas or NotEnoughReplicasAfterAppend). When used together, **min_insync_replicas**
  and **request_required_acks** allow you to enforce greater durability guarantees.

  A typical scenario would be to create a topic with a *replication factor* of **3**, set **min_insync_replicas** to **2**, and produce with
  **request_required_acks** of **in_syncs**. This will ensure that the producer raises an exception if a majority of replicas do not receive a
  write.

  - Default : 1
- **retention_minutes**: Number of minutes to keep a log file before deleting it.

  - Default: 10080 (7 days)
- **segment_minutes**: Number of minutes after which Kafka will force the log to roll
  even if the segment file is not full, to ensure that retention can delete or compact old data.

  - Default: 10080 (7 days)
- **segment_bytes**: Segment file size for the log.

  - Default: 1073741824 (1GB


Requirements
^^^^^^^^^^^^

- **kafka_host**: Kafka topics are hosted on Kafka components.


Artifacts
^^^^^^^^^

- **scripts**:  Kafka topic required scripts.

- **utils_scripts**: Common util scripts for whole Ystia components.


Kafka Relationships
-------------------

Any Kafka node is related to a Consul agent hosted on the same Compute node. This relationship is obtained by binding the **consul**
prerequisite of the Kafka node to the **agent** capability of the Consul node.

When used in the Elastic Stack architecture, Kafka topics are connected with a Logstash that publishes messages and another
Logstash that consumes those messages.

For the publishing part
^^^^^^^^^^^^^^^^^^^^^^^
#. Select the **Logstash Shipper** node.
#. In the **prerequisites** section, add a relationship for the **kafka_output** requirement and bind it to the **kafka_topic** capability
   of the Kafka Topic node.
#. In the **ConnectsLogstashToKafka** relationship you can specify the following configuration parameters:

- **request_required_acks**:
  This value controls when a produce request is considered completed. Specifically, how many other brokers must have committed the data
  to their log and acknowledged this to the leader. Typical values are:

  **no_ack**:
    Means that the producer never waits for an acknowledgement from the broker. This option provides the lowest latency but the
    weakest durability guarantees (some data may be lost when a server fails).

  **leader**:
    Means that the producer gets an acknowledgement after the leader replica has received the data. This option provides better
    durability as the client waits until the server acknowledges the request as successful (only messages that were written to the now-dead
    leader but not yet replicated will be lost).

  **in_syncs**:
    The producer gets an acknowledgement after all in-sync replicas have received the data. This option provides the greatest level of
    durability. However, it does not completely eliminate the risk of message loss because the number of in sync replicas may, in rare
    cases, shrink to 1. If you want to ensure that some minimum number of replicas (typically a majority) receive a write, then you must
    set the topic-level min_insync_replicas setting.

  - Default: no_ack

- **message_send_max_retries**:
  This property will cause the producer to automatically retry a failed send request. This property specifies the number of retries when
  such failures occur. Note that setting a non-zero value here can lead to duplicates, in the case of network errors that cause a message to
  be sent but the acknowledgement to be lost.

  - Default: 3
- **retry_backoff_ms**:
  Before each retry, the producer refreshes the metadata of relevant topics to see if a new leader has been elected. Since leader election
  takes a bit of time, this property specifies the amount of time that the producer waits before refreshing the metadata.

  - Default: 100
- **request_timeout_ms**:
  The amount of time the broker will wait trying to meet the request_required_acks requirement before sending back an error to the client.

  - Default: 10000


For the consumer part
^^^^^^^^^^^^^^^^^^^^^
#. Select the **Logstash Indexer** node.
#. In the **prerequisites** section, add a relationship for the **kafka_input** requirement and bind it to the **kafka_topic** capability
   of the Kafka Topic node.

Kafka Clustering
----------------

This section describes the recommendations to enable Kafka clustering. Then, Logstash will automatically publish and read logs to the
appropriate topic partitions.

Ystia offers an easy way to setup a Kafka cluster of several brokers. You just have to set the compute node hosting Kafka
scalable and to defining the scalability properties (min_instances, max_instances and default_instances).

However the Kafka clustering mode has a limitation. A Kafka cluster should be static at runtime. This means that you cannot modify the
number of deployed Kafka instances after the initial deployment.
This is due to the **ZooKeeper** component on which Kafka relies to store its configuration and which is deployed along with Kafka
instances. ZooKeeper in its stable release does not support dynamicity.
So we recommend setting scaling parameters as follows:

   **min_instances = max_instances = initial_instances**

Due to ZooKeeper limitations we recommend to have 3 or 5 instances in a clustering mode. 3 instances is the minimum to ensure fault
tolerance (this ensemble will tolerate the failure of one node at a time). More than 5 instances will start to have a moderate impact on
ZooKeeper performances.
Anyway you should have an odd number of instances as ZooKeeper works based on a simple majority voting for the leader election.

Advanced Kafka Configuration
----------------------------

Kafka exposes various configuration parameters, to tune Kafka precisely to your needs.
However, this tuning is always a tradeoff between the lowest latency and the greatest level of durability.

YSTIA ships different topology templates that are designed to address different applications. Kafka is used in two of those
templates:

- **ELK-broker**:
  In this template, Kafka is configured to be used with the lowest latency.

- **ELK-HA**:
  In this template, Kafka is configured to be used with the greatest level of durability.



