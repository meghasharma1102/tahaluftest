##############################################################################
# modules/landing_zone_mg/variables.tf
#
# Inputs for the Landing Zone (Application) MG module.
# Level 1 — parent to Landing Zone/Corp MG.
# Policies apply to all application workload subscriptions.
##############################################################################

variable "scope" {
  type        = string
  description = "Resource ID of the Landing Zone (Application) Management Group"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the central Log Analytics Workspace"
}

variable "ddos_protection_plan_id" {
  type        = string
  default     = ""
  description = "Resource ID of the Azure DDoS Protection Plan"
}

variable "user_assigned_identity_id" {
  type        = string
  default     = ""
  description = "Resource ID of the User Assigned Managed Identity for AMA policies"
}

variable "data_collection_rule_id" {
  type        = string
  default     = ""
  description = "Resource ID of the Data Collection Rule for ChangeTracking and Defender SQL policies"
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