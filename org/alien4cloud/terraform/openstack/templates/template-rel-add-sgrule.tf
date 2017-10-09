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

variable "FLOATING_IP" {}


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


# ### Openstack Credentials ##########################
provider "openstack" {
  user_name = "${lookup(var.OPENSTACK_CONFIG, var.user_name)}"
  tenant_name = "${lookup(var.OPENSTACK_CONFIG, var.tenant_name)}"
  password = "${lookup(var.OPENSTACK_CONFIG, var.password)}"
  auth_url = "${lookup(var.OPENSTACK_CONFIG, var.auth_url)}"
  region = "${lookup(var.OPENSTACK_CONFIG, var.region)}"
}

# ### Security Group Rule ##########################

data "openstack_networking_secgroup_v2" "a4c_internal" {
  name = "sg_a4c_internal"
}

resource "openstack_networking_secgroup_rule_v2" "a4c_kfk_service_floating" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9092
  port_range_max    = 9092
  remote_ip_prefix  = "${var.FLOATING_IP}/32"
  security_group_id = "${data.openstack_networking_secgroup_v2.a4c_internal.id}"
}
