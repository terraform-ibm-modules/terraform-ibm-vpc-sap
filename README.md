<!-- Update this title with a descriptive name. Use sentence case. -->
# IBM Cloud VPC SAP deployable architectures

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
  3. Update the Terraform Registry badge to point to the correct published module path (replace "module-template" with the actual module name before release).
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-vpc-sap?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/terraform-ibm-modules/vpc-sap/ibm/latest)

This repository provides Terraform deployable architectures and modules for automating the end-to-end deployment of SAP landscapes on **IBM Cloud Virtual Private Cloud (VPC)**. It deploys a secure VPC landing zone, provisions SAP HANA DB and SAP NetWeaver (Application) Virtual Server Instances (VSIs), configures storage and OS prerequisites, downloads installation media from IBM Cloud Object Storage (COS), and automates full SAP software provisioning (such as SAP S/4HANA or SAP BW/4HANA) using Ansible.

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
<ul>
  <li><a href="#terraform-ibm-vpc-sap">terraform-ibm-vpc-sap</a></li>
  <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/tree/main/modules">Submodules</a>
    <ul>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/tree/main/modules/vpc-landing-zone">vpc-landing-zone</a></li>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/tree/main/modules/vpc-landing-zone/submodules/ansible">vpc-landing-zone/subansible</a></li>
    </ul>
  </li>
  <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/tree/main/solutions">Deployable Architectures</a>
    <ul>
      <li><a href="https://github.com/terraform-ibm-modules/terraform-ibm-vpc-sap/tree/main/solutions/ibm-catalog/sap-s4hana-bw4hana">IBM Cloud Catalog - SAP HANA with SAP S/4HANA or SAP BW/4HANA on VPC</a></li>
    </ul>
  </li>
  <li><a href="#known-issues">Known issues</a></li>
  <li><a href="#contributing">Contributing</a></li>
</ul>
<!-- END OVERVIEW HOOK -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-module-template

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.70.0"
    }
  }
}

locals {
  region = "us-south"
  zone   = "us-south-1"
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = local.region
}

module "sap_s4hana_bw4hana" {
  source                     = "terraform-ibm-modules/vpc-sap/ibm//solutions/ibm-catalog/sap-s4hana-bw4hana"
  prefix                     = "sap-vpc"
  vpc_zone                   = local.zone
  external_access_ip         = "198.51.100.10/32"
  ssh_public_key             = var.ssh_public_key
  ssh_private_key            = var.ssh_private_key
  sap_solution               = "s4hana-2023"
  sap_hana_master_password   = var.sap_hana_master_password
  sap_swpm_master_password   = var.sap_swpm_master_password
  ansible_vault_password     = var.ansible_vault_password
  enable_monitoring          = false
  enable_scc_wp              = false
  ibmcloud_cos_service_credentials = var.ibmcloud_cos_service_credentials
}
```

### Required access policies

You need the following permissions to run this module:

Service
 VPC Infrastructure Services
  Administrator platform access
  Manager service access
IBM Cloud Object Storage
  Administrator platform access
  Manager service access
Secrets Manager (if VPN/certificates are enabled)
  Administrator platform access
  Manager service access
KMS / Key Protect (if enabled)
  Administrator platform access
  Manager service access

<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

No requirements.

### Modules

No modules.

### Resources

No resources.

### Inputs

No inputs.

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Known issues

<!-- Update this if any known issues or limitations -->
There are currently no known issues or limitations at this time.

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
