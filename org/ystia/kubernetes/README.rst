.. _kubernetes_section:

**********
Kubernetes
**********

.. contents::
    :local:
    :depth: 3

Kubernetes
----------

**Kubernetes** is an ...

A complete documentation is available at https://kubernetes.io/docs.

Requirements
^^^^^^^^^^^^

This component is implemented using ansible playbooks.
It requires some extra python libraries to be installed on the ansible host. Those libraries are listed in the 
pip requirements format under org/ystia/kubernetes/linux/ansible/playbooks/requirements.txt (could be installed using ``pip install -r requirements.txt``).

Kubernetes Master Component Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A Kubernetes Master node install Docker + Kubernetes core components.
Then it bootstraps itself using the ``kubeadm init`` command.

The Kubernetes Master nodes hosts an internal Etcd component that is a consensus system which requires a quorum to operate.
That means that when defining the number of Kubernetes Masters you need to use a odd number (the recommended number of nodes is 3 to ensure resilience)

Kubernetes Worker nodes could join a Kubernetes cluster using the **api_server**  prerequisite.

Kubernetes Applications nodes can be attached to the Kubernetes master node using **app_host** prerequisite.

Properties
~~~~~~~~~~

- **component_version:** Version of the component.

- **kube_yum_repo**: The YUM repository to use to install Kubernetes component

  - Default : https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
  
- **kube_yum_repo_gpg_keys**: YUM repository gpg keys used to sign artifacts

  - Default: https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

- **pod_network:** Overlay network plugin to install on top of Kubernetes

  - Default: calico

- **cfssl_download_url:** Download base url for cfssl tools used to generate certificates

  - Default: https://pkg.cfssl.org/R1.2

- **ca_certificate:** allows to provide a root ca certificate. This certificate should allow to sign client and server certificate and should be provided 
  along with the corresponding private key. If not set a self-signed certificate will be generated.

- **ca_key:** allows to provide a root ca private key. It should be provided along with the corresponding certificate. 
   If not set a self-signed certificate will be generated.

- **hosts_pods:** define if a master node could host application pods

  - Default: false

Requirements
~~~~~~~~~~~~

- **host**: Kubernetes should be hosted on a Compute.


Capabilities
~~~~~~~~~~~~

- **app_host**: Kubernetes can be used as a **app_host** by Kubernetes Applications components.
  Several Application components can be connected to a Kubernetes component by using their **app_host** prerequisite.

- **api_server**: This capability controls how the Kubernetes API is exposed. Particulary the **port** property could be use to define the API port number.
  This capability is used by Kubernetes workers to connect to a Master node.

Attributes
~~~~~~~~~~

- **admin_token**: This token is used by Workers nodes to connect to a master node.

- **ca_cert_hash**: This hash is used by Workers nodes to connect to a master node.

- **pods_cidr**: The CIDR used by the network overlay. This is usefull for setting-up no-proxy Configuration

- **node_name**: Name of the node as known by the Kubernetes cluster

Kubernetes Worker Component Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A Kubernetes Worker node install Docker + Kubernetes core components.
Then it connects to a Kubernetes master using the ``kubeadm join`` command.

Properties
~~~~~~~~~~

- **component_version:** Version of the component.

- **kube_yum_repo**: The YUM repository to use to install Kubernetes component

  - Default : https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
  
- **kube_yum_repo_gpg_keys**: YUM repository gpg keys used to sign artifacts

  - Default: https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

Requirements
~~~~~~~~~~~~

- **host**: Kubernetes should be hosted on a Compute.

- **api_server**: Kubernetes worker should be connected to exactly one Kubernetes master node.

Capabilities
~~~~~~~~~~~~

- **app_host**: Kubernetes can be used as a **app_host** by Kubernetes Applications components.
  Several Application components can be connected to a Kubernetes component by using their **app_host** prerequisite.

- **api_server**: This capability controls how the Kubernetes API is exposed. Particulary the **port** property could be use to define the API port number.
  This capability is used by Kubernetes workers to connect to a Master node.

Attributes
~~~~~~~~~~

- **node_name**: Name of the node as known by the Kubernetes cluster

KubernetesApp
^^^^^^^^^^^^^

A KubernetesApp should be hosted on a Kubernetes master node and allows to deploy a set of configuration files using ``kubectl apply -f``.
This allows to deploy applications and configuration to a Kubernetes cluster.

Properties
~~~~~~~~~~

- **specs:** A list of URLs that will be applied in order using ``kubectl apply -f <url>``

Requirements
~~~~~~~~~~~~

- **app_host**: A KubernetesApp should be hosted on a Kubernetes Master node.


Kubernetes Dashboard
^^^^^^^^^^^^^^^^^^^^

A Kubernetes Dashboard is an extension of a KubernetesApp used to deploy and setup a Kubernetes Dashboard

Properties
~~~~~~~~~~

- **specs:** A list of URLs that will be applied in order using ``kubectl apply -f <url>``.
  This type contains a predefined list of specifications that could be altered.

- **service_type**: defines how the dashboard service should be exposed, supported values are: *default* that do not alter the service, *NodePort* that configures
  the service to be exposed as a NodePort and *LoadBalancer* that configures the service to be exposed by a load-balancer

- **expose_admin_token**: Controls if the user admin token should be exposed as an attribute of the Dashboard node

  - Default: false

Requirements
~~~~~~~~~~~~

- **app_host**: A KubernetesApp should be hosted on a Kubernetes Master node.

Attributes
~~~~~~~~~~

- **admin_token**: Admin token to use to connect to the dashboard

- **url**: The dashboard URL 
