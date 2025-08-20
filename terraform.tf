# terraform.tf

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0.0"
    }
  }
}

terraform {
  cloud {
    organization = "vault-transit"
    workspaces {
      name = "vault-terraform"
    }
  }
}