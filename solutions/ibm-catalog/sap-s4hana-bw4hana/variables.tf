variable "ibmcloud_api_key" {
  description = "IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "vpc_zone" {
  description = "IBM Cloud data center location where VPC resources will be created."
  type        = string
}

variable "prefix" {
  description = "Unique prefix for resources to be created (e.g., SAP system name). Must be an alphanumeric string with maximum length of 8 characters."
  type        = string
  validation {
    condition = (
      var.prefix != null &&
      var.prefix != "" &&
      length(var.prefix) <= 8 &&
      can(regex("^[a-z0-9-]+$", var.prefix))
    )
    error_message = "Prefix must be up to 8 characters long and may include lowercase letters, numbers, and hyphens only."
  }
}

variable "external_access_ip" {
  description = "Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address."
  type        = string
}

#####################################################
# SAP HANA DB VSI parameters
#####################################################

variable "vsi_hana_db_profile" {
  description = "VPC instance profile for the SAP HANA DB VSI. Must be a HANA-certified mx2, vx2d, or ux2d profile. The memory encoded in the profile name (e.g. mx2-16x128 → 128 GB) is used to auto-calculate volume sizes."
  type        = string
  default     = "mx2-16x128"
}

variable "vsi_hana_db_image" {
  description = "OS image name for the SAP HANA DB VSI. Must be an SAP HANA certified RHEL or SLES image."
  type        = string
  default     = "ibm-redhat-9-6-amd64-sap-hana-10"
}

variable "vsi_hana_db_storage_config" {
  description = "Custom storage for the HANA DB VSI. Replaces the entire auto-calculated layout. Leave as default (empty name) to use auto-calculated volumes for hana/data, hana/log, hana/shared, usr/sap and swap from the profile memory. Each entry defines one block volume: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    iops  = string
    mount = string
    pool  = optional(string)
  }))
  default = [{
    name  = ""
    size  = ""
    count = ""
    iops  = ""
    mount = ""
  }]
}

variable "vsi_hana_db_additional_storage_config" {
  description = "Additional block volumes to attach to the HANA DB VSI, appended after the custom or auto-calculated volumes. Useful for extra file systems such as backup or archive mounts. Leave as default (empty name) to attach no additional volumes. Each entry: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    iops  = string
    mount = string
    pool  = optional(string)
  }))
  default = [{
    name  = "usr-sap"
    size  = "50"
    count = "1"
    iops  = "10iops-tier"
    mount = "/usr/sap"
  }]
}

#####################################################
# SAP APP (NetWeaver) VSI parameters
#####################################################

variable "vsi_app_profile" {
  description = "VPC instance profile for the SAP Application VSI."
  type        = string
  default     = "bx2-4x16"
}

variable "vsi_app_image" {
  description = "OS image name for the SAP Application VSI. Must be an SAP Applications certified RHEL or SLES image."
  type        = string
  default     = "ibm-redhat-9-6-amd64-sap-applications-10"
}

variable "vsi_app_storage_config" {
  description = "storage for the APP VSI. Replaces the default layout. Leave as default (empty name) to use the default layout [50 GB /usr/sap, 50 GB /sapmnt]. Each entry defines one block volume: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    iops  = string
    mount = string
  }))
  default = [
    { name = "usr-sap", size = "50", count = "1", iops = "10iops-tier", mount = "/usr/sap" },
    { name = "swap", size = "30", count = "1", iops = "10iops-tier", mount = "swap" },
    { name = "sap-mnt", size = "50", count = "1", iops = "10iops-tier", mount = "/sapmnt" },
  ]
}

#variable "vsi_app_additional_storage_config" {
#  description = "Additional block volumes to attach to the APP VSI, appended after the custom or default volumes. Leave as default (empty name) to attach no additional volumes. Each entry: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS."
#  type = list(object({
#    name  = string
#    size  = string
#    count = string
#    iops  = string
#    mount = string
#  }))
#  default = [{
#    name  = ""
#    size  = ""
#    count = ""
#    iops  = ""
#    mount = ""
#  }]
#}




#####################################################
# OS parameters
#####################################################

variable "ssh_public_key" {
  description = "Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh_public_key' which was created previously. The key is temporarily stored and deleted. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "nfs_server_config" {
  description = "Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount_path' defines the target mount point on os. Set 'configure_nfs_server' to false to ignore creating file storage share."
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
    "rhel_image" : "ibm-redhat-9-6-amd64-sap-applications-1"
    "sles_image" : "ibm-sles-15-7-amd64-sap-applications-1"
  }
}

# #####################################################
# # Parameters for SAP Installation
# #####################################################

variable "sap_solution" {
  description = "SAP Solution to be installed on Power Virtual Server."
  type        = string
  validation {
    condition     = contains(["s4hana-2023", "s4hana-2022", "s4hana-2021", "s4hana-2020", "bw4hana-2021"], var.sap_solution) ? true : false
    error_message = "Solution value has to be one of 's4hana-2023', 's4hana-2022', 's4hana-2021', 's4hana-2020', 'bw4hana-2021'"
  }
}

variable "ibmcloud_cos_configuration" {
  description = "IBM Cloud Object Storage bucket containing SAP installation binaries. 'cos_hana_software_path' must contain only HANA DB binaries. 'cos_solution_software_path' must contain only S/4HANA or BW/4HANA binaries (no IMDB files). Avoid a leading '/' in path values. Files are downloaded to the NFS share mount path."
  type = object({
    cos_region                 = string
    cos_bucket_name            = string
    cos_hana_software_path     = string
    cos_solution_software_path = string
  })
  default = {
    "cos_region" : "eu-geo",
    "cos_bucket_name" : "sap-binaries",
    "cos_hana_software_path" : "HANA_DB",
    "cos_solution_software_path" : "S4HANA_2023"
  }
}

variable "ibmcloud_cos_service_credentials" {
  description = "Service credentials for the IBM Cloud Object Storage instance, as a JSON string. Must contain 'apikey' and 'resource_instance_id'. See https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials."
  type        = string
  sensitive   = true
}

variable "sap_hana_master_password" {
  description = "SAP HANA master password."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.sap_hana_master_password) >= 8 && length(var.sap_hana_master_password) <= 30 && can(regex("[A-Z]", var.sap_hana_master_password)) && can(regex("[a-z]", var.sap_hana_master_password)) && can(regex("[0-9]", var.sap_hana_master_password)) && !can(regex("[\\\\\"]", var.sap_hana_master_password))
    error_message = "The SAP HANA master password must be 8-30 characters long containing at least one lower character (a-z), one upper character (A-Z) and one digit (0-9), and must not include a backslash (\\) or double quote (\")."
  }
}

variable "sap_hana_vars" {
  description = "SAP HANA SID and instance number."
  type = object({
    sap_hana_install_sid    = string
    sap_hana_install_number = string
  })
  default = {
    "sap_hana_install_sid" : "HDB",
    "sap_hana_install_number" : "02"
  }
  validation {
    condition     = can(regex("^[A-Z][A-Z0-9]{2}$", var.sap_hana_vars.sap_hana_install_sid))
    error_message = "The provided sap_hana_vars configuration is invalid. The sap_hana_install_sid value must consist of exactly three alphanumeric characters, all uppercase, and the first character must be a letter."
  }
  validation {
    condition     = can(regex("^[0-9]{2}$", var.sap_hana_vars.sap_hana_install_number))
    error_message = "The sap_hana_install_number must be a numeric value between 00 and 99. For single-digit numbers, append a leading zero."
  }
  validation {
    condition = length(distinct([
      var.sap_hana_vars.sap_hana_install_number,
      var.sap_solution_vars.sap_swpm_ascs_instance_nr,
      var.sap_solution_vars.sap_swpm_pas_instance_nr
    ])) == 3

    error_message = "HANA (sap_hana_install_number), ASCS (sap_swpm_ascs_instance_nr), and PAS (sap_swpm_pas_instance_nr) instance numbers must not be the same."
  }
}

variable "sap_swpm_master_password" {
  description = "SAP SWPM master password."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.sap_swpm_master_password) >= 8 && length(var.sap_swpm_master_password) <= 30 && can(regex("[A-Z]", var.sap_swpm_master_password)) && can(regex("[a-z]", var.sap_swpm_master_password)) && can(regex("[0-9]", var.sap_swpm_master_password)) && !can(regex("[\\\\\"]", var.sap_swpm_master_password))
    error_message = "The SAP Software Provisioning Manager master password must be 8-30 characters long containing at least one lower character (a-z), one upper character (A-Z) and one digit (0-9), and must not include a backslash (\\) or double quote (\")."
  }
}

variable "sap_solution_vars" {
  description = "SAP SID, ASCS and PAS instance numbers and service/protectedwebmethods parameters."
  type = object({
    sap_swpm_sid                         = string
    sap_swpm_ascs_instance_nr            = string
    sap_swpm_pas_instance_nr             = string
    sap_swpm_service_protectedwebmethods = string

  })
  default = {
    "sap_swpm_sid" : "S4H",
    "sap_swpm_ascs_instance_nr" : "00",
    "sap_swpm_pas_instance_nr" : "01",
    "sap_swpm_service_protectedwebmethods" : "SDEFAULT -GetQueueStatistic -ABAPGetWPTable -EnqGetStatistic -GetProcessList -GetEnvironment -BAPGetSystemWPTable"
  }
  validation {
    condition     = var.sap_solution_vars.sap_swpm_ascs_instance_nr != var.sap_solution_vars.sap_swpm_pas_instance_nr
    error_message = "ASCS and PAS instance number must not be same"
  }
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

# variable "sap_monitoring_vars" {
#   description = "Configuration details for SAP monitoring dashboard. Takes effect only when a monitoring instance was deployed as part of Power Virtual Server with VPC landing zone deployment. If 'config_override' is true, an existing configuration will be overwritten, 'sap_monitoring_nr' Two-digit incremental number starting with 01 up to 99. This is not a existing SAP ID, but a pure virtual number and 'sap_monitoring_solution_name' is a virtual arbitrary short name to recognize SAP System."
#   type = object({
#     config_override              = bool
#     sap_monitoring_nr            = string
#     sap_monitoring_solution_name = string
#   })
#   default = {
#     "config_override" : false,
#     "sap_monitoring_nr" : "01",
#     "sap_monitoring_solution_name" : ""
#   }
#   validation {
#     condition     = (length(var.sap_monitoring_vars.sap_monitoring_nr) == 2 && tonumber(var.sap_monitoring_vars.sap_monitoring_nr) >= 0 && tonumber(var.sap_monitoring_vars.sap_monitoring_nr) <= 99) || var.sap_monitoring_vars.sap_monitoring_nr == ""
#     error_message = "sap_monitoring_nr should be a 2-digit number between 00 and 99. or empty"
#   }
# }

#################################################
# Parameters SCC Workload Protection
#################################################

variable "enable_scc_wp" {
  description = "Set to true to enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all VSIs and PowerVS instances in this deployment."
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
  description = "CIDR values for the VPC subnets to be created. It's customer responsibility that none of the defined networks collide, including the PowerVS subnets and VPN client pool."
  type = object({
    vpn  = string
    mgmt = string
    vpe  = string
    edge = string
  })
  default = {
    "vpn"  = "10.30.10.0/24"
    "mgmt" = "10.30.20.0/24"
    "vpe"  = "10.30.30.0/24"
    "edge" = "10.30.40.0/24"
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
