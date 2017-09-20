# csar-public-library
A public TOSCA Cloud Service ARchive (csar) library of Types and Topologies.

## Rules

Here are the rules concerning csars naming nomenclature and version management.

### All components of the same branch or tag of this repository must share the same TOSCA DSL version.

### All components of the same branch or tag of this repository must share the same Normative Types version.

### Include in comments where to find dependency repositories (if different from this one).

### Type naming nomenclature.

The pattern is:

```
DOMAIN_NAME.PRODUCT_DOMAIN.TYPE[.PLATFORM][.ARTIFACT_IMPLEM].NAME
```

with

```
TYPE=nodes|relationships|capabilities|artifacts|datatypes
```

And with:

- package name in lower case
- NAME in upper camel case

For example:

- org.ystia.java.nodes.JDK
- org.ystia.java.relationships.JavaSoftwareHostedOnJDK
- org.ystia.java.nodes.linux.bash.JDK

When it's need, the major version of a software component can be added to it's name (for example when your type can not manager several versions):

- org.ystia.java.nodes.JDK7

### Folder naming nomenclature

The CSAR content must be placed in a folder that respect the archive name path.

For example the `org.ystia.java` archive content should be found in `org/ystia/java` folder.

### File naming convention

The base TOSCA file should be named `types.yml` to facilitate massive operations on CSARs. This file must be placed at the root of the CSAR folder.

### Type properties are named using snake case.

Example:

- java_home
- component_version

### The tosca.nodes.Root component_version property must be used to specify software version.

Example:

- For JDK version 7u51

```
component_version:
  type: version
  default: 7.0.51
  constraints:
    - valid_values: [ "7.0.51" ]
```

### Public packages

We encourage usage of public package to facilitate reusability and avoid strong coupling of components: when a component offers public capabilities and/or can be exposed as an A4C service, all these public types should be packaged in a public archive.

A public archive is by convention named 'pub' and should only contain capabilities and abstract node or relationship types. They should never embed implementations. A pub package should not import a non-pub package.

For example, the `org.alien4cloud.apache.pub` archive describe an abstract node type for apache and it's capabilities. `org.alien4cloud.apache.linux`_ans and `org.alien4cloud.apache.linux_sh` are two different implementations that inherit from the same abstract type and expose the same public capabilities. They both can be exposed as service and so be matched as their common abstract type.
