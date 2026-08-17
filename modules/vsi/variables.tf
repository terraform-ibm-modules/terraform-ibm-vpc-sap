variable "vpc_id" {
  description = "ID of the VPC in which to create the VSI."
  type        = string
}

variable "zone" {
  description = "IBM Cloud zone in which to create the VSI and its volumes."
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group for the VSI and its volumes."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for the VSI primary network interface."
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group to attach to the VSI primary network interface."
  type        = string
}

variable "ssh_key_id" {
  description = "ID of the SSH key to inject into the VSI."
  type        = string
}

variable "name" {
  description = "Full name for the VSI (already includes prefix and role, e.g. 'sap1-hanadb')."
  type        = string
}

variable "profile" {
  description = "VPC instance profile for the VSI (e.g. 'mx2-16x128')."
  type        = string
}

variable "image" {
  description = "OS image name for the VSI."
  type        = string
}

variable "user_data" {
  description = "cloud-init user data string to bootstrap the VSI."
  type        = string
}

variable "tags" {
  description = "List of tags to attach to the VSI and its volumes."
  type        = list(string)
  default     = []
}

variable "volume_map" {
  description = "Map of volumes to create and attach. Key is the full volume name; value is an object with 'size' (GB, as string) and 'iops' (IBM Cloud volume profile string)."
  type = map(object({
    size = string
    iops = string
  }))
}
