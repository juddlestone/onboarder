# Used to create basic, greenfield projects
module "basic_projects" {
  for_each     = local.basic_projects
  source       = "./modules/project"
  environments = each.value.environments

  azure_tenant_id               = data.azapi_client_config.current.tenant_id
  project_name                  = each.value.project_name
  project_owner                 = each.value.project_owner
  project_budget_amount         = each.value.project_budget_amount
  repository_name               = each.value.repository_name
  repository_description        = each.value.repository_description
  repository_visibility         = each.value.repository_visibility
  repository_gitignore_template = each.value.repository_gitignore_template

}
