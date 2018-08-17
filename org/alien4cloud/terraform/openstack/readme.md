# terraform-custom-types

Sample types to provision a Compute and a Security Group on Openstack using Terraform.

The idea is to wrap existing terraform template into a TOSCA node with the minimum efforts.

It doesn't means that it will be automatic and it may require some efforts to make the terraform scripts dynamic and scalable. 

# Prerequisite

Install terraform on Cloudify Manager.

	curl -LO https://releases.hashicorp.com/terraform/0.10.7/terraform_0.10.7_linux_amd64.zip
	unzip terraform_0.10.7_linux_amd64.zip
	chmod +x terraform
	sudo mv terraform /usr/bin


# Wrap Terraform template with a TOSCA Component

## How to wrap a Terraform template

The goal is to have a TOSCA node per terraform "resource unit".  
Concretely, what a resource unit is a group of terraform resources that can scale together without using the `count` function of terraform. 

**Thus You must split your terraform template into multiple templates in order to get ideally 1 kind of resources per templates.**

Also make sure that there is no static values inside the template. Every values that are dynamic must be put as variables.

## Creating the TOSCA node

The TOSCA component must have an artifact `ARTIFACT_TERRAFORM` that is the terraform template to deploy.

    artifacts:
      - ARTIFACT_TERRAFORM:
          file: templates/template-compute.tf
          type: tosca.artifacts.File
          description: Terraform file to provision a compute with a new floating

And it must implement our 3 generic scripts:

* scripts/prepare_terraform.sh  
* scripts/apply_terraform.sh
* scripts/destroy_terraform.sh

Here what it looks like in TOSCA: 

    interfaces:
      Standard:
        create:
          inputs:
            ...
          implementation: scripts/prepare_terraform.sh
        start:
          inputs:
            INPUT_FILE: { get_operation_output: [ SELF, Standard, create, INPUT_FILE ] }
          implementation: scripts/apply_terraform.sh
        delete:
          inputs:
            INPUT_FILE: { get_operation_output: [ SELF, Standard, create, INPUT_FILE ] }
          implementation: scripts/destroy_terraform.sh


### prepare_terraform.sh script

- Create a folder to store terraform files in `/opt/a4c_terraform/_instance_id_`
- Copy the terraform template from the artifact into the folder
- Translate TOSCA inputs into Terraform variables into a file `tf-inputs`
- Export the path of the generated inputs file

Properties to translate to Terraform should be prefixed with **\_TF\_** 

For example, if you write:
	
    create:
      inputs:
        _TF_IMAGE_ID: "image_id_value"
        _TF_FLAVOR_ID: "flavor_id_value"
      implementation: scripts/prepare_terraform.sh


The script will generate:

	IMAGE_ID  = "image_id_value"
	FLAVOR_ID = "flavor_id_value"


There is also a specific prefix **\_TFL\_** for a list of values.  
Each value of the list will be taken for an instance. This is usefull if you want to set specific values for each instance of a node i.e. if you want to use a list of existing floating ips for instance.

For example:

    create:
      inputs:
        _TFL_FLOATING_IP: 
		  - 192.168.0.10
		  - 192.168.0.11
		  - 192.168.0.12
      implementation: scripts/prepare_terraform.sh

will generate

	FLOATING_IP  = [ "192.168.0.10", "192.168.0.11", "192.168.0.12" ]


If you have configured your compute to create 3 instances, each instance of the compute will have the floating ips attached according to the list.  


### apply_terraform.sh script

- perform `terraform init` and `terraform apply` commands from `/opt/a4c_terraform/_instance_id_`
- save the output into a file named `tf-output`
- export terraform outputs back to alien4cloud

For instance, if you expect an operation:
	
    attributes:
      ip_address: { get_operation_output: [ SELF, Standard, start, IP_ADDRESS ] }


Your terraform template must have an output resource named `IP_ADDRESS`

	output "IP_ADDRESS" {
	  value = "${openstack_compute_instance_v2.a4c_compute.network.0.fixed_ip_v4}"
	}


**Tips**

As you can set environment variable `TF_LOG` to get more log from a terraform command, you can set it in the operation like the following

    interfaces:
      Standard:
        start:
          inputs:
            INPUT_FILE: { get_operation_output: [ SELF, Standard, create, INPUT_FILE ] }
            TF_LOG: { get_property: [ SELF, TF_LOG] }
            OS_DEBUG: { get_property: [ SELF, OS_DEBUG] }
          implementation: scripts/apply_terraform.sh

You can notice that we use the same trick with the `OS_DEBUG` variable to get more logs from the terraform openstack provider.

### destroy_terraform.sh script

- perform a `terraform destroy` command 
- delete the terraform folder on the manager in `/opt/a4c_terraform/_instance_id_`


## Make relationships

Now that you have 2 TOSCA nodes that can create 2 kinds of terraform resource, you will certainly have to somehow link them together. This is what TOSCA relationships are made for !

The `add_target` and `add_source` operations are very convenient for the task.

In our samples:

We have 2 node types `org.alien4cloud.nodes.terraform.openstack.cloudify.TerraInstance` and `org.alien4cloud.nodes.terraform.openstack.CustomSecurityGroup`

- `TerraInstance` creates a compute connected to 2 networks (internal and external) with a floating ip attached to the port linked to the internet network. It can also apply existing security groups on the 2 ports (internal and external). 
- `CustomSecurityGroup` creates 2 security groups with some specific rules in each.

So on one hand I have a compute and on the other hand a new secgroup. I would like to associate the secgroup with my compute. And also, I would like to add a new secgroup rule to allow ingress access to the public ip address of my compute.

In our sample, the `CustomSecurityGroup` depends on `TerraInstance`.
So `CustomSecurityGroup` is the **source** of the relationship and `TerraInstance` is the **target**.

So the `add_target` operation will add the new rule to the security group and the `add_source` operation will associate the security group to the compute.

### add_target

As we said above, the goal is to add a rule to allow the floating ip of each compute's instances that we want to associate with.

First, we created an artifact `ARTIFACT_REL_SG_TERRAFORM` for the `CustomSecurityGroup` node. This terraform template contains description to add a rule to the internal security group.
As an input of the script, we retrieve the public ip of the compute we want to associate, so at the end of the day the security group will contains a rule for the floating ip of each compute's intances.

Description of the add_target script `tf_rel_sg_add_target.sh`

- create a folder that will contains relationship template `/opt/a4c_terraform/rel-source_instance_id-target_instance_id`
- copy the `ARTIFACT_REL_SG_TERRAFORM` into the folder.
- perform `terraform init` and `terraform apply` commands

### add_source

The goal here is to associate the security group with the openstack ports.

The idea is to use the template override feature of terraform to do it.
Therefore, we have an additionnal artifact `ARTIFACT_PORT_OVERRIDE` which override the 2 ports definition in order to add the new security group ids.

Description of the add_source script `tf_rel_sg_add_source.sh`

- copy the override template into `/opt/a4c_terraform/_compute_instance_id_`
- retrieve the security group ids from `/opt/a4c_terraform/_secgroup_instance_id_`
- perform `terraform apply` commands to apply the changes to the current instance


# Feedbacks

## Pros

- Simplify the terraform templates: TOSCA component is responsible for a limited group of resources. 
- No need to use tricky statements for loops, if-else: TOSCA relationships can do the works.

## Cons

- Certainly need to adapt existing terraform templates into several TOSCA components to allow dynamicity and scalability.
- Building terraform types to provsion Common iaas resources (especially Computes) doesn't make much sense on our current solution as we already support it through Alien4Cloud/Cloudify.

# Next

- We saw that levering terraform to provision computes is not of great interest. On the other hand we can benifit from terraform templates to deal with what alien4cloud doesn't yet support as the creation of security groups.  
- Change how we configure the openstack credentials to make it more secure by using secret store for instance. 
