# Kubernetes Cluster Types


Simple TOSCA components to deploy the latest Kubernetes Cluster (v1.8.1)

## Kubernetes WebUI
The webui is accessible to the port 3000, for instance: `https://kubemaster_public_ip:30000`

**At the moment, you can just skip de login page**

## Cloudify manager

### Install kubectl
On Cloudify's manager, install the `kubectl`

	# To download a specific version (1.8.0)
	curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl

	# To download the latest version
	curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

	chmod +x ./kubectl
	sudo mv ./kubectl /usr/local/bin/kubectl

### Retrieve the kubernetes admin.conf file

Retrieve `/etc/kubernetes/admin.conf` from the kubernetes master machine and copy it on the Cloudify's Manager


### An example of how to query the manager

Use the `admin.conf` file to query kubernetes cluster from the Cloudify's manager machine.

	kubectl --kubeconfig /some_path/admin.conf get nodes 

## Misc

Tested on aws, computes matched with :
- ami-0f80e87c
- t2.medium
