---
copyright:
  years: 2024, 2025, 2026
lastupdated: "2026-08-18"
keywords:
  - SAP
  - SAP HANA
  - SAP S/4HANA
  - SAP BW/4HANA
  - IBM Cloud VPC
  - deployable architecture
subcollection: deployable-reference-architectures
authors:
  - name: IBM Cloud
production: true
docs: https://cloud.ibm.com/docs/sap
image_source: https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/blob/main/reference-architectures/sap-s4hana-bw4hana/deploy-arch-ibm-vpc-sap-s4hana-bw4hana.svg
use-case: ITServiceManagement
industry: Technology
compliance: SAPCertified
content-type: reference-architecture
version: v1.0.0
related_links:
  - title: 'SAP in IBM Cloud documentation'
    url: 'https://cloud.ibm.com/docs/sap'
    description: 'SAP in IBM Cloud documentation.'
  - title: 'SAP HANA with SAP S/4HANA or SAP BW/4HANA on VPC'
    url: 'https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/tree/main/solutions/ibm-catalog/sap-s4hana-bw4hana'
    description: 'Terraform implementation of the SAP solution.'
---

{{site.data.keyword.attribute-definition-list}}

# SAP HANA with SAP S/4HANA or SAP BW/4HANA on IBM Cloud VPC
{: #sap-s4hana-bw4hana}
{: toc-content-type="reference-architecture"}
{: toc-industry="Technology"}
{: toc-use-case="ITServiceManagement"}
{: toc-compliance="SAPCertified"}
{: toc-version="v1.0.0"}

The SAP HANA with SAP S/4HANA or SAP BW/4HANA on IBM Cloud Virtual Private Cloud (VPC) deployable architecture creates a basic SAP landscape consisting of an SAP HANA database and an SAP NetWeaver application server.

The solution creates and configures the VPC infrastructure, network services, storage, operating systems, and SAP installation prerequisites. It supports automated installation of SAP S/4HANA and SAP BW/4HANA using installation media stored in IBM Cloud Object Storage.

The default deployment is designed for a single VPC zone. It does not provide native high availability or disaster recovery.

## Architecture diagram
{: #sap-s4hana-bw4hana-architecture-diagram}

![Architecture diagram for SAP HANA with SAP S/4HANA or SAP BW/4HANA on IBM Cloud VPC.](deploy-arch-ibm-vpc-sap-s4hana-bw4hana.svg "Architecture diagram"){: caption="Figure 1. SAP HANA with SAP S/4HANA or SAP BW/4HANA on IBM Cloud VPC" caption-side="bottom"}{: external download="deploy-arch-ibm-vpc-sap-s4hana-bw4hana.svg"}

## Design requirements
{: #sap-s4hana-bw4hana-design-requirements}

![Design requirements for SAP HANA with SAP S/4HANA or SAP BW/4HANA on IBM Cloud VPC.](heat-map-deploy-arch-ibm-vpc-sap-s4hana-bw4hana.svg "Design requirements"){: caption="Figure 2. Scope of the solution requirements" caption-side="bottom"}{: external download="heat-map-deploy-arch-ibm-vpc-sap-s4hana-bw4hana.svg"}

The reference architecture provides an automated foundation for deploying SAP workloads on IBM Cloud VPC. The architecture focuses on secure network isolation, centralized infrastructure services, SAP-certified compute profiles, automated operating system configuration, and SAP software installation.

## Components
{: #sap-s4hana-bw4hana-components}

### VPC architecture decisions
{: #sap-s4hana-bw4hana-vpc-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------|--------------------|
| Ensure public internet connectivity while isolating application workloads from direct public access | VPC landing zone and security groups | Use the VPC landing zone network and security group configuration | Create and maintain a custom VPC network and security group design |
| Provide controlled administrative access | Bastion or management VSI | Use a dedicated management VSI as the SSH entry point to the environment | Configure a customer-managed bastion host |
| Provide DNS and NTP services to all VPC instances | Network services VSI | Configure a central network services VSI as the DNS forwarder and NTP server | Use customer-managed DNS and NTP services |
| Provide a proxy for outbound network access | Network services VSI | Configure Squid on the network services VSI | Configure a separate proxy service or network load balancer |
| Provide shared storage for installation media and shared SAP directories | VPC file storage and NFS services | Configure an NFS server and mount the share on the SAP VSIs | Use an existing customer-managed NFS service |
| Provide private access to IBM Cloud services | VPC service endpoints and COS VPE | Use private connectivity to IBM Cloud Object Storage where configured | Use an approved customer-managed connectivity pattern |
| Provide network monitoring and audit information | Flow Logs and Activity Tracker | Enable VPC Flow Logs and Activity Tracker according to deployment parameters | Use existing enterprise monitoring and audit services |
| Support optional security monitoring | Security and Compliance Center Workload Protection | Optionally install and configure the Workload Protection agent on the created VSIs | Use an existing security monitoring platform |

{: caption="Table 1. VPC architecture decisions" caption-side="bottom"}

### SAP compute architecture decisions
{: #sap-s4hana-bw4hana-compute-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------|--------------------|
| Deploy an SAP HANA database server | SAP HANA VSI | Create one VPC VSI using a customer-selected SAP HANA-certified profile and image | Deploy SAP HANA on an existing customer-managed VSI |
| Deploy SAP application services | SAP NetWeaver VSI | Create one VPC VSI hosting the SAP NetWeaver PAS and ASCS instances | Deploy PAS and ASCS on separate customer-managed VSIs |
| Use SAP-certified operating systems | VPC operating system images | Use SAP HANA-certified and SAP Applications-certified RHEL or SLES images | Provide other supported SAP-certified images manually |
| Configure SAP HANA filesystems | Block volumes attached to the HANA VSI | Automatically calculate storage based on the selected HANA profile, or provide a custom storage layout | Attach and configure storage manually |
| Configure SAP application filesystems | Block volumes attached to the application VSI | Configure `/usr/sap`, `swap`, and `/sapmnt` using the solution defaults or custom values | Attach and configure storage manually |
| Connect SAP instances to infrastructure services | DNS, NTP, and NFS client configuration | Configure the SAP VSIs to use the central DNS, NTP, and NFS services | Configure infrastructure services manually |
| Install SAP software | Ansible and SAP installation automation | Download installation media from COS and execute SAP HANA and SAP solution installation automation | Install SAP software manually |

{: caption="Table 2. SAP compute and storage architecture decisions" caption-side="bottom"}

### SAP solution architecture decisions
{: #sap-s4hana-bw4hana-sap-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------|--------------------|
| Support SAP S/4HANA | SAP S/4HANA | Support SAP S/4HANA 2020, 2021, 2022, and 2023 according to the selected input | Install another SAP release manually |
| Support SAP BW/4HANA | SAP BW/4HANA | Support SAP BW/4HANA 2021 according to the selected input | Install another SAP release manually |
| Store installation media | IBM Cloud Object Storage | Use an existing COS bucket containing the required HANA and SAP solution media | Upload and manage the installation media manually |
| Retrieve installation media securely | COS service credentials | Accept COS service credentials as a sensitive deployment input | Use an alternative approved credential-management workflow |
| Configure SAP system identity | SAP HANA and SAP solution variables | Allow the customer to specify SAP SIDs and instance numbers | Configure the SAP system identity manually after deployment |

{: caption="Table 3. SAP solution architecture decisions" caption-side="bottom"}

### Security and credentials architecture decisions
{: #sap-s4hana-bw4hana-security-components}

| Requirement | Component | Choice | Alternative choice |
|-------------|-----------|--------|--------------------|
| Access VPC instances securely | RSA SSH key pair | Require an RSA public and private key pair for instance access | Use an approved enterprise SSH access solution |
| Restrict administrative network access | External access IP or CIDR | Allow SSH access only from the specified external IP address or CIDR range | Use a customer-managed VPN or private access path |
| Protect deployment credentials | Sensitive Terraform variables | Mark API keys, private SSH keys, COS credentials, SAP passwords, and Ansible Vault passwords as sensitive inputs | Use an approved secrets-management integration |
| Protect generated automation files | Ansible Vault | Encrypt generated SAP installation variables and playbooks with the supplied Ansible Vault password | Encrypt and manage the files using an enterprise secrets platform |
| Protect IBM Cloud service access | IAM and service credentials | Use IBM Cloud API credentials with the minimum permissions required by the deployment | Use an enterprise IAM delegation model |

{: caption="Table 4. Security and credentials architecture decisions" caption-side="bottom"}

## Deployment scope
{: #sap-s4hana-bw4hana-deployment-scope}

The solution creates and configures:

- A VPC landing zone.
- A management or bastion VSI.
- A network services VSI that provides DNS, NTP, Squid, NFS, and central Ansible execution.
- One SAP HANA database VSI.
- One SAP NetWeaver application VSI hosting PAS and ASCS.
- Block storage volumes for SAP HANA and SAP application filesystems.
- NFS storage for shared files and installation media.
- IBM Cloud Object Storage integration for downloading installation media.
- Optional IBM Cloud Monitoring resources.
- Optional Security and Compliance Center Workload Protection.
- Optional client-to-site VPN resources.
- Optional Activity Tracker and VPC Flow Logs.
- Optional Secrets Manager resources.
- KMS resources used by the landing zone services.

## Supported SAP solutions
{: #sap-s4hana-bw4hana-supported-solutions}

The supported `sap_solution` values are:

- `s4hana-2023`
- `s4hana-2022`
- `s4hana-2021`
- `s4hana-2020`
- `bw4hana-2021`

The required installation media must be uploaded to the configured IBM Cloud Object Storage bucket before deployment.

Refer to [`s4hana23_bw4hana21_binaries.md`](../../solutions/ibm-catalog/sap-s4hana-bw4hana/docs/s4hana23_bw4hana21_binaries.md) for the expected installation media layout.

## Storage configuration
{: #sap-s4hana-bw4hana-storage}

### SAP HANA VSI

The default HANA storage layout is calculated from the selected SAP HANA profile:

```text
/hana/data     Automatically calculated from the selected memory size
/hana/log      512 GB default
/hana/shared   200 GB default
swap           32 GB default
/usr/sap       50 GB default additional volume
```

Custom HANA storage supports custom volume sizes, multiple volumes for striping, IBM Cloud volume profiles such as `3iops-tier`, `5iops-tier`, and `10iops-tier`, and custom mount points.

### SAP NetWeaver VSI

The default SAP application storage layout is:

```text
/usr/sap       50 GB
swap           30 GB
/sapmnt        50 GB
```

The SAP application storage configuration can be replaced with custom volume definitions.

## Network services
{: #sap-s4hana-bw4hana-network-services}

The deployment configures:

- DNS forwarding through the network services VSI.
- NTP through the network services VSI.
- NFS server storage for shared files and installation media.
- NFS client mounts on the SAP HANA and SAP NetWeaver VSIs.
- Squid proxy services on the network services VSI.
- SSH access through the management or bastion VSI.

The SAP VSIs use the network services VSI for DNS and NTP. The NFS share is mounted using NFS version 4.1 with `sec=sys` and `nofail` options.

## Prerequisites
{: #sap-s4hana-bw4hana-prerequisites}

Before deploying the solution, prepare:

1. An IBM Cloud account with sufficient permissions to create the required VPC, IAM, storage, monitoring, and security resources.
2. An existing IBM Cloud Object Storage bucket containing SAP HANA and SAP S/4HANA or SAP BW/4HANA installation media.
3. COS service credentials containing `apikey` and `resource_instance_id`.
4. An RSA SSH key pair with a key size of 2048 or 4096 bits.
5. An external IP address or CIDR range from which SSH access is permitted.
6. SAP installation passwords that meet the validation requirements.
7. A supported SAP HANA-certified VPC profile.
8. A supported SAP-certified RHEL or SLES operating system image.

Do not store private keys, API keys, COS credentials, or passwords in source control.

## Operational considerations
{: #sap-s4hana-bw4hana-operational-considerations}

- The default architecture deploys resources in a single VPC zone.
- The default architecture does not provide native high availability.
- The default architecture does not provide native disaster recovery.
- SAP-certified profiles and operating system images must be selected for the intended workload.
- Storage requirements should be reviewed against the planned SAP workload and database size.
- The COS bucket must contain the required installation files before deployment starts.
- Network CIDR ranges must not overlap with each other, the VPN client pool, or connected networks.
- Customer-specific backup, high availability, disaster recovery, and monitoring requirements must be implemented separately where required.

## Post-deployment information
{: #sap-s4hana-bw4hana-post-deployment}

After deployment:

1. Installation logs and generated Ansible files are stored under `/root/terraform_files/`.
2. The SAP HANA installation playbook is stored on the HANA VSI.
3. SAP Software Provisioning Manager installation variables are stored on the SAP NetWeaver VSI.
4. Generated sensitive playbooks are encrypted with the configured Ansible Vault password.
5. Deployment outputs provide the access host, network services host, SAP HANA VSI, SAP application VSI, storage, and SAP system details.

Private SSH keys and other sensitive values must be handled through an approved secure storage mechanism and must not be written to source control or shared through logs.

## Compliance
{: #sap-s4hana-bw4hana-compliance}

This deployable architecture is designed for SAP deployments on IBM Cloud VPC. SAP certification and support requirements must be reviewed for the selected SAP release, operating system image, VPC profile, and workload configuration.

## Next steps
{: #sap-s4hana-bw4hana-next-steps}

After the infrastructure deployment completes:

1. Verify the deployment outputs.
2. Connect to the environment through the management or bastion VSI.
3. Review the installation logs under `/root/terraform_files/`.
4. Confirm that SAP HANA and SAP NetWeaver installation automation completed successfully.
5. Complete customer-specific SAP configuration.
6. Configure operational backup, monitoring, high availability, and disaster recovery procedures as required.
