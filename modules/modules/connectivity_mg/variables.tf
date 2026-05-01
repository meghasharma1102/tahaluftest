##############################################################################
# modules/connectivity_mg/variables.tf
#
# Inputs for the Connectivity MG module.
# Level 2 — child of Platform MG.
# Sheet: Assignment Scope = "Platform/Connectivity"
##############################################################################

variable "scope" {
  type        = string
  description = "Resource ID of the Connectivity Management Group"
}

variable "ddos_protection_plan_id" {
  type        = string
  default     = ""
  description = "Resource ID of the Azure DDoS Protection Plan"
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

variable "root_management_group_name" {
  type        = string
  default     = ""
  description = "MGMT Group which houses the custom policies"
}