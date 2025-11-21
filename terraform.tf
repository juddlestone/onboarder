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
  token = var.github_token
}
