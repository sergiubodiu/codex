
variable "network"        { default = "10.4" }      # First 2 octets of your /16

variable "tenant_name"    { default = "codex"}
variable "user_name"      { default = "admin"}
variable "password"       { default = "supersecret"}
variable "auth_url"       { default = ""}


provider "openstack" {
    user_name  = "${var.user_name}"
    tenant_name = "${var.tenant_name}"
    password  = "${var.password}"
    auth_url  = "${var.auth_url}"
}

######################################
#         Security Groups
#####################################

resource "openstack_compute_secgroup_v2" "dmz" {
  name = "dmz"
  description = "Allow services from the private subnet through NAT"
  # ICMP traffic control
  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "0.0.0.0/0"
  }
  
  # Allow SSH traffic into the NAT box
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  
  # Allow all traffic through the NAT from inside the VPC
  rule {
    from_port = 0
    to_port = 0
    ip_protocol = "-1"
    cidr = "${var.network}.0.0/16"
  }

  # Allow outbound TCP traffic 
  rule {
    from_port = 0
    to_port = 65535
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  # Allow outbound UDP traffic 
  rule {
    from_port = 0
    to_port = 65535
    ip_protocol = "udp"
    cidr = "0.0.0.0/0"
  }
}


resource "openstack_compute_secgroup_v2" "wide-open" {
  name = "wide-open"
  description = "Allow everything in and out"
  # ICMP traffic control
  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "0.0.0.0/0"
  }
}


resource "openstack_compute_secgroup_v2" "cf-db" {
  name = "cf-db"
  description = "Allow access to the MySQL port"
  rule {
    from_port = 3306
    to_port = 3306
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}


resource "openstack_compute_secgroup_v2" "openvpn" {
  name = "openvpn"
  description = "Allow everything in and out"
  # ICMP traffic control
  rule {
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

################################
#          Networks TODO: Finish these
###############################

resource "openstack_networking_network_v2" "internal" {
  name = "internal"  
}

resource "openstack_networking_network_v2" "external" {
  name = "external"  
}

###############################
#           Subnets
###############################

resource "openstack_networking_subnet_v2" "dmz" {
  name = "dmz"
  network_id = "${openstack_networking_network_v2.external.id}"
  cidr = "${var.network}.0.0/24"
}

output "openstack_networking_network_v2.external.dmz.subnet" {
  value = "${openstack_networking_subnet_v2.dmz.id}"
}

######### Global ############

resource "openstack_networking_subnet_v2" "global-infra-0" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.1.0/24"
}

output "openstack_networking_network_v2.external.global-infra-0.subnet" {
  value = "${openstack_networking_subnet_v2.global-infra-0.id}"
}

resource "openstack_networking_subnet_v2" "global-infra-1" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.2.0/24"
}

output "openstack_networking_network_v2.external.global-infra-1.subnet" {
  value = "${openstack_networking_subnet_v2.global-infra-1.id}"
}

resource "openstack_networking_subnet_v2" "global-infra-2" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.3.0/24"
}

output "openstack_networking_network_v2.external.global-infra-2.subnet" {
  value = "${openstack_networking_subnet_v2.global-infra-2.id}"
}

resource "openstack_networking_subnet_v2" "global-openvpn-0" {
  network_id = "${openstack_networking_network_v2.external.id}"
  cidr = "${var.network}.4.0/25"
}

output "openstack_networking_network_v2.external.global-openvpn-0.subnet" {
  value = "${openstack_networking_subnet_v2.global-openvpn-0.id}"
}

resource "openstack_networking_subnet_v2" "global-openvpn-1" {
  network_id = "${openstack_networking_network_v2.external.id}"
  cidr = "${var.network}.4.128/25"
}

output "openstack_networking_network_v2.external.global-openvpn-1.subnet" {
  value = "${openstack_networking_subnet_v2.global-openvpn-1.id}"
}

######## Development ##########


resource "openstack_networking_subnet_v2" "dev-infra-0" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.16.0/24"
}

output "openstack_networking_network_v2.external.dev-infra-0.subnet" {
  value = "${openstack_networking_subnet_v2.dev-infra-0.id}"
}

resource "openstack_networking_subnet_v2" "dev-infra-1" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.17.0/24"
}

output "openstack_networking_network_v2.external.dev-infra-1.subnet" {
  value = "${openstack_networking_subnet_v2.dev-infra-1.id}"
}

resource "openstack_networking_subnet_v2" "dev-infra-2" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.18.0/24"
}

output "openstack_networking_network_v2.external.dev-infra-2.subnet" {
  value = "${openstack_networking_subnet_v2.dev-infra-2.id}"
}


######## DEV-CF-EDGE ##########

resource "openstack_networking_subnet_v2" "dev-cf-edge-0" {
  network_id = "${openstack_networking_network_v2.external.id}"
  cidr = "${var.network}.19.0/25"
}

output "openstack_networking_network_v2.external.dev-cf-edge-0.subnet" {
  value = "${openstack_networking_subnet_v2.dev-cf-edge-0.id}"
}

resource "openstack_networking_subnet_v2" "dev-cf-edge-1" {
  network_id = "${openstack_networking_network_v2.external.id}"
  cidr = "${var.network}.19.128/25"
}

output "openstack_networking_network_v2.external.dev-cf-edge-1.subnet" {
  value = "${openstack_networking_subnet_v2.dev-cf-edge-1.id}"
}

######## DEC-CF-CORE #########

resource "openstack_networking_subnet_v2" "dev-cf-core-0" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.20.0/24"
}

output "openstack_networking_network_v2.external.dev-cf-core-0.subnet" {
  value = "${openstack_networking_subnet_v2.dev-cf-core-0.id}"
}

resource "openstack_networking_subnet_v2" "dev-cf-core-1" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.21.0/24"
}

output "openstack_networking_network_v2.external.dev-cf-core-1.subnet" {
  value = "${openstack_networking_subnet_v2.dev-cf-core-1.id}"
}

resource "openstack_networking_subnet_v2" "dev-cf-core-2" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.22.0/24"
}

output "openstack_networking_network_v2.external.dev-cf-core-2.subnet" {
  value = "${openstack_networking_subnet_v2.dev-cf-core-2.id}"
}


######## DEC-CF-CORE #########

resource "openstack_networking_subnet_v2" "dev-cf-runtime-0" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.23.0/24"
}

output "openstack_networking_network_v2.external.dev-cf-runtime-0.subnet" {
  value = "${openstack_networking_subnet_v2.dev-cf-runtime-0.id}"
}


resource "openstack_networking_subnet_v2" "dev-cf-runtime-1" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.24.0/24"
}

output "openstack_networking_network_v2.external.dev-cf-runtime-1.subnet" {
  value = "${openstack_networking_subnet_v2.dev-cf-runtime-1.id}"
}

resource "openstack_networking_subnet_v2" "dev-cf-runtime-2" {
  network_id = "${openstack_networking_network_v2.internal.id}"
  cidr = "${var.network}.25.0/24"
}

output "openstack_networking_network_v2.external.dev-cf-runtime-2.subnet" {
  value = "${openstack_networking_subnet_v2.dev-cf-runtime-2.id}"
}



###############################
#      Volumes and Instances
###############################

resource "openstack_blockstorage_volume_v2" "volume_bastion" {
  region = "RegionOne"
  name = "volume_bastion"
  description = "bastion Volume"
  size = 2
}


resource "openstack_compute_instance_v2" "bastion" {
  name = "bastion"
  image_name = "cirros-0.3.4-x86_64-uec"
  flavor_id = "3"
  key_pair = "codex"
  security_groups = ["default"]

  network {
    name = "my_network"
  }

  volume {
    volume_id = "${openstack_blockstorage_volume_v1.myvol.id}"
  }
}
