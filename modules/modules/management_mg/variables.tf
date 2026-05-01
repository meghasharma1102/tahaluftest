##############################################################################
# modules/management_mg/variables.tf
#
# Inputs for the Management MG module.
# Level 2 — child of Platform MG.
# Sheet: Assignment Scope = "Management" — no policies yet.
##############################################################################

variable "scope" {
  type        = string
  description = "Resource ID of the Management Management Group"
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