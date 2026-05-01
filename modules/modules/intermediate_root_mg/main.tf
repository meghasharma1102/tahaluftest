##############################################################################
# modules/intermediate_root_mg/main.tf
#
# 10 policies assigned at the Intermediate Root (Parent Group) MG.
# These apply to EVERY subscription in the tenant hierarchy.
#
# Sheet: Assignment Scope = "Intermediate Root"
#
# Count breakdown:
#   Initiatives (8): Deploy-MDEndpoints, Deploy-MDEndpointsAMA, Deploy-Diag-Logs,
#                    MCSB, MCSB-v2, Deploy-ATP-OssDB, Deploy-ATP-SQL, Audit-Zone-Resilient
#   Policies    (2): Deploy-ActivityLog-Diag, Deploy-SvcHealth-Alert
##############################################################################

locals {
  intermediate_root_mg_policies = [

    # ── 1 ─────────────────────────────────────────────────────────────────────
    # Deploy Microsoft Defender for Endpoint agent
    # Initiative | DeployIfNotExists | GUID: e20d08c5-6d64-656d-6465-ce9e37fd0ebc
    {
      assignment_name     = "Deploy-MDEndpoints"
      display_name        = "Deploy Microsoft Defender for Endpoint agent"
      definition_id       = "e20d08c5-6d64-656d-6465-ce9e37fd0ebc"
      type                = "initiative"
      description         = "Deploy Microsoft Defender for Endpoint agent on applicable images."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"]
    },

    # ── 2 ─────────────────────────────────────────────────────────────────────
    # Configure multiple MDE integration settings with MDfC
    # Initiative | DeployIfNotExists | GUID: 77b391e3-2d5d-40c3-83bf-65c846b3c6a3
    {
      assignment_name     = "Deploy-MDEndpointsAMA"
      display_name        = "Configure multiple MDE integration settings with MDfC"
      definition_id       = "77b391e3-2d5d-40c3-83bf-65c846b3c6a3"
      type                = "initiative"
      description         = "Configure the multiple Microsoft Defender for Endpoint integration settings with Microsoft Defender for Cloud."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/fb1c8493-542b-48eb-b624-b4c8fea62acd"]
    },

    # ── 3 ─────────────────────────────────────────────────────────────────────
    # Enable allLogs resource logging to Log Analytics
    # Initiative | DeployIfNotExists | GUID: 0884adba-2312-4468-abeb-5422caed1038
    {
      assignment_name     = "Deploy-Diag-Logs"
      display_name        = "Enable allLogs resource logging to Log Analytics"
      definition_id       = "0884adba-2312-4468-abeb-5422caed1038"
      type                = "initiative"
      description         = "Deploys diagnostic setting using allLogs category group to route logs to Log Analytics Workspace for all supported resources."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({ logAnalytics = { value = var.log_analytics_workspace_id } })
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"]
    },

    # ── 4 ─────────────────────────────────────────────────────────────────────
    # Microsoft Cloud Security Benchmark (Azure Security Benchmark)
    # Initiative | AuditIfNotExists | GUID: 1f3afdf9-d0c9-4c3d-847f-89da613e70a8
    {
      assignment_name     = "MCSB"
      display_name        = "Microsoft Cloud Security Benchmark"
      definition_id       = "1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
      type                = "initiative"
      description         = "The Azure Security Benchmark initiative implements security recommendations defined in Azure Security Benchmark v2."
      effect              = "AuditIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 5 ─────────────────────────────────────────────────────────────────────
    # Microsoft Cloud Security Benchmark v2
    # Initiative | AuditIfNotExists | GUID: e3ec7e09-768c-4b64-882c-fcada3772047
    {
      assignment_name     = "MCSB-v2"
      display_name        = "Microsoft Cloud Security Benchmark v2"
      definition_id       = "e3ec7e09-768c-4b64-882c-fcada3772047"
      type                = "initiative"
      description         = "The Microsoft cloud security benchmark initiative implements security recommendations defined in Microsoft cloud security benchmark."
      effect              = "AuditIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7", "/providers/Microsoft.Authorization/roleDefinitions/a001fd3d-188f-4b5d-821b-7da978bf7442", "/providers/Microsoft.Authorization/roleDefinitions/25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68"]
    },

    # ── 6 ─────────────────────────────────────────────────────────────────────
    # Configure Advanced Threat Protection on open-source relational databases
    # Initiative | DeployIfNotExists | GUID: e77fc0b3-f7e9-4c58-bc13-cb753ed8e46e
    {
      assignment_name     = "Deploy-ATP-OssDB"
      display_name        = "Configure Advanced Threat Protection on OSS relational databases"
      definition_id       = "e77fc0b3-f7e9-4c58-bc13-cb753ed8e46e"
      type                = "initiative"
      description         = "Enable Advanced Threat Protection on non-Basic tier open-source relational databases to detect anomalous activities."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"]
    },

    # ── 7 ─────────────────────────────────────────────────────────────────────
    # Configure Azure Defender on SQL Servers and SQL Managed Instances
    # Initiative | DeployIfNotExists | GUID: 9cb3cc7a-b39b-4b82-bc89-e5a5d9ff7b97
    {
      assignment_name     = "Deploy-ATP-SQL"
      display_name        = "Configure Azure Defender on SQL Servers and SQL Managed Instances"
      definition_id       = "9cb3cc7a-b39b-4b82-bc89-e5a5d9ff7b97"
      type                = "initiative"
      description         = "Enable Azure Defender on SQL Servers and SQL Managed Instances to detect anomalous activities."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/056cd41c-7e88-42e1-933e-88ba6a50c9c3"]
    },

    # ── 8 ─────────────────────────────────────────────────────────────────────
    # Deploy Diagnostic Settings for Activity Log to Log Analytics workspace
    # Policy | DeployIfNotExists | GUID: 2465583e-4e78-4c15-b6be-a36cbc7c8b0f
    {
      assignment_name     = "Deploy-ActivityLog-Diag"
      display_name        = "Deploy Diagnostic Settings for Activity Log to Log Analytics workspace"
      definition_id       = "2465583e-4e78-4c15-b6be-a36cbc7c8b0f"
      type                = "policy"
      description         = "Deploys the diagnostic settings for Azure Activity to stream subscriptions audit logs to a Log Analytics workspace."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({ logAnalytics = { value = var.log_analytics_workspace_id } })
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293", "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa"]
    },

    # ── 9 ─────────────────────────────────────────────────────────────────────
    # Resources should be Zone Resilient
    # Initiative | Audit | GUID: 130fb88f-0fc9-4678-bfe1-31022d71c7d5
    {
      assignment_name     = "Audit-Zone-Resilient"
      display_name        = "Resources should be Zone Resilient"
      definition_id       = "130fb88f-0fc9-4678-bfe1-31022d71c7d5"
      type                = "initiative"
      description         = "Resources can be deployed Zone Redundant or Zone Aligned. Being zone aligned is the foundation for a resilient solution."
      effect              = "Audit"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 10 ────────────────────────────────────────────────────────────────────
    # Configure subscriptions to enable service health alert monitoring rule
    # Policy | DeployIfNotExists | GUID: 98903777-a9f6-47f5-90a9-acaf62ab01a8
    {
      assignment_name     = "Deploy-SvcHealth-Alert"
      display_name        = "Configure subscriptions to enable service health alert monitoring rule"
      definition_id       = "98903777-a9f6-47f5-90a9-acaf62ab01a8"
      type                = "policy"
      description         = "Ensures each subscription has a service health alert rule configured with alert conditions and mapping to action groups."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/47be4a87-7950-4631-9daf-b664a405f074"]
    },

    {
      assignment_name     = "Audit-VM-ManagedDisks"
      display_name        = "Audit VMs that do not use managed disks"
      definition_id       = "06a78e20-9358-41c9-923c-fb736d382a4d"
      type                = "policy"
      description         = "Audits VMs that do not use managed disks."
      effect              = "Audit"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },
    # CUSTOM POLICIES/ INITIATIVES
    # ── 11 ───────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Enforce-ACSB"
      display_name        = "Enforce Azure Compute Security Baseline compliance auditing"
      definition_id       = "Enforce-ACSB"
      type                = "custom_initiative"
      description         = "Enables Azure Compute Security Baseline compliance auditing for Windows and Linux VMs."
      effect              = "AuditIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = []
    },

    # ── 12 ───────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Audit-UnusedResources"
      display_name        = "Unused resources driving cost should be avoided"
      definition_id       = "Audit-UnusedResourcesCostOptimization"
      type                = "custom_initiative"
      description         = "Detects unused but chargeable resources to optimize cost."
      effect              = "Audit"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 13 ───────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Audit-TrustedLaunch"
      display_name        = "Audit-TrustedLaunch"
      definition_id       = "Audit-TrustedLaunch"
      type                = "custom_initiative"
      description         = "Audits Trusted Launch requirements — VM SKU, OS Disk and OS Image must support Gen2."
      effect              = "Audit"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    }

  ]
}

module "policy_assignment_engine" {
  source                = "../policy_assignment_engine"
  assignments           = local.intermediate_root_mg_policies
  custom_policy_ids     = var.custom_policy_ids
  custom_initiative_ids = var.custom_initiative_ids
}
