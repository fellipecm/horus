terraform {
  required_version = "~> 1.4.5"

  backend "remote" {
    organization = "fellipecm"

    workspaces {
      name = "horus"
    }
  }

  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "~> 4.117.0"
    }
  }
}
