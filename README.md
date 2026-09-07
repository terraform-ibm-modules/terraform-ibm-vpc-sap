# IBM Cloud VPC SAP deployable architectures
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-vpc-sap?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/terraform-ibm-modules/vpc-sap/ibm/latest)

## Summary
This repository provides Terraform deployable architectures and modules for automating the end-to-end deployment of SAP landscapes on **IBM Cloud Virtual Private Cloud (VPC)**. It deploys a secure VPC landing zone, provisions SAP HANA DB and SAP NetWeaver (Application) Virtual Server Instances (VSIs), configures storage and OS prerequisites, downloads installation media from IBM Cloud Object Storage (COS), and automates full SAP software provisioning (such as SAP S/4HANA or SAP BW/4HANA) using Ansible.

### Solutions

1. [IBM catalog VPC SAP Ready](./solutions/ibm-catalog/sap-ready-to-go)
    - Creates a VPC landing zone with management (jump/bastion) and network-services VSIs, and configures OS network management services (Squid proxy, NTP, NFS, and DNS) using Ansible Galaxy collection roles from the [ibm.power_linux_sap](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) collection.
    - Creates and configures **one HANA DB VSI and one NetWeaver VSI** with **RHEL** OS distribution.
    - Automatically calculates and configures HANA filesystems (`/hana/shared`, `/hana/data`, `/hana/log`, `/usr/sap`, `swap`) based on the instance memory profile, with support for custom storage layouts.
    - Tunes OS settings on HANA and NetWeaver VSIs for SAP workloads using [RHEL System Roles](https://access.redhat.com/articles/4488731): `sap_general_preconfigure`, `sap_hana_preconfigure`, `sap_netweaver_preconfigure`.
    - **Does not install SAP software.** Instances are ready for SAP installation.

2. [IBM catalog VPC SAP S/4HANA or BW/4HANA variation](./solutions/ibm-catalog/sap-s4hana-bw4hana)
    - Builds on the SAP Ready foundation and additionally downloads SAP installation binaries from an IBM Cloud Object Storage bucket onto a shared NFS file storage share.
    - Installs and configures **SAP applications** (SAP HANA DB, SAP S/4HANA, SAP BW/4HANA) using [RHEL System Roles](https://access.redhat.com/articles/4488731): `sap_hana_install`, `sap_swpm`, `sap_general_preconfigure`, `sap_hana_preconfigure`, `sap_netweaver_preconfigure`.
    - Supports automated installation of **S/4HANA 2023, S/4HANA 2022, S/4HANA 2021, S/4HANA 2020, and BW/4HANA 2021**.

## Reference architectures
- [IBM catalog VPC SAP S/4HANA or BW/4HANA variation](./reference-architectures/sap-s4hana-bw4hana/deploy-arch-ibm-vpc-sap-s4hana-bw4hana.svg.drawio.svg)



## Solutions

|                                  Variation                                  | Available on IBM Catalog | Creates VPC Landing Zone | Creates VPC HANA Instance | Creates VPC NW Instance | Performs VPC OS Config | Performs VPC SAP Tuning | Install SAP software |
|:---------------------------------------------------------------------------:|:------------------------:|:------------------------:|:-------------------------:|:-----------------------:|:----------------------:|:-----------------------:|:--------------------:|
| [IBM catalog VPC SAP Ready](./solutions/ibm-catalog/sap-ready-to-go) | :heavy_check_mark: | :heavy_check_mark: | 1 | 1 | :heavy_check_mark: | :heavy_check_mark: | N/A |
| [IBM catalog SAP S/4HANA or BW/4HANA variation](./solutions/ibm-catalog/sap-s4hana-bw4hana) | :heavy_check_mark: | :heavy_check_mark: | 1 | 1 | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |



## Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
    - IAM Services
        - **VPC Infrastructure Services** service
            - `Editor` platform access
        - **IBM Cloud Object Storage** service
            - `Reader` platform access
        - **Key Protect** or **Hyper Protect Crypto Services** service
            - `Editor` platform access
        - **Secrets Manager** service
            - `Editor` platform access (if Client-to-Site VPN is enabled)
        - **IBM Cloud Monitoring** service
            - `Editor` platform access (if monitoring is enabled)

## Contributing

You can report issues and request features for this module in GitHub issues in the module repository. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
