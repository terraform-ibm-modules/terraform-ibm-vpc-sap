
locals {
  #######################################################################
  # cloud-init user_data — written once, shared by the landing zone
  # override string (for jump-box / network-services VSIs) and by both
  # SAP VSIs (HANA DB and APP).  Mirrors the internal logic in
  # modules/vpc-landing-zone/main.tf so all VSIs get the same bootstrap.
  #######################################################################
  user_data = <<-EOT
    #cloud-config
    # vim: syntax=yaml
    write_files:
    - content: |
        ${var.ssh_public_key}
      path: /root/.ssh/authorized_keys
      permissions: '0600'
      owner: root:root
    runcmd:
    - sed -i 's/^PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
    - systemctl restart sshd
  EOT

  #######################################################################
  # Infrastructure IDs resolved directly from module.standard outputs.
  #
  # module.standard.vpc_data           — list of vpc objects, each with:
  #                                        .vpc_id       (string)
  #                                        .subnet_zone_list[*].{name, id}
  # module.standard.resource_group_data — map of { name => id }
  # module.standard.vsi_ssh_key_data    — list of ssh key objects with .id
  # module.standard.security_group_data — list of sg objects with .id, .name
  #######################################################################

  # The only VPC created by the preset is the "edge" VPC.
  # vpc_data_edge     — merged object from module.vpc (subnet_zone_list, vpc_id, …)
  # vpc_data_raw      — raw data.ibm_is_vpc object (security_group, id, …)
  vpc_data_edge = module.standard.vpc_data[0]
  vpc_data_raw  = local.vpc_data_edge.vpc_data

  vpc_id = local.vpc_data_edge.vpc_id

  # SAP VSIs go on the vsi-edge-<zone> subnet (public-gateway enabled).
  subnet_id = [
    for s in local.vpc_data_edge.subnet_zone_list :
    s.id if can(regex("vsi-edge-", s.name))
  ][0]

  # SAP VSIs use the network-services-sg security group.
  # data.ibm_is_vpc.security_group is a list of { group_id, group_name, rules }.
  security_group_id = [
    for sg in local.vpc_data_raw.security_group :
    sg.group_id if can(regex("network-services-sg", sg.group_name))
  ][0]

  # resource_group_data is a map: { "<prefixed-name>" => "<id>" }
  # The preset creates slz-edge-rg with use_prefix=true, so the key is "{prefix}-slz-edge-rg".
  resource_group_id = module.standard.resource_group_data["${var.prefix}-slz-edge-rg"]

  # Single SSH key provisioned by the landing zone.
  ssh_key_id = module.standard.vsi_ssh_key_data[0].id

  #######################################################################
  # HANA DB volume sizing — derived from profile name.
  # Profile format: <family>-<vcpus>x<memory_GB>  e.g. "mx2-16x128"
  #######################################################################
  hana_memory_gb = tonumber(regex("x([0-9]+)$", var.vsi_hana_db_profile)[0])

  # /hana/data  = 1× RAM rounded up to the nearest 100 GB
  hana_data_gb = ceil(local.hana_memory_gb / 100) * 100
  # /hana/log   = fixed 512 GB (SAP minimum)
  hana_log_gb = 512
  # /hana/shared = 1× RAM capped at 1 TB
  hana_shared_gb = min(local.hana_memory_gb, 1024)
  # /usr/sap and swap are fixed
  hana_usr_sap_gb = 50
  hana_swap_gb    = 32

  # Empty-sentinel check: a single entry with name="" means "use defaults"
  hana_config_provided     = length(var.vsi_hana_db_storage_config) > 0 && var.vsi_hana_db_storage_config[0].name != ""
  hana_additional_provided = length(var.vsi_hana_db_additional_storage_config) > 0 && var.vsi_hana_db_additional_storage_config[0].name != ""

  hana_storage_default = [
    { name = "hana-data", size = tostring(local.hana_data_gb), iops = "10iops-tier", mount = "/hana/data", count = "1" },
    { name = "hana-log", size = tostring(local.hana_log_gb), iops = "10iops-tier", mount = "/hana/log", count = "1" },
    { name = "hana-shared", size = tostring(local.hana_shared_gb), iops = "5iops-tier", mount = "/hana/shared", count = "1" },
    { name = "usr-sap", size = tostring(local.hana_usr_sap_gb), iops = "10iops-tier", mount = "/usr/sap", count = "1" },
    { name = "swap", size = tostring(local.hana_swap_gb), iops = "10iops-tier", mount = "swap", count = "1" },
  ]
  # Custom config replaces the default; additional volumes (when non-empty) are always appended.
    hana_storage = concat(local.hana_config_provided ? var.vsi_hana_db_storage_config : local.hana_storage_default, local.hana_additional_provided ? var.vsi_hana_db_additional_storage_config : [])
  # Keyed map used by for_each in the volume resource — key = "{prefix}-{hostname}-{name}"
  hana_volume_map    = { for v in local.hana_storage : "${var.prefix}-hanadb-${v.name}" => v }
  hana_vol_mount_map = { for v in local.hana_storage : v.name => v.mount }
  hana_vol_fs_map    = { for v in local.hana_storage : v.name => (v.mount == "swap" ? "swap" : "xfs") }

  #######################################################################
  # APP (NetWeaver) volume sizing.
  #######################################################################
  app_config_provided     = length(var.vsi_app_storage_config) > 0 && var.vsi_app_storage_config[0].name != ""
  app_additional_provided = length(var.vsi_app_additional_storage_config) > 0 && var.vsi_app_additional_storage_config[0].name != ""

  app_storage_default = [
    { name = "usr-sap", size = "128", iops = "10iops-tier", mount = "/usr/sap", count = "1" },
    { name = "swap", size = "30", iops = "10iops-tier", mount = "swap", count = "1" },
  ]
  app_storage = concat(local.app_config_provided ? var.vsi_app_storage_config : local.app_storage_default, local.app_additional_provided ? var.vsi_app_additional_storage_config : [])
  # Keyed map used by for_each in the volume resource — key = "{prefix}-app-{name}"
  app_volume_map    = { for v in local.app_storage : "${var.prefix}-app-${v.name}" => v }
  app_vol_mount_map = { for v in local.app_storage : v.name => v.mount }
  app_vol_fs_map    = { for v in local.app_storage : v.name => (v.mount == "swap" ? "swap" : "xfs") }
}
