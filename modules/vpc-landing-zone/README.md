# Module powervs-vpc-landing-zone

## IBM Power Virtual Server with VPC Landing Zone

This module provisions the following resources in IBM Cloud:
- A **VPC Infrastructure** with the following components:
    - One VSI for management (jump/bastion) VSI
    - One VSI for network-services configured as squid proxy, NTP and DNS servers(using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). This VSI also acts as central ansible execution node.
    - Optional VSI for Monitoring host
    - Optional [Client to site VPN server](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
    - Optional [File storage share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui)
    - Optional [Network load balancer](https://cloud.ibm.com/docs/vpc?group=network-load-balancer)
    - IBM Cloud Object storage(COS) Virtual Private endpoint gateway(VPE)
    - IBM Cloud Object storage(COS) Instance and buckets
    - VPC flow logs
    - KMS keys
    - Activity tracker
    - Optional Secrets Manager Instance Instance with private certificate.
    - For single zone components, the VPC zone is automatically chosen to be in the same availability zone with the selected PowerVS zone.


- A local or global **transit gateway**
- An optional IBM Cloud Monitoring Instance

- A **Power Virtual Server** workspace with the following network topology:
    - Creates two private networks: a management network and a backup network.
    - Attaches the PowerVS workspace to transit gateway
    - Creates an SSH key.
    - Optionally imports up to three custom images from Cloud Object Storage.

- Finally, interconnects both VPC and PowerVS infrastructure.

## Usage
```hcl
provider "ibm" {
  alias            = "ibm-pi"
  region           = ""
  zone             = ""
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

provider "ibm" {
  alias            = "ibm-is"
  region           = ""
  zone             = ""
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "vpc-landing-zone" {
  source  = "terraform-ibm-modules/vpc-sap/ibm//modules//vpc-landing-zone"
  version = "x.x.x" # Replace "x.x.x" with a git release version to lock into a specific release

  providers = { ibm.ibm-is = ibm.ibm-is }

  vpc_zone                                 = var.powervs_zone
  prefix                                       = var.prefix
  external_access_ip                           = var.external_access_ip
  vpc_intel_images                             = var.vpc_intel_images
  ssh_public_key                               = var.ssh_public_key
  ssh_private_key                              = var.ssh_private_key
  transit_gateway_global                       = var.transit_gateway_global                       #(optional,  default false)
  network_services_vsi_profile                 = var.network_services_vsi_profile                 #(optional.  default check vars)
  configure_dns_forwarder                      = var.configure_dns_forwarder                      #(optional,  default false)
  configure_ntp_forwarder                      = var.configure_ntp_forwarder                      #(optional,  default false)
  configure_nfs_server                         = var.configure_nfs_server                         #(optional.  default false)
  dns_forwarder_config                         = var.dns_forwarder_config                         #(optional.  default check vars)
  nfs_server_config                            = var.nfs_server_config                            #(optional.  default check vars)
  tags                                         = var.tags                                         #(optional.  default [])
  client_to_site_vpn                           = var.client_to_site_vpn                           #(optional.  default check vars)
  sm_service_plan                              = var.sm_service_plan                              #(optional.  default standard)
  existing_sm_instance_guid                    = var.existing_sm_instance_guid                    #(optional.  default null)
  existing_sm_instance_region                  = var.existing_sm_instance_region                  #(optional.  default null)
  enable_monitoring                            = var.enable_monitoring                            #(optional.  default false)
  enable_monitoring_host                       = var.enable_monitoring_host                            #(optional.  default false)
  existing_monitoring_instance_crn             = var.existing_monitoring_instance_crn             #(optional.  default null)
  enable_scc_wp                                = var.enable_scc_wp                                #(optional.  default false)
  ansible_vault_password                       = var.ansible_vault_password                       #(optional.  default null)
}
```

### Notes:
Catalog image names to be imported into infrastructure can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-workspace/blob/main/docs/catalog_images_list.md)

Creates VPC Landing Zone | Performs VPC VSI OS Config | Creates PowerVS Infrastructure | Creates PowerVS Instance | Performs PowerVS OS Config |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | N/A | N/A |


## Supported Reference architectures
1. [Standard Landscape Variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard/deploy-arch-ibm-pvs-inf-standard.svg)
2. [Quickstart (Standard Landscape plus VSI) variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/standard-plus-vsi/deploy-arch-ibm-pvs-inf-standard-plus-vsi.svg)


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.65.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_config"></a> [app\_config](#module\_app\_config) | terraform-ibm-modules/app-configuration/ibm | 1.18.12 |
| <a name="module_client_to_site_vpn"></a> [client\_to\_site\_vpn](#module\_client\_to\_site\_vpn) | terraform-ibm-modules/client-to-site-vpn/ibm | 3.6.7 |
| <a name="module_configure_monitoring_host"></a> [configure\_monitoring\_host](#module\_configure\_monitoring\_host) | ./submodules/ansible | n/a |
| <a name="module_configure_network_services"></a> [configure\_network\_services](#module\_configure\_network\_services) | ./submodules/ansible | n/a |
| <a name="module_configure_scc_wp_agent"></a> [configure\_scc\_wp\_agent](#module\_configure\_scc\_wp\_agent) | ./submodules/ansible | n/a |
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | terraform-ibm-modules/landing-zone/ibm//patterns//vsi//module | 8.21.6 |
| <a name="module_private_secret_engine"></a> [private\_secret\_engine](#module\_private\_secret\_engine) | terraform-ibm-modules/secrets-manager-private-cert-engine/ibm | 2.0.5 |
| <a name="module_scc_wp_instance"></a> [scc\_wp\_instance](#module\_scc\_wp\_instance) | terraform-ibm-modules/scc-workload-protection/ibm | 1.21.0 |
| <a name="module_secrets_manager_group"></a> [secrets\_manager\_group](#module\_secrets\_manager\_group) | terraform-ibm-modules/secrets-manager-secret-group/ibm | 1.5.5 |
| <a name="module_secrets_manager_private_certificate"></a> [secrets\_manager\_private\_certificate](#module\_secrets\_manager\_private\_certificate) | terraform-ibm-modules/secrets-manager-private-cert/ibm | 1.12.8 |

### Resources

| Name | Type |
|------|------|
| [ibm_is_share.file_share_nfs](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share) | resource |
| [ibm_is_share_mount_target.mount_target_nfs](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_share_mount_target) | resource |
| [ibm_is_vpc_address_prefix.vpn_address_prefix](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpc_address_prefix) | resource |
| [ibm_resource_instance.monitoring_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.secrets_manager](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible playbooks that contain sensitive information. Required when SCC workload Protection is enabled. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | `null` | no |
| <a name="input_client_to_site_vpn"></a> [client\_to\_site\_vpn](#input\_client\_to\_site\_vpn) | VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance. PowerVS server routes will create additional entries in the routing table to establish connectivity between the VPN and PowerVS. This is only needed if the PowerVS subnets are in this module are set to null and additional subnets are created outside of this module. Each route must have a unique name and destination CIDR. | <pre>object({<br/>    enable                        = bool<br/>    client_ip_pool                = string<br/>    vpn_client_access_group_users = list(string)<br/>    powervs_server_routes = optional(list(object({<br/>      route_name  = string<br/>      destination = string<br/>      action      = string<br/>    })))<br/>    }<br/>  )</pre> | <pre>{<br/>  "client_ip_pool": "192.168.0.0/16",<br/>  "enable": false,<br/>  "powervs_server_routes": null,<br/>  "vpn_client_access_group_users": []<br/>}</pre> | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns\_forwarder\_config' optional variable is set properly. DNS forwarder will be installed on the network-services vsi. | `bool` | `false` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). [File storage share and mount target](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui) in VPC will be created.. If yes, ensure 'nfs\_server\_config' optional variable is set properly below. Default value is '200GB' which will be mounted on specified directory in network-service vsi. | `bool` | `false` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the network-services vsi. | `bool` | `false` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS. | <pre>object({<br/>    dns_servers = string<br/>  })</pre> | <pre>{<br/>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;"<br/>}</pre> | no |
| <a name="input_enable_atracker"></a> [enable\_atracker](#input\_enable\_atracker) | Enable Activity Tracker. If true, Activity Tracker resources (KMS key, COS instance, bucket, and atracker configuration) will be created. | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance. If you already have an existing monitoring instance, set this to true and specify in optional parameter 'existing\_monitoring\_instance\_crn'. | `bool` | `false` | no |
| <a name="input_enable_monitoring_host"></a> [enable\_monitoring\_host](#input\_enable\_monitoring\_host) | Specify whether to create an additional Intel Instance that can be used to configure additional monitoring services. | `bool` | `false` | no |
| <a name="input_enable_scc_wp"></a> [enable\_scc\_wp](#input\_enable\_scc\_wp) | Set to true to enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all VSIs and PowerVS instances in this deployment. | `bool` | `false` | no |
| <a name="input_enable_vpc_flow_logs"></a> [enable\_vpc\_flow\_logs](#input\_enable\_vpc\_flow\_logs) | Enable VPC flow logs. If true, flow logs will be stored in the atracker bucket. | `bool` | `true` | no |
| <a name="input_existing_monitoring_instance_crn"></a> [existing\_monitoring\_instance\_crn](#input\_existing\_monitoring\_instance\_crn) | Existing CRN of IBM Cloud Monitoring Instance. If value is null, then an IBM Cloud Monitoring Instance will not be created but an intel VSI instance will be created if 'enable\_monitoring\_host' is true. | `string` | `null` | no |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | An existing Secrets Manager GUID. If not provided a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Required if value is passed into `var.existing_sm_instance_guid`. | `string` | `null` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn. | `string` | n/a | yes |
| <a name="input_network_services_vsi_profile"></a> [network\_services\_vsi\_profile](#input\_network\_services\_vsi\_profile) | Compute profile configuration of the network services vsi (cpu and memory configuration). Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui). | `string` | `"cxf-2x4"` | no |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount\_path' defines the target mount point on os. Set 'configure\_nfs\_server' to false to ignore creating file storage share. | <pre>object({<br/>    size       = number<br/>    iops       = number<br/>    mount_path = string<br/>  })</pre> | <pre>{<br/>  "iops": 600,<br/>  "mount_path": "/nfs",<br/>  "size": 200<br/>}</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. Must contain only lowercase letters, numbers, and - characters. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) to login to Intel VSIs to configure network management services (SQUID, NTP, DNS and ansible). Should match to public SSH key referenced by 'ssh\_public\_key'. The key is not uploaded or stored. If you're unsure how to create one, check [Generate a SSH Key Pair](https://cloud.ibm.com/docs/powervs-vpc?topic=powervs-vpc-powervs-automation-prereqs#powervs-automation-ssh-key) in our docs. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) in the VPC docs. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. If you're unsure how to create one, check [Generate a SSH Key Pair](https://cloud.ibm.com/docs/powervs-vpc?topic=powervs-vpc-powervs-automation-prereqs#powervs-automation-ssh-key) in our docs. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) in the VPC docs. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | `[]` | no |
| <a name="input_transit_gateway_global"></a> [transit\_gateway\_global](#input\_transit\_gateway\_global) | Connect to the networks outside the associated region. | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | cloud-init user data passed to all landing zone VSIs (jump-box, network-services, monitoring). Must be a valid cloud-config YAML string. For more information, see https://cloud.ibm.com/docs/vpc?topic=vpc-user-data. | `string` | n/a | yes |
| <a name="input_vpc_intel_images"></a> [vpc\_intel\_images](#input\_vpc\_intel\_images) | Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring). | <pre>object({<br/>    rhel_image = string<br/>    sles_image = string<br/>  })</pre> | n/a | yes |
| <a name="input_vpc_subnet_cidrs"></a> [vpc\_subnet\_cidrs](#input\_vpc\_subnet\_cidrs) | CIDR values for the VPC subnets to be created. It's customer responsibility that none of the defined networks collide, including the PowerVS subnets and VPN client pool. | <pre>object({<br/>    vpn  = string<br/>    mgmt = string<br/>    vpe  = string<br/>    edge = string<br/>  })</pre> | <pre>{<br/>  "edge": "10.30.40.0/24",<br/>  "mgmt": "10.30.20.0/24",<br/>  "vpe": "10.30.30.0/24",<br/>  "vpn": "10.30.10.0/24"<br/>}</pre> | no |
| <a name="input_vpc_zone"></a> [vpc\_zone](#input\_vpc\_zone) | VPC zone where resources will be created. Eg: eu-de-1, eu-es-3 | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host(jump/bastion) for created PowerVS infrastructure. |
| <a name="output_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#output\_ansible\_host\_or\_ip) | Central Ansible node private IP address. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for created PowerVS infrastructure. |
| <a name="output_kms_key_map"></a> [kms\_key\_map](#output\_kms\_key\_map) | Map of ids and keys for KMS keys created |
| <a name="output_monitoring_instance"></a> [monitoring\_instance](#output\_monitoring\_instance) | Details of the IBM Cloud Monitoring Instance: CRN, location, guid, monitoring\_host\_ip. monitoring\_host\_ip is an empty string if enable\_monitoring\_host is disabled. |
| <a name="output_network_services_config"></a> [network\_services\_config](#output\_network\_services\_config) | Complete configuration of network management services. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS host for created PowerVS infrastructure. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | NTP host for created PowerVS infrastructure. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix that is associated with all resources. |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host:port for created PowerVS infrastructure. |
| <a name="output_resource_group_data"></a> [resource\_group\_data](#output\_resource\_group\_data) | List of resource groups data used within landing zone. |
| <a name="output_scc_wp_instance"></a> [scc\_wp\_instance](#output\_scc\_wp\_instance) | Details of the Security and Compliance Center Workload Protection Instance: guid, access key, api\_endpoint, ingestion\_endpoint. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key used when deploying VPC. |
| <a name="output_transit_gateway_global"></a> [transit\_gateway\_global](#output\_transit\_gateway\_global) | Connect to the networks outside the associated region. |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | The ID of transit gateway. |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
| <a name="output_vpc_data"></a> [vpc\_data](#output\_vpc\_data) | List of VPC data. |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC. |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs. |
| <a name="output_vsi_ssh_key_data"></a> [vsi\_ssh\_key\_data](#output\_vsi\_ssh\_key\_data) | List of SSH key data |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
