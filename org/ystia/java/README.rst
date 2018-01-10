.. _java_section:

Java
----

Java is a technical component allowing other software components to choose the required Java version.

Some Ystia components need a Java component to run.

A Java node is hosted on a Compute node. The components that need Java are hosted on the Java node using a prerequisite named **host**,
with the capability **org.ystia.java.pub.capabilities.JavaHosting**.

****

**Note**
  In the topology templates provided with Ystia, the relationships between Compute, Java and
  Ystia Component hosted on Java are already configured.

****

Properties
^^^^^^^^^^

- **component_version**: Version. Available values may be 6, 7 or 8

  - Default: 8
- **jre**: Boolean allowing to specify that a JRE is sufficient.

  - Default: true
- **headless**: Boolean allowing to specify that headless mode is enough as the components are run on a server
  and do not need equipment such as display or keyboard.

  - Default: true
- **download_url**: If you need a specific Java version, URL from which it can be downloaded.

Capabilities
^^^^^^^^^^^^

- **java_host**: Java component requires to be hosted on a Compute.


Artifacts
^^^^^^^^^

- **scripts**: Java required scripts.

- **utils_scripts**: Common util scripts for whole Ystia components.

