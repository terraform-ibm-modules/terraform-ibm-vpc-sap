#####################################################
# VPC Landing Zone module
#####################################################
locals {
  external_access_ip = var.external_access_ip != null && var.external_access_ip != "" ? length(regexall("/", var.external_access_ip)) > 0 ? var.external_access_ip : "${var.external_access_ip}/32" : ""

  # Generate user_data with SSH public key
  generated_user_data = <<-EOT
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


  override_json_string = templatefile("${path.module}/presets/slz-preset.json.tftpl",
    {
      external_access_ip           = local.external_access_ip,
      rhel_image                   = var.vpc_intel_images.rhel_image,
      network_services_vsi_profile = var.network_services_vsi_profile,
      user_data                    = var.user_data != null ? replace(var.user_data, "\n", "\\n") : replace(local.generated_user_data, "\n", "\\n")
      transit_gateway_global       = var.transit_gateway_global,
      enable_monitoring_host       = var.enable_monitoring_host,
      sles_image                   = var.vpc_intel_images.sles_image,
      availability_zone            = "zone-${regex("[0-9]+$", var.vpc_zone)}"
      vpc_subnet_cidrs             = var.vpc_subnet_cidrs
      vpn_client_cidr              = var.client_to_site_vpn.enable ? var.client_to_site_vpn.client_ip_pool : null
      enable_atracker              = var.enable_atracker
      enable_vpc_flow_logs         = var.enable_vpc_flow_logs
    }
  )
}


module "landing_zone" {
  source    = "terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module"
  version   = "8.21.6"
  providers = { ibm = ibm.ibm-is }

  ssh_public_key       = var.ssh_public_key
  region               = local.vpc_region
  prefix               = var.prefix
  override_json_string = local.override_json_string
  kms_endpoint_type    = "public"
}


#####################################################
# Locals for verifying and extracting IPs
# from landing zone outputs to configure OS
#####################################################

locals {
  vpc_region = regex("^(.+)-[0-9]+$", var.vpc_zone)[0]

  key_fip_vsi_exists     = contains(keys(module.landing_zone), "fip_vsi") ? true : false
  key_floating_ip_exists = local.key_fip_vsi_exists ? contains(keys(module.landing_zone.fip_vsi[0]), "floating_ip") ? true : false : false
  access_host_or_ip      = local.key_floating_ip_exists ? module.landing_zone.fip_vsi[0].floating_ip : ""

  key_vsi_list_exists = contains(keys(module.landing_zone), "vsi_list") ? true : false
  # network_services_vsi_exists = local.key_vsi_list_exists ? contains(module.landing_zone.vsi_names, "${var.prefix}-network-services-001") ? true : false : false
  network_services_vsi_exists = local.key_vsi_list_exists ? length([for vsi_name in module.landing_zone.vsi_names : vsi_name if can(regex("${var.prefix}-network-services", vsi_name))]) > 0 ? true : false : false
  network_services_vsi_ip     = local.network_services_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if can(regex("${var.prefix}-network-services", vsi.name))][0] : ""

  monitoring_vsi_exists = local.key_vsi_list_exists ? length([for vsi_name in module.landing_zone.vsi_names : vsi_name if can(regex("${var.prefix}-monitoring", vsi_name))]) > 0 ? true : false : false
  monitoring_vsi_ip     = local.monitoring_vsi_exists ? [for vsi in module.landing_zone.vsi_list : vsi.ipv4_address if can(regex("${var.prefix}-monitoring", vsi.name))][0] : ""

  ###### For preset floating ip and network services vsi should exist.
  valid_json_used   = local.key_floating_ip_exists && local.network_services_vsi_exists ? true : false
  validate_json_msg = "Wrong JSON preset used. Please use one of the JSON preset supported."
  # tflint-ignore: terraform_unused_declarations
  validate_json_chk = regex("^${local.validate_json_msg}$", (local.valid_json_used ? local.validate_json_msg : ""))
}
