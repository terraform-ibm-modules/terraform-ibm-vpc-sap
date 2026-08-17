provider "ibm" {
  alias            = "ibm-is"
  region           = regex("^(.+)-[0-9]+$", var.vpc_zone)[0]
  zone             = var.vpc_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

provider "ibm" {
  alias            = "ibm-sm"
  region           = regex("^(.+)-[0-9]+$", var.vpc_zone)[0]
  zone             = var.vpc_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

data "ibm_iam_auth_token" "auth_token" {
  provider = ibm.ibm-is
}

provider "restapi" {
  uri = "https://resource-controller.cloud.ibm.com"
  headers = {
    Authorization = data.ibm_iam_auth_token.auth_token.iam_access_token
  }
  write_returns_object = true
}
