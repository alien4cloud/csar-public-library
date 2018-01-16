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
