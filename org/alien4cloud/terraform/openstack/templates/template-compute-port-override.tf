# ### Variables ######################################

variable "NEW_EXT_SECGROUP_IDS" {
  type = "list"
  default = []
} 

variable "NEW_INT_SECGROUP_IDS" {
  type = "list"
  default = []
} 

resource "openstack_networking_port_v2" "a4c_intranet_port" {
  name           = "${var.OPENSTACK_PREFIX}_${random_string.name.result}_intranet"
  network_id     = "${data.openstack_networking_network_v2.a4c_intranet.id}"
  admin_state_up = "true"
  security_group_ids = "${concat(var.INTERNAL_SECGROUP_IDS, var.NEW_INT_SECGROUP_IDS, var.NEW_EXT_SECGROUP_IDS)}"
}

resource "openstack_networking_port_v2" "a4c_internet_port" {
  name           = "${var.OPENSTACK_PREFIX}_${random_string.name.result}_internet"
  network_id     = "${data.openstack_networking_network_v2.a4c_internet.id}"
  admin_state_up = "true"
  security_group_ids = "${concat(var.EXTERNAL_SECGROUP_IDS, var.NEW_INT_SECGROUP_IDS)}"
}