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
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance and an Intel Monitoring Instance to host the services. | `bool` | n/a | yes |
| <a name="input_enable_scc_wp"></a> [enable\_scc\_wp](#input\_enable\_scc\_wp) | Set to true to enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all VSIs and PowerVS instances in this deployment. | `bool` | n/a | yes |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | An existing Secrets Manager GUID. If not provided a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Required if value is passed into `var.existing_sm_instance_guid`. | `string` | `null` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount\_path' defines the target mount point on os. Set 'configure\_nfs\_server' to false to ignore creating file storage share. | <pre>object({<br/>    size       = number<br/>    iops       = number<br/>    mount_path = string<br/>  })</pre> | <pre>{<br/>  "iops": 600,<br/>  "mount_path": "/nfs",<br/>  "size": 200<br/>}</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Must be an alphanumeric string with maximum length of 8 characters. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP network domain name. | `string` | `"sap.com"` | no |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key' which was created previously. The key is temporarily stored and deleted. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud resources created. | `list(string)` | `[]` | no |
| <a name="input_vpc_landing_zone_images"></a> [vpc\_landing\_zone\_images](#input\_vpc\_landing\_zone\_images) | Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring). | <pre>object({<br/>    rhel_image = string<br/>    sles_image = string<br/>  })</pre> | <pre>{<br/>  "rhel_image": "ibm-redhat-9-6-amd64-sap-applications-1",<br/>  "sles_image": "ibm-sles-15-7-amd64-sap-applications-1"<br/>}</pre> | no |
| <a name="input_vpc_subnet_cidrs"></a> [vpc\_subnet\_cidrs](#input\_vpc\_subnet\_cidrs) | CIDR values for the VPC subnets to be created. It's customer responsibility that none of the defined networks collide, including the PowerVS subnets and VPN client pool. | <pre>object({<br/>    vpn  = string<br/>    mgmt = string<br/>    vpe  = string<br/>    edge = string<br/>  })</pre> | <pre>{<br/>  "edge": "10.30.40.0/24",<br/>  "mgmt": "10.30.20.0/24",<br/>  "vpe": "10.30.30.0/24",<br/>  "vpn": "10.30.10.0/24"<br/>}</pre> | no |
| <a name="input_vpc_zone"></a> [vpc\_zone](#input\_vpc\_zone) | IBM Cloud data center location where VPC resources will be created. | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
