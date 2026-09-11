variable "ibmcloud_api_key" {
  description = "IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "vpc_zone" {
  description = "IBM Cloud VPC Zone location where VPC resources will be created."
  type        = string
}

variable "prefix" {
  description = "Unique prefix for resources to be created (e.g., SAP system name). Must be an lowercase alphanumeric characters and hyphens with maximum length of 7 characters."
  type        = string
  validation {
    condition = (
      var.prefix != null &&
      var.prefix != "" &&
      length(var.prefix) <= 7 &&
      can(regex("^[a-z0-9-]+$", var.prefix))
    )
    error_message = "Prefix must be up to 7 characters long and may include lowercase letters, numbers, and hyphens only."
  }
}

variable "external_access_ip" {
  description = "Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address."
  type        = string
}

#####################################################
# VPC HANA Instance parameters
#####################################################

variable "vpc_hana_instance_sap_profile_id" {
  description = "VPC instance profile for the VPC SAP HANA instance. Must be a HANA-certified mx2, vx2d, or ux2d profile. The memory encoded in the profile name (e.g. mx2-16x128 → 128 GB) is used to auto-calculate volume sizes."
  type        = string
  default     = "mx2-16x128"
}

variable "vpc_hana_instance_image" {
  description = "OS image name for the SAP HANA DB VSI. Must be an SAP HANA certified RHEL or SLES image."
  type        = string
  default     = "ibm-redhat-9-6-amd64-sap-hana-10"
}

variable "vpc_hana_instance_custom_storage_config" {
  description = "Custom storage for the HANA DB VSI. Replaces the entire auto-calculated layout. Leave as default (empty name) to use auto-calculated volumes for hana/data, hana/log, hana/shared, and swap from the profile memory. Each entry defines one block volume: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    iops  = string
    mount = string
    pool  = optional(string)
  }))
  default = [{
    name : ""
    size : ""
    count : ""
    iops : ""
    mount : ""
  }]
}

variable "vpc_hana_instance_additional_storage_config" {
  description = "Additional block volumes to attach to the HANA DB VSI, appended after the custom or auto-calculated volumes. Useful for extra file systems such as backup or archive mounts. Leave as default to attach no additional volumes. Each entry: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    iops  = string
    mount = string
    pool  = optional(string)
  }))
  default = [{
    name : "usr-sap"
    size : "50"
    count : "1"
    iops : "10iops-tier"
    mount : "/usr/sap"
  }]
}

#####################################################
# SAP APP (NetWeaver) VSI parameters
#####################################################

variable "vpc_app_instance_profile_id" {
  description = "VPC instance profile for the SAP Application VSI."
  type        = string
  default     = "bx2-4x16"
}

variable "vpc_app_instance_image" {
  description = "OS image name for the SAP Application VSI. Must be an SAP Applications certified RHEL or SLES image."
  type        = string
  default     = "ibm-redhat-9-6-amd64-sap-applications-10"
}

variable "vpc_app_instance_storage_config" {
  description = "storage for the APP VSI. Replaces the default layout. Leave as default (empty name) to use the default layout [50 GB /usr/sap, 50 GB /sapmnt]. Each entry defines one block volume: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    iops  = string
    mount = string
  }))
  default = [
    { name : "usr-sap", size : "50", count : "1", iops : "10iops-tier", mount : "/usr/sap" },
    { name : "swap", size : "30", count : "1", iops : "10iops-tier", mount : "swap" },
    { name : "sap-mnt", size : "50", count : "1", iops : "10iops-tier", mount : "/sapmnt" },
  ]
}

#####################################################
# OS parameters
#####################################################

variable "ssh_public_key" {
  description = "Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM VPC instances. Should match to uploaded public SSH key referenced by 'ssh_public_key' which was created previously. The key is temporarily stored and deleted. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "nfs_server_config" {
  description = "Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount_path' defines the target mount point on os."

  type = object({
    size       = number
    iops       = number
    mount_path = string
  })

  default = {
    "size" : 200,
    "iops" : 600,
    "mount_path" : "/nfs"
  }
}

#####################################################
# Parameters for Image
#####################################################

variable "vpc_landing_zone_images" {
  description = "Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring)."
  type = object({
    rhel_image = string
    sles_image = string
  })
  default = {
    "rhel_image" : "ibm-redhat-9-6-amd64-sap-applications-10"
    "sles_image" : "ibm-sles-15-7-amd64-sap-applications-1"
  }
}

# #####################################################
# # Parameters for SAP Installation
# #####################################################

variable "sap_domain" {
  description = "SAP domain name used across HANA and NetWeaver configurations."
  type        = string
  default     = "sap.com"
}

# #####################################################
# # Optional Parameters VPN and Secrets Manager
# #####################################################

variable "client_to_site_vpn" {
  description = "VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance."
  type = object({
    enable                        = bool
    client_ip_pool                = string
    vpn_client_access_group_users = list(string)
  })

  default = {
    "enable" : true,
    "client_ip_pool" : "192.168.0.0/16",
    "vpn_client_access_group_users" : []
  }
}

variable "sm_service_plan" {
  type        = string
  description = "The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null."
  default     = "standard"
}

variable "existing_sm_instance_guid" {
  type        = string
  description = "An existing Secrets Manager GUID. If not provided a new instance will be provisioned."
  default     = null
}

variable "existing_sm_instance_region" {
  type        = string
  description = "Required if value is passed into `var.existing_sm_instance_guid`."
  default     = null

}

#####################################################
# Parameters for Monitoring
#####################################################

variable "enable_monitoring" {
  description = "Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance and an Intel Monitoring Instance to host the services."
  type        = bool
}

#################################################
# Parameters SCC Workload Protection
#################################################

variable "enable_scc_wp" {
  description = "Set to true to enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all VSIs in this deployment."
  type        = bool
}

#####################################################
# Other Parameters
#####################################################

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible playbooks that contain sensitive information. Required when SCC workload Protection is enabled. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.ansible_vault_password) >= 0
    error_message = "ansible_vault_password is required."
  }
}

variable "tags" {
  description = "List of tag names for the IBM Cloud resources created."
  type        = list(string)
  default     = []
}

#####################################################
# Optional Parameters VPC subnets
#####################################################

variable "vpc_subnet_cidrs" {
  description = "CIDR values for the VPC subnets to be created. It's customer responsibility that none of the defined networks collide, including VPN client pool."
  type = object({
    vpn  = string
    mgmt = string
    vpe  = string
    edge = string
  })
  default = {
    "vpn" : "10.30.10.0/24"
    "mgmt" : "10.30.20.0/24"
    "vpe" : "10.30.30.0/24"
    "edge" : "10.30.40.0/24"
  }
}

#####################################################
# Optional Parameters Activity Tracker and VPC Flow Logs
#####################################################

variable "enable_atracker" {
  description = "Enable Activity Tracker. If true, Activity Tracker resources (KMS key, COS instance, bucket, and atracker configuration) will be created."
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC flow logs. If true, flow logs will be stored in the atracker bucket."
  type        = bool
  default     = true
}
