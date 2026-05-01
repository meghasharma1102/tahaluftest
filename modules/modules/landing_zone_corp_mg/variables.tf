##############################################################################
# modules/landing_zone_corp_mg/variables.tf
#
# Inputs for the Landing Zone/Corp MG module.
# Corp is a CHILD of Landing Zone MG — it inherits all 21 Landing Zone policies
# and additionally gets these 3 Corp-specific restrictions.
##############################################################################

variable "scope" {
  type        = string
  description = "Resource ID of the Landing Zone/Corp Management Group"
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
