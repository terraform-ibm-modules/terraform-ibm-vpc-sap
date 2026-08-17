###########################################################
# Ansible Host setup and execution module
###########################################################

locals {
  network_services_config = {
    squid = {
      "enable"     = true
      "squid_port" = "3128"
    }
    dns = merge(var.dns_forwarder_config, {
      "enable" = var.configure_dns_forwarder
    })
    ntp = {
      "enable" = var.configure_ntp_forwarder
    }
    nfs = {
      "enable"          = var.configure_nfs_server
      "nfs_server_path" = var.configure_nfs_server ? ibm_is_share_mount_target.mount_target_nfs[0].mount_path : ""
      "nfs_client_path" = var.configure_nfs_server ? var.nfs_server_config.mount_path : ""
      "opts"            = "sec=sys,nfsvers=4.1,nofail"
      "fstype"          = "nfs4"
    }
  }
}


module "configure_network_services" {

  source     = "./submodules/ansible"
  depends_on = [ibm_is_share_mount_target.mount_target_nfs]

  bastion_host_ip        = local.access_host_or_ip
  ansible_host_or_ip     = local.network_services_vsi_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = true

  src_script_template_name = "configure-network-services/ansible_exec.sh.tftpl"
  dst_script_file_name     = "network-services-instance.sh"

  src_playbook_template_name = "configure-network-services/playbook-configure-network-services.yml.tftpl"
  dst_playbook_file_name     = "network-services-instance-playbook.yml"
  playbook_template_vars = {
    "server_config" : jsonencode(
      { "squid" : local.network_services_config.squid,
        "dns" : local.network_services_config.dns,
        "ntp" : local.network_services_config.ntp
    }),
    "client_config" : jsonencode(
      { "nfs" : local.network_services_config.nfs
    })
  }

  src_inventory_template_name = "inventory.tftpl"
  dst_inventory_file_name     = "network-services-instance-inventory"
  inventory_template_vars     = { "host_or_ip" : local.network_services_vsi_ip }
}
