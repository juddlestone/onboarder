# Random
resource "random_uuid" "this" {
  for_each = var.environments
}



# Time
resource "time_static" "this" {}



# Github
# Repository
resource "github_repository" "this" {
  name        = var.repository_name
  description = var.repository_description

  visibility         = var.repository_visibility
  gitignore_template = var.repository_gitignore_template
}

# Branches
# Don't create a branch for 'prd', I will use main for my production branch
resource "github_branch" "this" {
  for_each   = { for k, v in var.environments : k => v if k != "prd" }
  repository = github_repository.this.name
  branch     = each.key
}

# Create a github environment for each environment 
resource "github_repository_environment" "this" {
  for_each    = var.environments
  environment = each.key
  repository  = github_repository.this.name
}

# Create a terraform workflow for each environment
resource "github_repository_file" "this" {
  for_each            = var.environments
  repository          = github_repository.this.name
  branch              = "main"
  file                = ".github/workflows/terraform-${each.key}.yml"
  content             = "**/*.tfstate"
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform"
  commit_email        = "terraform@itsjack.cloud"
  overwrite_on_create = true
}

resource "github_actions_environment_secret" "env_secret_client_id" {
  for_each        = var.environments
  environment     = each.key
  repository      = github_repository.this.name
  secret_name     = "AZURE_CLIENT_ID"
  plaintext_value = azapi_resource.user_assigned_identity[each.key].output.properties.clientId
}

resource "github_actions_environment_secret" "env_secret_subscription_id" {
  for_each        = var.environments
  environment     = each.key
  repository      = github_repository.this.name
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = each.value.subscription_id
}

resource "github_actions_secret" "repo_secret" {
  for_each        = local.repository_secrets
  repository      = github_repository.this.name
  secret_name     = each.value.name
  plaintext_value = each.value.value
}

# AzAPI
# Naming
module "naming" {
  for_each = var.environments
  source   = "Azure/naming/azurerm"
  suffix   = [each.value.name, each.key]
}

# Resource Group
resource "azapi_resource" "resource_group" {
  for_each = var.environments
  type     = "Microsoft.Resources/resourceGroups@2025-04-01"

  parent_id = "/subscriptions/${each.value.subscription_id}"
  name      = module.naming[each.key].resource_group.name_unique
  location  = each.value.location
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

# Budget
resource "azapi_resource" "budget" {
  for_each = var.environments
  type     = "Microsoft.Consumption/budgets@2019-10-01"

  parent_id = azapi_resource.resource_group[each.key].id
  name      = "budget-${module.naming[each.key].resource_group.name_unique}"
  body = {
    properties = {
      amount   = var.project_budget_amount
      category = "Cost"
      notifications = {
        "NinetyPercent" = {
          contactEmails = [var.project_owner]
          enabled       = true
          operator      = "EqualTo"
          threshold     = 90
          thresholdType = "Actual"
        }
      }
      timeGrain = "Monthly"
      timePeriod = {
        startDate = formatdate("YYYY-MM-'01T00:00:00Z'", time_static.this.rfc3339)
      }
    }
  }
}

# User Assigned Identity
resource "azapi_resource" "user_assigned_identity" {
  for_each = var.environments
  type     = "Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview"

  parent_id = azapi_resource.resource_group[each.key].id
  name      = module.naming[each.key].user_assigned_identity.name_unique
  location  = each.value.location

  response_export_values = ["*"]

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

# Federated Credential
resource "azapi_resource" "user_assigned_identity_federated_credential" {
  for_each = var.environments
  type     = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2025-01-31-preview"

  parent_id = azapi_resource.user_assigned_identity[each.key].id
  name      = "fic-${module.naming[each.key].user_assigned_identity.name_unique}"
  body = {
    properties = {
      audiences = ["api://AzureADTokenExchange"]
      issuer    = "https://token.actions.githubusercontent.com"
      subject   = "repo:huddlestone/${github_repository.this.name}:environment:${each.key}"
    }
  }
}

# Role Assignment
# Gives 'Owner' role to the UAI in the target resource group
resource "azapi_resource" "user_assigned_identity_role_assignment" {
  for_each = var.environments
  type     = "Microsoft.Authorization/roleAssignments@2022-04-01"

  parent_id = azapi_resource.resource_group[each.key].id
  name      = random_uuid.this[each.key].result
  body = {
    properties = {
      description      = "Provides 'Owner' permissions to the UAI in the ${each.key} environment"
      principalId      = azapi_resource.user_assigned_identity[each.key].output.properties.principalId
      principalType    = "ServicePrincipal"
      roleDefinitionId = "/subscriptions/${each.value.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
    }
  }
}
