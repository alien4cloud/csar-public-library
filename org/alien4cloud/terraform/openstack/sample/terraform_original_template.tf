provider "openstack" {
}
variable "floatingip_intranet" {
  type = "list"
  default = [
    "10.10.1.12",
    "10.10.1.13",
    "10.10.1.14"
  ]
}
data "openstack_networking_network_v2" "intranet" {
  name = "OPS-EU-INFRA-private-net"
}

data "openstack_networking_network_v2" "internet" {
  name = "OPS-EU-INFRA-internet-net"
}

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

resource "openstack_networking_secgroup_rule_v2" "a4c_kfk_service_floating" {
  count = 3
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9092
  port_range_max    = 9092
  remote_ip_prefix  = "${var.floatingip_intranet[count.index]}/32"
  security_group_id = "${openstack_networking_secgroup_v2.a4c_internal.id}"
}

resource "openstack_networking_port_v2" "intranet_port" {
  count          = 3
  name           = "alien_${count.index + 1}_intranet"
  network_id     = "${data.openstack_networking_network_v2.intranet.id}"
  admin_state_up = "true"
  security_group_ids = [
    "3e855338-925f-4f40-a31d-620b402a8687",
    "${openstack_networking_secgroup_v2.a4c_internal.id}",
    "${openstack_networking_secgroup_v2.a4c_external.id}"
  ]
}

resource "openstack_networking_port_v2" "internet_port" {
  count          = 3
  name           = "alien_${count.index + 1}_internet"
  network_id     = "${data.openstack_networking_network_v2.internet.id}"
  admin_state_up = "true"
  security_group_ids = [
    "3e855338-925f-4f40-a31d-620b402a8687",
    "${openstack_networking_secgroup_v2.a4c_internal.id}"
  ]
}

resource "openstack_compute_instance_v2" "a4c_compute" {
  count     = 3
  name      = "alien_${count.index + 1}"
  image_id  = "4b100898-b12e-42b7-aa9d-a78798411258"
  flavor_id = "1dabe14f-2c0f-4d2b-b0d0-4e1bf9badd67"
  key_pair  = "key_pair_name"

  metadata {
    env = "DEV"
    code = "CPT"
  }

  network {
    port = "${openstack_networking_port_v2.intranet_port.*.id[count.index]}"
  }

  network {
    port = "${openstack_networking_port_v2.internet_port.*.id[count.index]}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "intranet" {
  count = 3
  floating_ip = "${var.floatingip_intranet[count.index]}"
  instance_id = "${openstack_compute_instance_v2.a4c_compute.*.id[count.index]}"
  fixed_ip    = "${openstack_compute_instance_v2.a4c_compute.*.network.0.fixed_ip_v4[count.index]}"
}
