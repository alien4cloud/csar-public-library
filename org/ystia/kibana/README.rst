.. _kibana_section:

******
Kibana
******

.. contents::
    :local:
    :depth: 3

Kibana
------

**Kibana** is an analytics and visualization platform that uses Elasticsearch to give you a better understanding of your data.
It is a part of the **Elastic Stack**, which includes **Elasticsearch**, **Logstash**, **Kibana** and **Beats**.

A complete documentation is available at https://www.elastic.co/guide/en/kibana/5.1/index.html.

In addition of default visualisations provided by Kibana , we support natively some plugins like:

- **Sankey**: those charts are ideal for displaying the material, energy and cost flows.
- **Heatmap**: this is a graphical representation of data where the individual values contained in a matrix are represented as colors.
- **Slider**: useful for filtering data by sliding one or more data fields values.
- **Network**: displays a network node that link two fields that have been selected.
- **Health Color Metric**: allows to change color/health of the visualization depending of a metric aggregation.
- **C3 charts**:  allows to represent on the same chart  up to 5 different metrics.
- **SwimLane**: displays the behavior of a metric value over time across a field using lanes.
- **Mathlion**: a Kibana extension that enables equation parsing and advanced math under Timelion.

Kibana Interface
^^^^^^^^^^^^^^^^

The Kibana interface includes four main sections:

- Discover
- Visualize
- Dashboard
- Timelion
- Dev Tools
- Management

These sections are reached by tabs on the top of the main interface.

**Kibana Discover**

The Discover page displays all of the Elastic Stack most recently received logs.
Here, you can filter through and find specific log messages based on **search queries** then narrow the search results to a specific time range with the **time filter**.

**Kibana Visualize**

The Visualize page is where you will create, modify, and view your own custom visualizations.

**Kibana Dashboard**

The Dashboard page is where you can create, modify, and view your own custom dashboards.
A dashboard allows you to combine multiple visualizations onto a single page.
Dashboards are useful to get an overview of your logs, and to make correlations among various visualizations and logs.
Dashboards can be refreshed automatically with a configurable period.
They can be filtered by entering a search query, changing the time filter, or by clicking elements on the visualization.

**Kibana Timelion**

Timelion is a time series data visualizer that enables you to combine totally independent data sources within a single visualization.

**Kibana Dev Tools**

The Dev Tools page is a UI Console to interact with the REST API of Elasticsearch.

**Kibana Management**

The Management page is where you perform your runtime configuration of Kibana.

Kibana Configuration
^^^^^^^^^^^^^^^^^^^^

A Kibana node must be hosted on a Java node, which is hosted on a Compute node. The minimum version of Java is **JRE 8**.
Kibana Dashboard nodes can be attached to the Kibana node using **dashboard_host** prerequisite.

A Kibana node requires to be related to an Elasticsearch node. Use the **search_endpoint** prerequisite to establish the relation with an already created Elasticsearch node.

A Kibana node is related to a Consul agent hosted on its Compute node. This is required to perform Elasticsearch cluster discovery.
Use **consul** prerequisite to connect Kibana to its Consul Agent, as shown in the following figure.

.. image:: docs/images/Kibana-Basic-Conf-With-Consul.png
   :name: kibana_consul_figure
   :scale: 100
   :align: center

Properties
^^^^^^^^^^

- **component_version:** Version of the component.

- **repository**: Download repository for this component artifacts. Providing a different value allows to specify an alternative repository.
  It is your responsibility to provide an accessible download url and to store required artifacts on it. You should specify only the base repository url.
  Artifacts names will be appended to it, so this property could be shared among several components using the inputs feature.

  - Default : https://www.elastic.co/downloads/kibana
  
- **es_heap_size**: Heap memory that will be allocated to the java process of the Elasticsearch client node associated to Kibana. It allocates the same value to both initial and maximum values (ie -Xms and -Xmx java options).

  - Default: 2G


Requirements
^^^^^^^^^^^^

- **host**: Kibana should be hosted on a Java component. Java 8 or greater is required.
- **consul**: Kibana component requires to be connected to a local Consul Agent. This is required to perform cluster
  discovery.
- **search_endpoint**: allows to connect a Kibana component to Elasticsearch


Capabilities
^^^^^^^^^^^^

- **host**: Kibana can be used as a **dashboard_host** by Dashboard components. The role of a **Dashboard** component is to carry a dashboard configuration (it has an artifact named **dashboard_file**). This configuration is described in a .JSON file. Several Dashboard components can be connected to a Kibana component by using their **dashboard_host** prerequisite.

Artifacts
^^^^^^^^^

- **scripts**:  Kibana required scripts.

- **consul_scripts**: Scripts required by the Consul component.

- **utils_scripts**: Common util scripts for whole Ystia components.

- **plugins**: Kibana plugins directory

Using Kibana
^^^^^^^^^^^^

Once the topology deployed, the URL allowing you to use Kibana is available in the **Deployment** view.

In the Topology view, click the **Output properties** icon near the **url** attribute:

.. image:: docs/images/Kibana-Node-url.png
   :name: kibana_url_figure
   :scale: 80
   :align: center

You can visualize data from Elasticsearch using deployed dashboards or created dashboards.

If you need to upload a particular JSON dashboard file to visualize data, use the **KibanaDashboard** component provided by the Elastic Stack,
and upload the JSON file into it using its **dashboard_file** artifact. Perform this operation before deploying the topology.

If you have already deployed the topology, you may test a JSON dashboard file by using the **Runtime** view of the Kibana node and using a custom operation named
**custom.updateDashboardOnKibana**. Set the **url** parameter to a path containing the JSON file to load.

Kibana Dashboards Format
^^^^^^^^^^^^^^^^^^^^^^^^

A Kibana dashboard JSON file may be obtained by an **Export Everything** operation available in the **Saved Objects** tab
of the **Management** menu of Kibana. The main object types to keep in the dashboard JSON file are *dashboard*, *visualization* and *search*.
