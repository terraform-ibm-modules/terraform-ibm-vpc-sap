##############################################################
# SAP VSI — creates one VPC instance and its block volumes.
# Designed to be called once per SAP role (HANA DB, APP, etc.)
##############################################################

data "ibm_is_image" "image" {
  provider = ibm.ibm-is
  name     = var.image
}

resource "ibm_is_volume" "volumes" {
  provider = ibm.ibm-is
  for_each = var.volume_map

  name           = each.key
  zone           = var.zone
  resource_group = var.resource_group_id
  capacity       = tonumber(each.value.size)
  profile        = each.value.iops
  tags           = var.tags
}

resource "ibm_is_instance" "vsi" {
  provider = ibm.ibm-is

  name           = var.name
  profile        = var.profile
  image          = data.ibm_is_image.image.id
  vpc            = var.vpc_id
  zone           = var.zone
  resource_group = var.resource_group_id
  keys           = [var.ssh_key_id]
  user_data      = var.user_data
  volumes        = [for v in ibm_is_volume.volumes : v.id]
  tags           = var.tags

  primary_network_interface {
    subnet          = var.subnet_id
    security_groups = [var.security_group_id]
  }
}
