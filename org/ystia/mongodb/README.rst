.. _mongodb_section:

*******
MongoDB
*******

.. contents::
    :local:
    :depth: 3

MongoDB is a NOSQL database oriented document.
https://www.mongodb.com/

MongoDB Component
-----------------

A MongoDB node is hosted on a Compute node.

The following figure shows a MongoDB node configuration:

.. image:: docs/images/mongodb_component.png
    :name: mongodb_component_figure
    :scale: 100
    :align: center


Properties
^^^^^^^^^^

- **component_version**: Version of the component.
  - Default: 3.6
- **download_url**: If you need a specific MongoDB version, URL from which it can be downloaded.

Capabilities
^^^^^^^^^^^^


Requirements
^^^^^^^^^^^^

- **host**: MongoDB component requires to be hosted on a Compute

Artifacts
^^^^^^^^^

- **scripts**: MongoDB required scripts.

- **utils_scripts**: Common util scripts for whole Ystia components.

