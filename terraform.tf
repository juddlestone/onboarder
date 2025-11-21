terraform {
  backend "azurerm" {}

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.7.0"
    }

    # azuread = {
    #   source  = "hashicorp/azuread"
    #   version = "~> 3.0"
    # }

    github = {
      source  = "integrations/github"
      version = "~> 6.8.3"
    }
  }
}

provider "azapi" {}

provider "github" {
  owner = var.github_owner
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = var.github_app_pem_file
  }
}
