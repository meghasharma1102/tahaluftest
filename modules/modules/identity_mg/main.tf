##############################################################################
# modules/identity_mg/main.tf
#
# 1 policy assigned at the Identity MG level.
# Identity MG is a child of Platform MG and inherits Platform policies.
#
# Sheet: Assignment Scope = "Platform/Identity"
#
# Count breakdown:
#   Policies (1): Deploy-VM-Backup
##############################################################################

locals {
  identity_mg_policies = [

    # ── 1 ─────────────────────────────────────────────────────────────────────
    # Configure backup on VMs without a given tag to a new recovery services vault
    # Policy | DeployIfNotExists | GUID: 98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86
    {
      assignment_name     = "Deploy-VM-Backup"
      display_name        = "Configure backup on VMs without a given tag to a new recovery services vault"
      definition_id       = "98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86"
      type                = "policy"
      description         = "Enforce backup for all VMs in the Identity MG by deploying a recovery services vault in the same location and resource group."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c", "/providers/Microsoft.Authorization/roleDefinitions/5e467623-bb1f-42f4-a55d-6e525e11384b"]
    },
    # CUSTOM POLICY/INITIATIVES
    # ── 1 ─────────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Deny-MgmtPorts"
      display_name        = "Management port access from the Internet should be blocked"
      definition_id       = "Management port access from the Internet should be blocked"
      type                = "custom_policy"
      description         = "Denies any NSG rule that allows management port access from the Internet."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },


    # ── 2 ─────────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Deploy-AMBA-Identity"
      display_name        = "Deploy Azure Monitor Baseline Alerts for Identity"
      definition_id       = "/providers/Microsoft.Management/managementGroups/${var.root_management_group_name}/providers/Microsoft.Authorization/policySetDefinitions/Alerting-Identity"
      type                = "raw"
      description         = "Deploys AMBA alerts relevant to the ALZ Identity management group."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = []
    },
    # ── 3 ─────────────────────────────────────────────────────────────────────
    {
      assignment_name = "Deny-SubnetNoNSG"
      display_name    = "Subnets should have a Network Security Group"
      definition_id   = "Deny-Subnet-Without-Nsg"
      type            = "custom_policy"
      description     = "Denies creation of a subnet without a Network Security Group."
      effect          = "Deny"
      scope           = var.scope
      parameters = jsonencode({
        effect = {
          value = "Deny"
        }
        excludedSubnets = {
          value = [
            "GatewaySubnet",
            "AzureFirewallSubnet",
            "AzureFirewallManagementSubnet",
            "RouteServerSubnet"
      ] } })
      identity_type       = "None"
      role_definition_ids = []
    },

  ]
}

module "policy_assignment_engine" {
  source                = "../policy_assignment_engine"
  assignments           = local.identity_mg_policies
  custom_policy_ids     = var.custom_policy_ids
  custom_initiative_ids = var.custom_initiative_ids
}