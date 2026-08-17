########################################################################
# Landing zone infrastructure rollup
########################################################################

output "infrastructure_data" {
  description = "VPC landing zone infrastructure details."
  value       = { for k, v in module.standard : k => v }
}

output "access_host_or_ip" {
  description = "Public IP of the bastion/jump host."
  value       = module.standard.access_host_or_ip
}

output "ansible_host_or_ip" {
  description = "Private IP of the network-services VSI (Ansible/NTP/DNS host)."
  value       = module.standard.ansible_host_or_ip
}

output "dns_host_or_ip" {
  description = "Private IP of the DNS forwarder."
  value       = module.standard.dns_host_or_ip
}

output "ntp_host_or_ip" {
  description = "Private IP of the NTP forwarder."
  value       = module.standard.ntp_host_or_ip
}

output "nfs_host_or_ip_path" {
  description = "NFS server host and mount path."
  value       = module.standard.nfs_host_or_ip_path
}

output "proxy_host_or_ip_port" {
  description = "Squid proxy host:port."
  value       = module.standard.proxy_host_or_ip_port
}

output "monitoring_instance" {
  description = "IBM Cloud Monitoring instance details."
  value       = module.standard.monitoring_instance
}

########################################################################
# SAP HANA DB VSI
########################################################################

output "hana_db_instance" {
  description = "SAP HANA DB VSI details: id, name, zone, and primary private IP."
  value = {
    id      = module.hana_db.instance_id
    name    = module.hana_db.instance_name
    zone    = module.hana_db.instance_zone
    ip      = module.hana_db.instance_ip
    profile = module.hana_db.instance_profile
  }
}

output "hana_db_volumes" {
  description = "Block volumes attached to the SAP HANA DB VSI."
  value       = module.hana_db.volumes
}

########################################################################
# SAP APP (NetWeaver) VSI
########################################################################

output "app_instance" {
  description = "SAP Application (NetWeaver) VSI details: id, name, zone, and primary private IP."
  value = {
    id      = module.app.instance_id
    name    = module.app.instance_name
    zone    = module.app.instance_zone
    ip      = module.app.instance_ip
    profile = module.app.instance_profile
  }
}

output "app_volumes" {
  description = "Block volumes attached to the SAP Application VSI."
  value       = module.app.volumes
}
