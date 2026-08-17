output "prefix" {
  description = "The prefix that is associated with all resources."
  value       = var.prefix
}

########################################################################
# Landing Zone VPC outputs
########################################################################

output "vpc_names" {
  description = "A list of the names of the VPC."
  value       = module.landing_zone.vpc_names
}

output "vsi_names" {
  description = "A list of the vsis names provisioned within the VPCs."
  value       = module.landing_zone.vsi_names
}

output "ssh_public_key" {
  description = "The string value of the ssh public key used when deploying VPC."
  value       = var.ssh_public_key
}

output "transit_gateway_name" {
  description = "The name of the transit gateway."
  value       = module.landing_zone.transit_gateway_name
}

output "transit_gateway_id" {
  description = "The ID of transit gateway."
  value       = module.landing_zone.transit_gateway_data.id
}

output "transit_gateway_global" {
  description = "Connect to the networks outside the associated region."
  value       = var.transit_gateway_global
}

output "vsi_list" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value       = module.landing_zone.vsi_list
}

output "vpc_data" {
  description = "List of VPC data."
  value       = module.landing_zone.vpc_data
}

output "kms_key_map" {
  description = "Map of ids and keys for KMS keys created"
  value       = module.landing_zone.key_map
}

output "vsi_ssh_key_data" {
  description = "List of SSH key data"
  value       = module.landing_zone.ssh_key_data
}

output "resource_group_data" {
  description = "List of resource groups data used within landing zone."
  value       = module.landing_zone.resource_group_data
}

output "access_host_or_ip" {
  description = "Access host(jump/bastion) for created PowerVS infrastructure."
  value       = local.access_host_or_ip
}

output "proxy_host_or_ip_port" {
  description = "Proxy host:port for created PowerVS infrastructure."
  value       = "${local.network_services_vsi_ip}:${local.network_services_config.squid.squid_port}"
}

output "dns_host_or_ip" {
  description = "DNS forwarder host for created PowerVS infrastructure."
  value       = var.configure_dns_forwarder ? local.network_services_vsi_ip : ""
}

output "ntp_host_or_ip" {
  description = "NTP host for created PowerVS infrastructure."
  value       = var.configure_ntp_forwarder ? local.network_services_vsi_ip : ""
}

output "nfs_host_or_ip_path" {
  description = "NFS host for created PowerVS infrastructure."
  value       = var.configure_nfs_server ? local.nfs_host_or_ip_path : ""
}

output "ansible_host_or_ip" {
  description = "Central Ansible node private IP address."
  value       = local.network_services_vsi_ip
}

output "network_services_config" {
  description = "Complete configuration of network management services."
  value       = local.network_services_config
}

########################################################################
# Monitoring output
########################################################################

output "monitoring_instance" {
  description = "Details of the IBM Cloud Monitoring Instance: CRN, location, guid, monitoring_host_ip. monitoring_host_ip is an empty string if enable_monitoring_host is disabled."
  value       = local.monitoring_instance
}

########################################################################
# SCC Workload Protection Output
########################################################################

output "scc_wp_instance" {
  description = "Details of the Security and Compliance Center Workload Protection Instance: guid, access key, api_endpoint, ingestion_endpoint."
  value       = local.scc_wp_instance
}
