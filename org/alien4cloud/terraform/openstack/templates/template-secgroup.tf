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


# ### Security Groups ##########################

resource "openstack_networking_secgroup_v2" "a4c_external" {
  name = "sg_a4c_external"
  description = "A4C Exernal Secgroup"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "a4c_rabbitmq_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5672
  port_range_max    = 5672
  remote_ip_prefix  = "10.10.21.0/25"
  security_group_id = "${openstack_networking_secgroup_v2.a4c_external.id}"
}

resource "openstack_networking_secgroup_rule_v2" "a4c_kafka_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9092
  port_range_max    = 9092
  remote_ip_prefix  = "10.10.21.0/25"
  security_group_id = "${openstack_networking_secgroup_v2.a4c_external.id}"
}

resource "openstack_networking_secgroup_v2" "a4c_internal" {
  name = "sg_a4c_internal"
  description = "A4C Internal Secgroup"
  delete_default_rules = false
}

resource "openstack_networking_secgroup_rule_v2" "a4c_zoo_leader" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2888
  port_range_max    = 2888
  remote_group_id   = "${openstack_networking_secgroup_v2.a4c_internal.id}"
  security_group_id = "${openstack_networking_secgroup_v2.a4c_internal.id}"
}

resource "openstack_networking_secgroup_rule_v2" "a4c_zoo_election" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3888
  port_range_max    = 3888
  remote_group_id   = "${openstack_networking_secgroup_v2.a4c_internal.id}"
  security_group_id = "${openstack_networking_secgroup_v2.a4c_internal.id}"
}

resource "openstack_networking_secgroup_rule_v2" "a4c_zoo_service" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2181
  port_range_max    = 2181
  remote_group_id   = "${openstack_networking_secgroup_v2.a4c_internal.id}"
  security_group_id = "${openstack_networking_secgroup_v2.a4c_internal.id}"
}

resource "openstack_networking_secgroup_rule_v2" "a4c_kfk_service" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9092
  port_range_max    = 9092
  remote_group_id   = "${openstack_networking_secgroup_v2.a4c_internal.id}"
  security_group_id = "${openstack_networking_secgroup_v2.a4c_internal.id}"
}

output "_TF_SG_a4c_external" {
  value = "${openstack_networking_secgroup_v2.a4c_external.id}"
}

output "_TF_SG_a4c_internal" {
  value = "${openstack_networking_secgroup_v2.a4c_internal.id}"
}