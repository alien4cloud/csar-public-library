# ### Variables ######################################

variable "OPENSTACK_CONFIG" {
  type = "map"
  default = {
    user_name = ""
    tenant_name = ""
    password = ""
    auth_url = ""
    region = ""
  }
}
variable "IMAGE_ID" {} 
variable "FLAVOR_ID" {} 
variable "KEY_NAME" {} 
variable "OPENSTACK_PREFIX" {} 
variable "EXTERNAL_NETWORK_NAME" {}
variable "EXTERNAL_SECGROUP_IDS" {
  type = "list"
  default = []
}
variable "FLOATING_IP" {} 
variable "INTERNAL_NETWORK_NAME" {}
variable "INTERNAL_SECGROUP_IDS" {
  type = "list"
  default = []
} 
variable "METADATA" {
  type = "map"
  default = {}
} 


# ### Key Map ######################################

variable user_name {
  default = "user_name"
}
variable tenant_name {
  default = "tenant_name"
}
variable password {
  default = "password"
}
variable auth_url {
  default = "auth_url"
}
variable region {
  default = "region"
}

resource "random_string" "name" {
  length = 8
  special = false
}


# ### Openstack Credentials ##########################
provider "openstack" {
  user_name = "${lookup(var.OPENSTACK_CONFIG, var.user_name)}"
  tenant_name = "${lookup(var.OPENSTACK_CONFIG, var.tenant_name)}"
  password = "${lookup(var.OPENSTACK_CONFIG, var.password)}"
  auth_url = "${lookup(var.OPENSTACK_CONFIG, var.auth_url)}"
  region = "${lookup(var.OPENSTACK_CONFIG, var.region)}"
}

data "openstack_networking_network_v2" "a4c_intranet" {
  name = "${var.INTERNAL_NETWORK_NAME}"
}

data "openstack_networking_network_v2" "a4c_internet" {
  name = "${var.EXTERNAL_NETWORK_NAME}"
}

resource "openstack_networking_port_v2" "a4c_intranet_port" {
  name           = "${var.OPENSTACK_PREFIX}_${random_string.name.result}_intranet"
  network_id     = "${data.openstack_networking_network_v2.a4c_intranet.id}"
  admin_state_up = "true"
  security_group_ids = "${var.INTERNAL_SECGROUP_IDS}"
}

resource "openstack_networking_port_v2" "a4c_internet_port" {
  name           = "${var.OPENSTACK_PREFIX}_${random_string.name.result}_internet"
  network_id     = "${data.openstack_networking_network_v2.a4c_internet.id}"
  admin_state_up = "true"
  security_group_ids = "${concat(var.EXTERNAL_SECGROUP_IDS)}"
}

resource "openstack_compute_instance_v2" "a4c_compute" {
  name      = "${var.OPENSTACK_PREFIX}_${random_string.name.result}"
  image_id  = "${var.IMAGE_ID}"
  flavor_id = "${var.FLAVOR_ID}"
  key_pair  = "${var.KEY_NAME}"

  metadata = "${var.METADATA}"

  network {
    port = "${openstack_networking_port_v2.a4c_internet_port.id}"
  }

  network {
    port = "${openstack_networking_port_v2.a4c_intranet_port.id}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "a4c_floating_ip" {
  floating_ip = "${var.FLOATING_IP}"
  instance_id = "${openstack_compute_instance_v2.a4c_compute.id}"
  fixed_ip    = "${openstack_compute_instance_v2.a4c_compute.network.0.fixed_ip_v4}"
}

output "PUBLIC_IP_ADDRESS" {
  value = "${var.FLOATING_IP}"
}

output "IP_ADDRESS" {
  value = "${openstack_compute_instance_v2.a4c_compute.network.0.fixed_ip_v4}"
}

output "INSTANCE_ID" {
  value = "${openstack_compute_instance_v2.a4c_compute.id}"
}

output "INSTANCE_NAME" {
  value = "${openstack_compute_instance_v2.a4c_compute.name}"
}