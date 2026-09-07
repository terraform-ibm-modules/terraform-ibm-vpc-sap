#######################################################
# Power Virtual Server with VPC landing zone module
# VPC landing zone
#######################################################

module "standard" {
  source = "../../../modules/vpc-landing-zone"

  providers = {
    ibm.ibm-is = ibm.ibm-is
    ibm.ibm-sm = ibm.ibm-sm
  }

  vpc_zone                    = var.vpc_zone
  prefix                      = var.prefix
  external_access_ip          = var.external_access_ip
  vpc_intel_images            = var.vpc_landing_zone_images
  ssh_public_key              = var.ssh_public_key
  ssh_private_key             = var.ssh_private_key
  user_data                   = local.user_data
  configure_dns_forwarder     = true
  configure_ntp_forwarder     = true
  configure_nfs_server        = true
  nfs_server_config           = var.nfs_server_config
  dns_forwarder_config        = { "dns_servers" : "161.26.0.7; 161.26.0.8; 9.9.9.9;" }
  tags                        = var.tags
  client_to_site_vpn          = var.client_to_site_vpn
  sm_service_plan             = var.sm_service_plan
  existing_sm_instance_guid   = var.existing_sm_instance_guid
  existing_sm_instance_region = var.existing_sm_instance_region
  enable_monitoring           = var.enable_monitoring
  enable_monitoring_host      = var.enable_monitoring
  enable_scc_wp               = var.enable_scc_wp
  ansible_vault_password      = var.ansible_vault_password
  vpc_subnet_cidrs            = var.vpc_subnet_cidrs
  enable_atracker             = var.enable_atracker
  enable_vpc_flow_logs        = var.enable_vpc_flow_logs
}


#######################################################
# SAP HANA DB VSI
#######################################################

module "hana_db" {
  source     = "../../../modules/vsi"
  depends_on = [module.standard]

  providers = { ibm.ibm-is = ibm.ibm-is }

  name              = "${var.prefix}-hanadb"
  profile           = var.vpc_hana_instance_sap_profile_id
  image             = var.vpc_hana_instance_image
  vpc_id            = local.vpc_id
  zone              = var.vpc_zone
  resource_group_id = local.resource_group_id
  subnet_id         = local.subnet_id
  security_group_id = local.security_group_id
  ssh_key_id        = local.ssh_key_id
  user_data         = local.user_data
  volume_map        = local.hana_volume_map
  tags              = var.tags
}

#######################################################
# SAP APP (NetWeaver) VSI
#######################################################

module "app_server" {
  source     = "../../../modules/vsi"
  depends_on = [module.standard]

  providers = { ibm.ibm-is = ibm.ibm-is }

  name              = "${var.prefix}-app"
  profile           = var.vpc_app_instance_profile_id
  image             = var.vpc_app_instance_image
  vpc_id            = local.vpc_id
  zone              = var.vpc_zone
  resource_group_id = local.resource_group_id
  subnet_id         = local.subnet_id
  security_group_id = local.security_group_id
  ssh_key_id        = local.ssh_key_id
  user_data         = local.user_data
  volume_map        = local.app_volume_map
  tags              = var.tags
}

#######################################################
# Configure Network Services on SAP HANA DB VSI
# Configures DNS, NTP, NFS filesystems
#######################################################

module "linux_init_hana_db" {
  source     = "../../../modules/vpc-landing-zone/submodules/ansible"
  depends_on = [module.hana_db]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "configure-network-services/ansible_exec.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-hanadb-linux-init.sh"

  src_playbook_template_name = "configure-network-services/playbook-configure-network-services.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-hanadb-linux-init-playbook.yml"

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-hanadb-linux-init-inventory"

  playbook_template_vars = {
    "server_config" : jsonencode({})
    "client_config" : jsonencode({
      "squid" : {
        enable          = false
        squid_port      = ""
        squid_server_ip = ""
      }
      "dns" : { enable = true, dns_server_ip = module.standard.ansible_host_or_ip }
      "ntp" : { enable = true, ntp_server_ip = module.standard.ansible_host_or_ip }
      "nfs" : {
        enable          = true
        nfs_server_path = module.standard.nfs_host_or_ip_path
        nfs_client_path = var.nfs_server_config.mount_path
        opts            = "sec=sys,nfsvers=4.1,nofail"
        fstype          = "nfs4"
      }
    })
    "storage_config" : jsonencode(local.hana_fs_config)
  }

  inventory_template_vars = { "host_or_ip" : module.hana_db.instance_ip }
}


#######################################################
# Configure Network Services on SAP APP (NetWeaver) VSI
# Configures DNS, NTP, NFS filesystems
#######################################################

module "linux_init_app_server" {
  source     = "../../../modules/vpc-landing-zone/submodules/ansible"
  depends_on = [module.app_server]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "configure-network-services/ansible_exec.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-app-linux-init.sh"

  src_playbook_template_name = "configure-network-services/playbook-configure-network-services.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-app-linux-init-playbook.yml"

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-app-linux-init-inventory"

  playbook_template_vars = {
    "server_config" : jsonencode({})
    "client_config" : jsonencode({
      "squid" : {
        enable          = false
        squid_port      = ""
        squid_server_ip = ""
      }
      "dns" : { enable = true, dns_server_ip = module.standard.ansible_host_or_ip }
      "ntp" : { enable = true, ntp_server_ip = module.standard.ansible_host_or_ip }
      "nfs" : {
        enable          = true
        nfs_server_path = module.standard.nfs_host_or_ip_path
        nfs_client_path = var.nfs_server_config.mount_path
        opts            = "sec=sys,nfsvers=4.1,nofail"
        fstype          = "nfs4"
      }
    })
    "storage_config" : jsonencode(local.app_fs_config)
  }

  inventory_template_vars = { "host_or_ip" : module.app_server.instance_ip }
}

#######################################################
# SAP OS preconfiguration — HANA DB VSI
#######################################################

module "configure_os_hana_db" {
  source     = "../../../modules/ansible"
  depends_on = [module.linux_init_hana_db]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "configure-os-for-sap/ansible_exec.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-hanadb-configure-os.sh"

  src_playbook_template_name = "configure-os-for-sap/playbook-configure-os-for-sap.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-hanadb-configure-os-playbook.yml"
  playbook_template_vars = {
    "sap_solution" : "HANA"
    "sap_domain" : var.sap_domain
  }

  src_inventory_template_name = "pi-instance-inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-hanadb-configure-os-inventory"
  inventory_template_vars     = { "pi_instance_management_ip" : module.hana_db.instance_ip }
}

#######################################################
# SAP OS preconfiguration — APP (NetWeaver) VSI
#######################################################

module "configure_os_app_server" {
  source     = "../../../modules/ansible"
  depends_on = [module.linux_init_app_server]

  bastion_host_ip        = module.standard.access_host_or_ip
  ansible_host_or_ip     = module.standard.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "configure-os-for-sap/ansible_exec.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-app-configure-os.sh"

  src_playbook_template_name = "configure-os-for-sap/playbook-configure-os-for-sap.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-app-configure-os-playbook.yml"
  playbook_template_vars = {
    "sap_solution" : "NETWEAVER"
    "sap_domain" : var.sap_domain
  }

  src_inventory_template_name = "pi-instance-inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-app-configure-os-inventory"
  inventory_template_vars     = { "pi_instance_management_ip" : module.app_server.instance_ip }
}
