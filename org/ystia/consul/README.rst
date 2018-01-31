.. _consul_section:

.. contents::
    :local:
    :depth: 2

Consul
------

**Consul** is a technical component allowing other software components to discover each other in a flexible,
highly available and fault tolerant way.

The same **Consul** component is used for two different purposes: it can run as a **Consul Server** or as a **Consul Agent**.
**Consul Servers** are responsible for storing and replicating data between themselves, while **Consul Agents** are responsible for
registering functional services, store services distributed configuration, performing health checks on nodes hosting those services and
serving service discovery requests through their DNS interface.

The type (Server or Agent) of a **Consul** component is determined by the relationships that link it to other **Consul** nodes:

- Without any relationship, it is a **Consul Server**.

- If a Consul node is target of one or several 'ConnectsConsulAgentToServer' relationship, then it is a **Consul Server**.

- If a Consul node is source of a 'ConnectsConsulAgentToServer' relationship, then it is a **Consul Agent**.

The following figure shows the relationships between Consul Agents and Servers.

.. image:: docs/images/consul_component_agent_server.png
    :scale: 100
    :align: center

**Consul** requires a quorum of at least (N/2 + 1) servers to be up to serve requests, so the recommended number of servers nodes is 3 or 5
allowing respectively the failure of 1 or 2 nodes simultaneously.


Properties
^^^^^^^^^^

- **component_version**: Version of the component

- **install_dnsmasq**: If dnsmasq is installed any .ystia DNS queries on local machine will be forwarded to Consul.
  Otherwise the Consul DNS interface is listening on port 8600. This feature must be enabled on **Consul Agents**.

  - Default: true
- **installation_directory**: Allows you to choose where to install **Consul** binaries

  - Default: ~/consul

Capabilities
^^^^^^^^^^^^

- **server**: Allows **Consul agents** to connect to this Consul instance as a **Consul server**

- **agent**: Allows other components to require a **Consul agent** to operate

Requirements
^^^^^^^^^^^^

- **host**: Consul component has to be hosted on a Compute.

- **server_endpoint**: Optional prerequisite that allows to connect a **Consul agent** to a **Consul server**

Artifacts
^^^^^^^^^

- **scripts**: Consul required scripts.

- **utils_scripts**: Common util scripts for whole Ystia components.