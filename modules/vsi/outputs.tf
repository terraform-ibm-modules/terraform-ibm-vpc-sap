output "instance_id" {
  description = "ID of the VSI."
  value       = ibm_is_instance.vsi.id
}

output "instance_name" {
  description = "Name of the VSI."
  value       = ibm_is_instance.vsi.name
}

output "instance_ip" {
  description = "Primary private IP address of the VSI."
  value       = ibm_is_instance.vsi.primary_network_interface[0].primary_ip[0].address
}

output "instance_zone" {
  description = "Zone in which the VSI was created."
  value       = ibm_is_instance.vsi.zone
}

output "instance_profile" {
  description = "Profile of the VSI."
  value       = ibm_is_instance.vsi.profile
}

output "volumes" {
  description = "Block volumes attached to the VSI."
  value = [for v in ibm_is_volume.volumes : {
    id       = v.id
    name     = v.name
    capacity = v.capacity
    profile  = v.profile
  }]
}
output "volume_attachments" {
  description = "Volume attachments on the VSI, including volume_id and device."
  value       = ibm_is_instance.vsi.volume_attachments
}
