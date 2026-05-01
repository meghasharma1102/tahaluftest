##############################################################################
# modules/management_mg/main.tf
#
# 0 policies currently assigned at the Management MG level.
# Management MG is a child of Platform MG and inherits Platform policies.
#
# Sheet: Assignment Scope = "Management" — no entries
#
# TO ADD A POLICY: Copy the block template below into the list and fill it in.
##############################################################################

locals {
  management_mg_policies = [

    {
      assignment_name     = "Deploy-AMBA-Management"
      display_name        = "Deploy Azure Monitor Baseline Alerts for Management"
      definition_id       = "/providers/Microsoft.Management/managementGroups/${var.root_management_group_name}/providers/Microsoft.Authorization/policySetDefinitions/Alerting-Management"
      type                = "raw"
      description         = "Deploys AMBA alerts relevant to the ALZ Management management group."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = []
    },

  ]
}

module "policy_assignment_engine" {
  source                = "../policy_assignment_engine"
  assignments           = local.management_mg_policies
  custom_policy_ids     = var.custom_policy_ids
  custom_initiative_ids = var.custom_initiative_ids
}
