variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "management_subscription_id" {
  description = "The Subscription ID for the management subscription where resources will be created."
  type        = string
}
