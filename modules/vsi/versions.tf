terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source                = "IBM-Cloud/ibm"
      version               = ">= 2.4.0"
      configuration_aliases = [ibm.ibm-is]
    }
  }
}
