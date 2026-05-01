##############################################################################
# modules/intermediate_root_mg/variables.tf
#
# Inputs for the Intermediate Root (Parent Group) MG module.
# Level 0 — policies here apply to ALL subscriptions in the tenant.
##############################################################################

variable "scope" {
  type        = string
  description = "Resource ID of the Intermediate Root Management Group"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the central Log Analytics Workspace"
}

variable "custom_policy_ids" {
  type = map(object({
    name                = string
    id                  = string
    role_definition_ids = list(string)
  }))
  default = {}
}

variable "custom_initiative_ids" {
  type = map(object({
    name                = string
    id                  = string
    role_definition_ids = list(string)
  }))
  default = {}
}