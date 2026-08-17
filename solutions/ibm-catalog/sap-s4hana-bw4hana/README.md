# IBM Cloud Catalog - Power Virtual Server for SAP HANA : 'SAP S/4HANA or SAP BW/4HANA'

# Summary

## Summary Outcome:
   SAP S/4HANA or SAP BW/4HANA installation configuration to IBM VPC hosts.

|                                  Variation                                  | Available on IBM Catalog | Requires Schematics Workspace ID | Creates VPC with VPC landing zone | Creates VPC HANA Instance | Creates VPC NW Instances | Performs VPC OS Config | Performs VPC SAP Tuning | Install SAP software |
|:---------------------------------------------------------------------------:|:------------------------:|:--------------------------------:|:-------------------------------------:|:-----------------------------:|:----------------------------:|:--------------------------:|:---------------------------:|:--------------------:|
| [IBM catalog SAP S/4HANA or BW/4HANA variation]( ./) |    :heavy_check_mark:    |        :heavy_check_mark:        |        :heavy_check_mark:        |               1               |            1            |     :heavy_check_mark:     |      :heavy_check_mark:     |          :heavy_check_mark:         |

## Architecture Diagram
![sap-s4hana-bw4hana](https://github.com/terraform-ibm-modules/terraform-ibm-VPC-sap/blob/main/reference-architectures/sap-s4hana-bw4hana/deploy-arch-ibm-pvs-sap-s4hana-bw4hana.svg)

## Overview
1. [Summary Tasks](#summary-tasks)
2. [Before you begin](#before-you-begin)
3. [Notes](#notes)
4. [Post Deployment](#post-deployment)
5. [Storage setup](#storage-setup)
6. [Ansible roles used](#ansible-roles-used)

- With the following components:
- One VSI for management (jump/bastion)
- One VSI for network-services configured as squid proxy, NTP and DNS servers(using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). This VSI also acts as central ansible execution node.
- Optional VSI for Monitoring host
- Optional [Client to site VPN server](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
- Optional [File storage share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui)
- Optional [Network load balancer](https://cloud.ibm.com/docs/vpc?group=network-load-balancer)
- Optional [IBM Cloud Security and Compliance Center Workload Protection](https://cloud.ibm.com/docs/workload-protection) and SCC Workload Protection agent configuration on the VSIs in the deployment
- IBM Cloud Object storage(COS) Virtual Private endpoint gateway(VPE)
- IBM Cloud Object storage(COS) Instance and buckets
- VPC flow logs
- KMS keys
- Activity tracker
- Optional Secrets Manager Instance Instance with private certificate.
- An optional IBM Cloud Monitoring Instance
- Creates and configures one VPC instance for SAP HANA based on best practices for HANA database.
- Creates and configures one VPC instance for SAP NetWeaver based on best practices, hosting the PAS and ASCS instances.
- Connects all created VPC instances to an NTP server and DNS forwarder specified by IP address or hostname.
- Configures a shared NFS directory on all created VPC instances.
- Optionally configures the monitoring host to collect relevant information from the Database and application servers and send it to the IBM Cloud® Monitoring Instance
- Optionally installs Sysdig agent and configures connection to [IBM Cloud Security and Compliance Center Workload Protection](https://cloud.ibm.com/docs/workload-protection)
- Supports installation of **S/4HANA2023, S/4HANA2022, S/4HANA2021, S/4HANA2020, BW/4HANA2021**.
- Supports installation using **Maintenance Planner** as well.
- Optionally installs and configures SAP Monitoring host and dashboard, if monitoring instance was deployed as part of [Power Virtual Server with VPC landing zone deployment](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?catalog_query=aHR0cHM6Ly9jbG91ZC5pYm0uY29tL2NhdGFsb2c%2Fc2VhcmNoPXBvd2VyI3NlYXJjaF9yZXN1bHRz).


## Before you begin
1. **It is required to have an existing IBM Cloud Object Storage (COS) instance**. Within the instance, an Object Storage Bucket containing the **SAP Software installation media files is required in the correct folder structure as defined** [here](#2-sap-binaries-required-for-installation-and-folder-structure-in-ibm-cloud-object-storage-bucket).


## Notes
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**.
- Custom storage configuration by providing custom volume size, **iops**(tier0, tier1, tier3, tier5k), counts and mount points is supported.



## Post Deployment
1. All the installation logs and Ansible playbook files will be under the directory `/root/terraform_files/`.
2. The **ansible vault password** will be used to encrypt the Ansible playbook file created during deployment. This playbook file will be placed under `/root/terraform_files/sap-hana-install.yml` on the **HANA instance** and `/root/terraform_files/sap-swpm-install-vars.yml` on the **NetWeaver Instance**.
3. This file can be decrypted using the same value passed to variable **'ansible_vault_password'** during deployment. Use the command `ansible-vault decrypt /root/terraform_files/sap-swpm-install-vars.yml` and enter the password when prompted.

## Storage setup

### 1. HANA Instance:
**Default values:**
```
/hana/shared (size auto calculated based on memory)
/hana/data   (size auto calculated based on memory)
/hana/log    (size auto calculated based on memory)
/usr/sap     50GB
```

*Note: Supports custom storage configuration using provided optional variables.*

### 2. Netweaver Instance:
**Default values:**
```
/usr/sap 50GB
/sapmnt  300GB
```

*Note: Supports custom storage configuration using provided optional variables.*


## Ansible roles used
1. **[RHEL System Roles](https://access.redhat.com/articles/4488731):** `sap_hana_install, sap_swpm, sap_general_preconfigure, sap_hana_preconfigure, sap_netweaver_preconfigure`
2. **[IBM Role](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/):** `power_linux_sap`


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
| <a name="module_app"></a> [app](#module\_app) | ../../../modules/vsi | n/a |
| <a name="module_hana_db"></a> [hana\_db](#module\_hana\_db) | ../../../modules/vsi | n/a |
| <a name="module_ibmcloud_cos_download_hana_binaries"></a> [ibmcloud\_cos\_download\_hana\_binaries](#module\_ibmcloud\_cos\_download\_hana\_binaries) | ../../../modules/ibmcloud-cos | n/a |
| <a name="module_ibmcloud_cos_download_solution_binaries"></a> [ibmcloud\_cos\_download\_solution\_binaries](#module\_ibmcloud\_cos\_download\_solution\_binaries) | ../../../modules/ibmcloud-cos | n/a |
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
| <a name="input_enable_scc_wp"></a> [enable\_scc\_wp](#input\_enable\_scc\_wp) | Set to true to enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all VSIs and PowerVS instances in this deployment. | `bool` | n/a | yes |
| <a name="input_enable_vpc_flow_logs"></a> [enable\_vpc\_flow\_logs](#input\_enable\_vpc\_flow\_logs) | Enable VPC flow logs. If true, flow logs will be stored in the atracker bucket. | `bool` | `true` | no |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | An existing Secrets Manager GUID. If not provided a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Required if value is passed into `var.existing_sm_instance_guid`. | `string` | `null` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_ibmcloud_cos_configuration"></a> [ibmcloud\_cos\_configuration](#input\_ibmcloud\_cos\_configuration) | IBM Cloud Object Storage bucket containing SAP installation binaries. 'cos\_hana\_software\_path' must contain only HANA DB binaries. 'cos\_solution\_software\_path' must contain only S/4HANA or BW/4HANA binaries (no IMDB files). Avoid a leading '/' in path values. Files are downloaded to the NFS share mount path. | <pre>object({<br/>    cos_region                 = string<br/>    cos_bucket_name            = string<br/>    cos_hana_software_path     = string<br/>    cos_solution_software_path = string<br/>  })</pre> | <pre>{<br/>  "cos_bucket_name": "sap-binaries",<br/>  "cos_hana_software_path": "HANA_DB",<br/>  "cos_region": "eu-geo",<br/>  "cos_solution_software_path": "S4HANA_2023"<br/>}</pre> | no |
| <a name="input_ibmcloud_cos_service_credentials"></a> [ibmcloud\_cos\_service\_credentials](#input\_ibmcloud\_cos\_service\_credentials) | Service credentials for the IBM Cloud Object Storage instance, as a JSON string. Must contain 'apikey' and 'resource\_instance\_id'. See https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials. | `string` | n/a | yes |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount\_path' defines the target mount point on os. Set 'configure\_nfs\_server' to false to ignore creating file storage share. | <pre>object({<br/>    size       = number<br/>    iops       = number<br/>    mount_path = string<br/>  })</pre> | <pre>{<br/>  "iops": 600,<br/>  "mount_path": "/nfs",<br/>  "size": 200<br/>}</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Must be an alphanumeric string with maximum length of 8 characters. | `string` | n/a | yes |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key' which was created previously. The key is temporarily stored and deleted. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud resources created. | `list(string)` | `[]` | no |
| <a name="input_vpc_landing_zone_images"></a> [vpc\_landing\_zone\_images](#input\_vpc\_landing\_zone\_images) | Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring). | <pre>object({<br/>    rhel_image = string<br/>    sles_image = string<br/>  })</pre> | <pre>{<br/>  "rhel_image": "ibm-redhat-9-6-amd64-sap-applications-1",<br/>  "sles_image": "ibm-sles-15-7-amd64-sap-applications-1"<br/>}</pre> | no |
| <a name="input_vpc_subnet_cidrs"></a> [vpc\_subnet\_cidrs](#input\_vpc\_subnet\_cidrs) | CIDR values for the VPC subnets to be created. It's customer responsibility that none of the defined networks collide, including the PowerVS subnets and VPN client pool. | <pre>object({<br/>    vpn  = string<br/>    mgmt = string<br/>    vpe  = string<br/>    edge = string<br/>  })</pre> | <pre>{<br/>  "edge": "10.30.40.0/24",<br/>  "mgmt": "10.30.20.0/24",<br/>  "vpe": "10.30.30.0/24",<br/>  "vpn": "10.30.10.0/24"<br/>}</pre> | no |
| <a name="input_vpc_zone"></a> [vpc\_zone](#input\_vpc\_zone) | IBM Cloud data center location where VPC resources will be created. | `string` | n/a | yes |
| <a name="input_vsi_app_additional_storage_config"></a> [vsi\_app\_additional\_storage\_config](#input\_vsi\_app\_additional\_storage\_config) | Additional block volumes to attach to the APP VSI, appended after the custom or default volumes. Leave as default (empty name) to attach no additional volumes. Each entry: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    iops  = string<br/>    mount = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "",<br/>    "iops": "",<br/>    "mount": "",<br/>    "name": "",<br/>    "size": ""<br/>  }<br/>]</pre> | no |
| <a name="input_vsi_app_image"></a> [vsi\_app\_image](#input\_vsi\_app\_image) | OS image name for the SAP Application VSI. Must be an SAP Applications certified RHEL or SLES image. | `string` | `"ibm-redhat-9-6-amd64-sap-applications-10"` | no |
| <a name="input_vsi_app_profile"></a> [vsi\_app\_profile](#input\_vsi\_app\_profile) | VPC instance profile for the SAP Application VSI. | `string` | `"bx2-4x16"` | no |
| <a name="input_vsi_app_storage_config"></a> [vsi\_app\_storage\_config](#input\_vsi\_app\_storage\_config) | Custom storage for the APP VSI. Replaces the default layout. Leave as default (empty name) to use the default layout [128 GB /usr/sap, 10 GB swap]. Each entry defines one block volume: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    iops  = string<br/>    mount = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "",<br/>    "iops": "",<br/>    "mount": "",<br/>    "name": "",<br/>    "size": ""<br/>  }<br/>]</pre> | no |
| <a name="input_vsi_hana_db_additional_storage_config"></a> [vsi\_hana\_db\_additional\_storage\_config](#input\_vsi\_hana\_db\_additional\_storage\_config) | Additional block volumes to attach to the HANA DB VSI, appended after the custom or auto-calculated volumes. Useful for extra file systems such as backup or archive mounts. Leave as default (empty name) to attach no additional volumes. Each entry: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    iops  = string<br/>    mount = string<br/>    pool  = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "",<br/>    "iops": "",<br/>    "mount": "",<br/>    "name": "",<br/>    "size": ""<br/>  }<br/>]</pre> | no |
| <a name="input_vsi_hana_db_image"></a> [vsi\_hana\_db\_image](#input\_vsi\_hana\_db\_image) | OS image name for the SAP HANA DB VSI. Must be an SAP HANA certified RHEL or SLES image. | `string` | `"ibm-redhat-9-6-amd64-sap-hana-10"` | no |
| <a name="input_vsi_hana_db_profile"></a> [vsi\_hana\_db\_profile](#input\_vsi\_hana\_db\_profile) | VPC instance profile for the SAP HANA DB VSI. Must be a HANA-certified mx2, vx2d, or ux2d profile. The memory encoded in the profile name (e.g. mx2-16x128 → 128 GB) is used to auto-calculate volume sizes. | `string` | `"mx2-16x128"` | no |
| <a name="input_vsi_hana_db_storage_config"></a> [vsi\_hana\_db\_storage\_config](#input\_vsi\_hana\_db\_storage\_config) | Custom storage for the HANA DB VSI. Replaces the entire auto-calculated layout. Leave as default (empty name) to use auto-calculated volumes for hana/data, hana/log, hana/shared, usr/sap and swap from the profile memory. Each entry defines one block volume: 'name' is a label, 'size' is in GB, 'count' is the number of volumes to stripe, 'iops' is the IBM Cloud volume profile (3iops-tier/5iops-tier/10iops-tier), 'mount' is the target mount point on the OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    iops  = string<br/>    mount = string<br/>    pool  = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "",<br/>    "iops": "",<br/>    "mount": "",<br/>    "name": "",<br/>    "size": ""<br/>  }<br/>]</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of the bastion/jump host. |
| <a name="output_ansible_host_or_ip"></a> [ansible\_host\_or\_ip](#output\_ansible\_host\_or\_ip) | Private IP of the network-services VSI (Ansible/NTP/DNS host). |
| <a name="output_app_instance"></a> [app\_instance](#output\_app\_instance) | SAP Application (NetWeaver) VSI details: id, name, zone, and primary private IP. |
| <a name="output_app_volumes"></a> [app\_volumes](#output\_app\_volumes) | Block volumes attached to the SAP Application VSI. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | Private IP of the DNS forwarder. |
| <a name="output_hana_db_instance"></a> [hana\_db\_instance](#output\_hana\_db\_instance) | SAP HANA DB VSI details: id, name, zone, and primary private IP. |
| <a name="output_hana_db_volumes"></a> [hana\_db\_volumes](#output\_hana\_db\_volumes) | Block volumes attached to the SAP HANA DB VSI. |
| <a name="output_infrastructure_data"></a> [infrastructure\_data](#output\_infrastructure\_data) | VPC landing zone infrastructure details. |
| <a name="output_monitoring_instance"></a> [monitoring\_instance](#output\_monitoring\_instance) | IBM Cloud Monitoring instance details. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS server host and mount path. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | Private IP of the NTP forwarder. |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Squid proxy host:port. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
