##############################################################################
# modules/policy_assignment_engine/variables.tf
#
# Input schema for the shared engine.
# Every MG module passes its policy list into this engine.
##############################################################################

variable "assignments" {
  description = "List of policy/initiative assignments to deploy"
  type = list(object({
    assignment_name = string
    display_name    = string
    definition_id   = string
    type            = string # "policy" or "initiative"
    description     = string
    effect          = string
    scope           = string
    # parameters        = optional(map(any), {})
    parameters          = optional(string, "")
    identity_type       = optional(string, "None") # "None" | "SystemAssigned" | "UserAssigned"
    identity_id         = optional(string, "")
    role_definition_ids = optional(list(string), [])
  }))
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