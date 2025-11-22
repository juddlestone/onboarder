# Time 
# Used to generate tags with creation date
resource "time_static" "this" {}

# Resource Group
# Used for the state storage account and identity used to provision azure resources
resource "azapi_resource" "resource_group" {
  type = "Microsoft.Resources/resourceGroups@2025-04-01"

  parent_id = "/subscriptions/${var.management_subscription_id}"
  name      = "rg-man-onboarder"
  location  = "uksouth"
  tags      = local.tags
}

# Storage Account
# Used to store terraform state files
resource "azapi_resource" "storage_account" {
  type = "Microsoft.Storage/storageAccounts@2025-01-01"

  parent_id = azapi_resource.resource_group.id
  name      = "stmanonboarder"
  location  = azapi_resource.resource_group.location
  body = {
    kind = "StorageV2"
    properties = {
      accessTier                   = "Hot"
      allowBlobPublicAccess        = false
      allowCrossTenantReplication  = false
      allowSharedKeyAccess         = true
      defaultToOAuthAuthentication = false
      encryption = {
        keySource = "Microsoft.Storage"
        services = {
          blob = {
            enabled = true
            keyType = "Account"
          }
          file = {
            enabled = true
            keyType = "Account"
          }
        }
      }
      minimumTlsVersion = "TLS1_2"
      networkAcls = {
        defaultAction = "Allow"
      }
      publicNetworkAccess      = "Enabled"
      supportsHttpsTrafficOnly = true
    }
    sku = {
      name = "Standard_RAGRS"
    }
  }
  tags                   = local.tags
  response_export_values = ["*"]
}
