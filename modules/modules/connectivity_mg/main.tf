##############################################################################
# modules/connectivity_mg/main.tf
#
# 1 policy assigned at the Connectivity MG level.
# Connectivity MG is a child of Platform MG and inherits Platform policies.
#
# Sheet: Assignment Scope = "Platform/Connectivity"
#
# Count breakdown:
#   Policies (1): Modify-DDoS-Protection
##############################################################################

locals {
  connectivity_mg_policies = [

    # ── 1 ─────────────────────────────────────────────────────────────────────
    # Virtual networks should be protected by Azure DDoS Protection Standard
    # Policy | Modify | GUID: 94de2ad3-e0c1-4caf-ad78-5d47bbc83d3d
    {
      assignment_name     = "Modify-DDoS-Protection"
      display_name        = "Virtual networks should be protected by Azure DDoS Protection Standard"
      definition_id       = "94de2ad3-e0c1-4caf-ad78-5d47bbc83d3d"
      type                = "policy"
      description         = "Protect virtual networks against volumetric and protocol attacks with Azure DDoS Protection Standard."
      effect              = "Modify"
      scope               = var.scope
      parameters          = jsonencode({ ddosPlan = { value = var.ddos_protection_plan_id } })
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7"]
    },
    {
      assignment_name     = "Deploy-AMBA-Conn1"
      display_name        = "Deploy Azure Monitor Baseline Alerts (AMBA-ALZ) for Connectivity - Part #1"
      definition_id       = "/providers/Microsoft.Management/managementGroups/${var.root_management_group_name}/providers/Microsoft.Authorization/policySetDefinitions/Alerting-Connectivity" # ← add this file first
      type                = "raw"
      description         = "This initiative deploys Azure Monitor Baseline Alerts (AMBA-ALZ) to monitor Network components such as Azure Firewalls, ExpressRoute, VPN, and Private DNS Zones."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = []
    },
    {
      assignment_name     = "Deploy-AMBA-Conn2"
      display_name        = "Deploy Azure Monitor Baseline Alerts (AMBA-ALZ) for Connectivity - Part #2"
      definition_id       = "/providers/Microsoft.Management/managementGroups/${var.root_management_group_name}/providers/Microsoft.Authorization/policySetDefinitions/Alerting-Connectivity-2" # ← add this file first
      type                = "raw"
      description         = "This initiative deploys Azure Monitor Baseline Alerts (AMBA-ALZ) to monitor Network components such as Azure Firewalls, ExpressRoute, p2svpngateways and virtualhubs."
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
  assignments           = local.connectivity_mg_policies
  custom_policy_ids     = var.custom_policy_ids
  custom_initiative_ids = var.custom_initiative_ids
}