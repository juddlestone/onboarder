locals {
  common_tags = {
    ProjectOwner = var.project_owner
    ProjectName  = var.project_name
    TimeCreated  = "${time_static.this.year}/${time_static.this.month}/${time_static.this.day}"
  }

  repository_secrets = {
    AZURE_TENANT_ID = {
      name  = "AZURE_TENANT_ID"
      value = var.azure_tenant_id
    }
    BACKEND_RESOURCE_GROUP_NAME = {
      name  = "BACKEND_RESOURCE_GROUP_NAME"
      value = "rg-man-onboarder"
    }
    BACKEND_STORAGE_ACCOUNT_NAME = {
      name  = "BACKEND_STORAGE_ACCOUNT_NAME"
      value = "stmanonboarder"
    }
  }
}
