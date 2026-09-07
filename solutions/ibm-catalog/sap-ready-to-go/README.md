# IBM Cloud Catalog - SAP Ready on VPC

# Summary

## Summary Outcome:
   Deploys a secure VPC landing zone with SAP HANA DB and SAP NetWeaver (Application) Virtual Server Instances (VSIs), configures OS and storage prerequisites, and tunes the instances to be ready for SAP software installation. **Does not install SAP software.**

## Summary Tasks

- A **VPC Infrastructure** with the following components:
    - One VSI for management (jump/bastion)
    - One VSI for network-services configured as Squid proxy, NTP, and DNS servers (using Ansible Galaxy collection roles [ibm.power_linux_sap](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/)). This VSI also acts as the central Ansible execution node.
    - Optional VSI for Monitoring host
    - Optional [Client-to-Site VPN server](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
    - [File storage share (NFS)](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui) for SAP shared directories
    - Optional [IBM Cloud Security and Compliance Center Workload Protection](https://cloud.ibm.com/docs/workload-protection) (Sysdig agent configured on all VSIs)
    - IBM Cloud Object Storage (COS) Virtual Private Endpoint gateway (VPE)
    - IBM Cloud Object Storage (COS) instance and buckets (for Activity Tracker)
    - VPC Flow Logs
    - Key Management Service (KMS) keys
    - IBM Cloud Activity Tracker
    - Optional Secrets Manager instance with private certificates
    - Optional IBM Cloud Monitoring instance

- **SAP Compute & Storage:**
    - Creates and configures one VPC VSI for SAP HANA DB based on certified profiles and best practices.
    - Creates and configures one VPC VSI for SAP NetWeaver based on SAP best practices.
    - Automatically calculates and configures HANA filesystems (`/hana/shared`, `/hana/data`, `/hana/log`, `/usr/sap`, `swap`) based on the instance memory profile, with support for custom storage layouts.
    - Connects all VPC instances to the central NTP server and DNS forwarder.
    - Mounts the shared NFS directory on all created VPC instances.
    - Tunes OS settings on HANA and NetWeaver VSIs for SAP workloads using [RHEL System Roles](https://access.redhat.com/articles/4488731): `sap_general_preconfigure`, `sap_hana_preconfigure`, `sap_netweaver_preconfigure`.


## Notes
- **Does not install any SAP software or solutions.**
- Filesystem sizes for HANA data and log volumes are **calculated automatically** based on the chosen instance profile memory size.
- Custom storage configuration is supported by specifying volume sizes, profiles/tiers (`3iops-tier`, `5iops-tier`, `10iops-tier`), volume counts, and mount points.


|                                  Variation                                  | Available on IBM Catalog | Creates VPC Landing Zone | Creates VPC HANA Instance | Creates VPC NW Instance | Performs VPC OS Config | Performs VPC SAP Tuning | Install SAP software |
|:---------------------------------------------------------------------------:|:------------------------:|:------------------------:|:-------------------------:|:-----------------------:|:----------------------:|:-----------------------:|:--------------------:|
| [IBM Catalog sap-ready-to-go](./) | :heavy_check_mark: | :heavy_check_mark: | 1 | 1 | :heavy_check_mark: | :heavy_check_mark: | N/A |

![sap-ready-to-go](https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/blob/main/reference-architectures/sap-ready-to-go/deploy-arch-ibm-vpc-sap-ready-to-go.svg)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 2.4.0 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | 2.0.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_server"></a> [app\_server](#module\_app\_server) | ../../../modules/vsi | n/a |
| <a name="module_configure_os_app_server"></a> [configure\_os\_app\_server](#module\_configure\_os\_app\_server) | ../../../modules/ansible | n/a |
| <a name="module_configure_os_hana_db"></a> [configure\_os\_hana\_db](#module\_configure\_os\_hana\_db) | ../../../modules/ansible | n/a |
| <a name="module_hana_db"></a> [hana\_db](#module\_hana\_db) | ../../../modules/vsi | n/a |
| <a name="module_linux_init_app_server"></a> [linux\_init\_app\_server](#module\_linux\_init\_app\_server) | ../../../modules/vpc-landing-zone/submodules/ansible | n/a |
| <a name="module_linux_init_hana_db"></a> [linux\_init\_hana\_db](#module\_linux\_init\_hana\_db) | ../../../modules/vpc-landing-zone/submodules/ansible | n/a |
| <a name="module_standard"></a> [standard](#module\_standard) | ../../../modules/vpc-landing-zone | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_auth_token.auth_token](https://registry.terraform.io/providers/IBM-Cloud/ibm/2.4.0/docs/data-sources/iam_auth_token) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible playbooks that contain sensitive information. Required when SCC workload Protection is enabled. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | n/a | yes |
| <a name="input_client_to_site_vpn"></a> [client\_to\_site\_vpn](#input\_client\_to\_site\_vpn) | VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance. | <pre>object({<br/>    enable                        = bool<br/>    client_ip_pool                = string<br/>    vpn_client_access_group_users = list(string)<br/>  })</pre> | <pre>{<br/>  "client_ip_pool": "192.168.0.0/16",<br/>  "enable": true,<br/>  "vpn_client_access_group_users": []<br/>}</pre> | no |
| <a name="input_enable_atracker"></a> [enable\_atracker](#input\_enable\_atracker) | Enable Activity Tracker. If true, Activity Tracker resources (KMS key, COS instance, bucket, and atracker configuration) will be created. | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance and an Intel Monitoring Instance to host the services. | `bool` | n/a | yes |
| <a name="input_enable_scc_wp"></a> [enable\_scc\_wp](#input\_enable\_scc\_wp) | Set to true to enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all VSIs in this deployment. | `bool` | n/a | yes |
| <a name="input_enable_vpc_flow_logs"></a> [enable\_vpc\_flow\_logs](#input\_enable\_vpc\_flow\_logs) | Enable VPC flow logs. If true, flow logs will be stored in the atracker bucket. | `bool` | `true` | no |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | An existing Secrets Manager GUID. If not provided a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Required if value is passed into `var.existing_sm_instance_guid`. | `string` | `null` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount\_path' defines the target mount point on os. | <pre>object({<br/>    size       = number<br/>    iops       = number<br/>    mount_path = string<br/>  })</pre> | <pre>{<br/>  "iops": 600,<br/>  "mount_path": "/nfs",<br/>  "size": 200<br/>}</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Must be an lowercase alphanumeric characters and hyphens with maximum length of 7 characters. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP domain name used across HANA and NetWeaver configurations. | `string` | `"sap.com"` | no |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM VPC instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key' which was created previously. The key is temporarily stored and deleted. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud resources created. | `list(string)` | `[]` | no |
| <a name="input_vpc_app_instance_image"></a> [vpc\_app\_instance\_image](#input\_vpc\_app\_instance\_image) | OS image name for the SAP Application VSI. Must be an SAP Applications certified RHEL or SLES image. | `string` | `"ibm-redhat-9-6-amd64-sap-applications-10"` | no |
| <a name="input_vpc_app_instance_profile_id"></a> [vpc\_app\_instance\_profile\_id](#input\_vpc\_app\_instance\_profile\_id) | VPC instance profile for the SAP Application VSI. | `string` | `"bx2-4x16"` | no |
| <a name="input_vpc_app_instance_storage_config"></a> [vpc\_app\_instance\_storage\_config](#input\_vpc\_app\_instance\_storage\_config) | storage for the APP VSI. Replaces the default layout. Leave as default (empty name) to use the default layout [50 GB /usr/sap, 50 GB /sapmnt]. Each entry defines one block volume: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    iops  = string<br/>    mount = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "1",<br/>    "iops": "10iops-tier",<br/>    "mount": "/usr/sap",<br/>    "name": "usr-sap",<br/>    "size": "50"<br/>  },<br/>  {<br/>    "count": "1",<br/>    "iops": "10iops-tier",<br/>    "mount": "swap",<br/>    "name": "swap",<br/>    "size": "30"<br/>  },<br/>  {<br/>    "count": "1",<br/>    "iops": "10iops-tier",<br/>    "mount": "/sapmnt",<br/>    "name": "sap-mnt",<br/>    "size": "50"<br/>  }<br/>]</pre> | no |
| <a name="input_vpc_hana_instance_additional_storage_config"></a> [vpc\_hana\_instance\_additional\_storage\_config](#input\_vpc\_hana\_instance\_additional\_storage\_config) | Additional block volumes to attach to the HANA DB VSI, appended after the custom or auto-calculated volumes. Useful for extra file systems such as backup or archive mounts. Leave as default to attach no additional volumes. Each entry: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    iops  = string<br/>    mount = string<br/>    pool  = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "1",<br/>    "iops": "10iops-tier",<br/>    "mount": "/usr/sap",<br/>    "name": "usr-sap",<br/>    "size": "50"<br/>  }<br/>]</pre> | no |
| <a name="input_vpc_hana_instance_custom_storage_config"></a> [vpc\_hana\_instance\_custom\_storage\_config](#input\_vpc\_hana\_instance\_custom\_storage\_config) | Custom storage for the HANA DB VSI. Replaces the entire auto-calculated layout. Leave as default (empty name) to use auto-calculated volumes for hana/data, hana/log, hana/shared, and swap from the profile memory. Each entry defines one block volume: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    iops  = string<br/>    mount = string<br/>    pool  = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "",<br/>    "iops": "",<br/>    "mount": "",<br/>    "name": "",<br/>    "size": ""<br/>  }<br/>]</pre> | no |
| <a name="input_vpc_hana_instance_image"></a> [vpc\_hana\_instance\_image](#input\_vpc\_hana\_instance\_image) | OS image name for the SAP HANA DB VSI. Must be an SAP HANA certified RHEL or SLES image. | `string` | `"ibm-redhat-9-6-amd64-sap-hana-10"` | no |
| <a name="input_vpc_hana_instance_sap_profile_id"></a> [vpc\_hana\_instance\_sap\_profile\_id](#input\_vpc\_hana\_instance\_sap\_profile\_id) | VPC instance profile for the VPC SAP HANA instance. Must be a HANA-certified mx2, vx2d, or ux2d profile. The memory encoded in the profile name (e.g. mx2-16x128 → 128 GB) is used to auto-calculate volume sizes. | `string` | `"mx2-16x128"` | no |
| <a name="input_vpc_landing_zone_images"></a> [vpc\_landing\_zone\_images](#input\_vpc\_landing\_zone\_images) | Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring). | <pre>object({<br/>    rhel_image = string<br/>    sles_image = string<br/>  })</pre> | <pre>{<br/>  "rhel_image": "ibm-redhat-9-6-amd64-sap-applications-10",<br/>  "sles_image": "ibm-sles-15-7-amd64-sap-applications-1"<br/>}</pre> | no |
| <a name="input_vpc_subnet_cidrs"></a> [vpc\_subnet\_cidrs](#input\_vpc\_subnet\_cidrs) | CIDR values for the VPC subnets to be created. It's customer responsibility that none of the defined networks collide, including VPN client pool. | <pre>object({<br/>    vpn  = string<br/>    mgmt = string<br/>    vpe  = string<br/>    edge = string<br/>  })</pre> | <pre>{<br/>  "edge": "10.30.40.0/24",<br/>  "mgmt": "10.30.20.0/24",<br/>  "vpe": "10.30.30.0/24",<br/>  "vpn": "10.30.10.0/24"<br/>}</pre> | no |
| <a name="input_vpc_zone"></a> [vpc\_zone](#input\_vpc\_zone) | IBM Cloud VPC Zone location where VPC resources will be created. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of the bastion/jump host. |
| <a name="output_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#output\_ansible\_host\_or\_ip) | Private IP of the network-services VSI (Ansible/NTP/DNS host). |
| <a name="output_app_instance"></a> [app\_instance](#output\_app\_instance) | SAP Application (NetWeaver) VSI details: id, name, zone, and primary private IP. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | Private IP of the DNS forwarder. |
| <a name="output_hana_db_instance"></a> [hana\_db\_instance](#output\_hana\_db\_instance) | SAP HANA DB VSI details: id, name, zone, and primary private IP. |
| <a name="output_infrastructure_data"></a> [infrastructure\_data](#output\_infrastructure\_data) | VPC landing zone infrastructure details. |
| <a name="output_monitoring_instance"></a> [monitoring\_instance](#output\_monitoring\_instance) | IBM Cloud Monitoring instance details. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS server host and mount path. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | Private IP of the NTP forwarder. |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Squid proxy host:port. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
