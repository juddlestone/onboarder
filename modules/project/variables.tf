variable "environments" {
  type = map(object({
    name            = string
    subscription_id = string
    location        = string
  }))
  description = "A map of environments to create branches and workflows for."
}

variable "project_name" {
  type        = string
  description = "The name of the project."
}

variable "project_owner" {
  type        = string
  description = "The owner of the project."
  default     = "jack@itsjack.cloud"
}

variable "project_budget_amount" {
  type        = number
  description = "The budget amount for the project."
  default     = 5
}

variable "repository_name" {
  type        = string
  description = "The name of the GitHub repository."
}

variable "repository_description" {
  type        = string
  description = "The description of the GitHub repository."
  default     = "Managed by Terraform"
}

variable "repository_visibility" {
  type        = string
  description = "The visibility of the GitHub repository."
  default     = "private"
}

variable "repository_gitignore_template" {
  type        = string
  description = "The gitignore template to use for the GitHub repository."
  default     = "Terraform"
}

variable "azure_tenant_id" {
  type        = string
  description = "The Azure tenant ID."
}
