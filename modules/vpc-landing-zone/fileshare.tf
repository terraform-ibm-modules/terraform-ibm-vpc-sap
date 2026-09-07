#####################################################
# File share for NFS and Network Load Balancer
#####################################################

locals {
  vpc_zone                      = var.vpc_zone
  resource_group_id             = module.landing_zone.resource_group_data["${var.prefix}-slz-edge-rg"]
  file_share_name               = "${var.prefix}-file-share-nfs"
  file_share_size               = var.nfs_server_config.size
  file_share_iops               = var.nfs_server_config.iops
  file_share_mount_target_name  = "${var.prefix}-nfs"
  file_share_subnet_id          = [for subnet in module.landing_zone.subnet_data : subnet.id if subnet.name == "${var.prefix}-edge-vsi-edge-zone-${regex("[0-9]+$", var.vpc_zone)}"][0]
  file_share_security_group_ids = [for security_group in module.landing_zone.vpc_data[0].vpc_data.security_group : security_group.group_id if security_group.group_name == "network-services-sg"]
}

resource "ibm_is_share" "file_share_nfs" {
  provider = ibm.ibm-is
  count    = var.configure_nfs_server ? 1 : 0

  name                = local.file_share_name
  size                = local.file_share_size
  profile             = "dp2"
  access_control_mode = "security_group"
  iops                = local.file_share_iops
  zone                = local.vpc_zone
  resource_group      = local.resource_group_id
}

resource "ibm_is_share_mount_target" "mount_target_nfs" {
  provider = ibm.ibm-is
  count    = var.configure_nfs_server ? 1 : 0

  name  = local.file_share_mount_target_name
  share = ibm_is_share.file_share_nfs[0].id
  virtual_network_interface {
    name            = local.file_share_mount_target_name
    resource_group  = local.resource_group_id
    subnet          = local.file_share_subnet_id
    security_groups = local.file_share_security_group_ids
  }
}

locals {
  nfs_host_or_ip_path = var.configure_nfs_server ? ibm_is_share_mount_target.mount_target_nfs[0].mount_path : ""
}
