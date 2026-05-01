##############################################################################
# modules/platform_mg/main.tf
#
# 10 policies assigned at the Platform MG level.
# Apply to all Platform subscriptions (Connectivity, Identity, Management).
#
# Sheet: Assignment Scope = "Platform"
#
# Count breakdown:
#   Initiatives (8): Deploy-VM-Monitor-AMA, Deploy-VMSS-Monitor-AMA,
#                    Deploy-HybridVM-Monitor-AMA, Deploy-ChangeTracking-VM,
#                    Deploy-ChangeTracking-VMSS, Deploy-ChangeTracking-Arc,
#                    Deploy-DefenderSQL-AMA, Deploy-TrustedLaunch-Attestation
#   Policies    (2): Enforce-Subnet-Private, DenyAction-PRT-AMA-Identity
##############################################################################

locals {
  platform_mg_policies = [

    # ── 1 ─────────────────────────────────────────────────────────────────────
    # Subnets should be private
    # Policy | Audit (→ Deny when ready) | GUID: 7bca8353-aa3b-429b-904a-9229c4385837
    {
      assignment_name     = "Enforce-Subnet-Private"
      display_name        = "Test-Subnets should be private"
      definition_id       = "7bca8353-aa3b-429b-904a-9229c4385837"
      type                = "policy"
      description         = "Ensure subnets are secure by default by preventing default outbound access."
      effect              = "Audit" # Change to "Deny" when ready to enforce
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 2 ─────────────────────────────────────────────────────────────────────
    # Enable Azure Monitor for VMs with AMA
    # Initiative | DeployIfNotExists | GUID: 924bfe3a-762f-40e7-86dd-5c8b95eb09e6
    {
      assignment_name = "Deploy-VM-Monitor-AMA"
      display_name    = "Test-Enable Azure Monitor for VMs with AMA"
      definition_id   = "924bfe3a-762f-40e7-86dd-5c8b95eb09e6"
      type            = "initiative"
      description     = "Installs the Azure Monitoring Agent on VMs and enables Azure Monitor."
      effect          = "DeployIfNotExists"
      scope           = var.scope
      parameters = jsonencode({
        userAssignedManagedIdentityName          = { value = regex("[^/]+$", var.user_assigned_identity_id) }
        userAssignedManagedIdentityResourceGroup = { value = regex("/resourceGroups/([^/]+)/", var.user_assigned_identity_id)[0] }
        bringYourOwnUserAssignedManagedIdentity  = { value = false }
        dcrResourceId                            = { value = var.data_collection_rule_id }


      })
      identity_type = "SystemAssigned"
      identity_id   = "" #var.user_assigned_identity_id
      role_definition_ids = [
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
      ]
    },

    # ── 3 ─────────────────────────────────────────────────────────────────────
    # Enable Azure Monitor for VMSS with AMA
    # Initiative | DeployIfNotExists | GUID: f5bf694c-cca7-4033-b883-3a23327d5485
    {
      assignment_name = "Deploy-VMSS-Monitor-AMA"
      display_name    = "Test-Enable Azure Monitor for VMSS with AMA"
      definition_id   = "f5bf694c-cca7-4033-b883-3a23327d5485"
      type            = "initiative"
      description     = "Installs the Azure Monitoring Agent on VM Scale Sets and enables Azure Monitor."
      effect          = "DeployIfNotExists"
      scope           = var.scope

      parameters = jsonencode({
        userAssignedManagedIdentityName          = { value = regex("[^/]+$", var.user_assigned_identity_id) }
        userAssignedManagedIdentityResourceGroup = { value = regex("/resourceGroups/([^/]+)/", var.user_assigned_identity_id)[0] }
        bringYourOwnUserAssignedManagedIdentity  = { value = false }
        dcrResourceId                            = { value = var.data_collection_rule_id }

      })
      identity_type = "SystemAssigned"
      identity_id   = "" #var.user_assigned_identity_id
      role_definition_ids = [
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
      ]
    },

    # ── 4 ─────────────────────────────────────────────────────────────────────
    # Enable Azure Monitor for Hybrid VMs with AMA
    # Initiative | DeployIfNotExists | GUID: 2b00397d-c309-49c4-aa5a-f0b2c5bc6321
    {
      assignment_name = "Deploy-HybVM-Mntr-AMA"
      display_name    = "Test-Enable Azure Monitor for Hybrid VMs with AMA"
      definition_id   = "2b00397d-c309-49c4-aa5a-f0b2c5bc6321"
      type            = "initiative"
      description     = "Installs the Azure Monitoring Agent on Arc-enabled servers and enables Azure Monitor."
      effect          = "DeployIfNotExists"
      scope           = var.scope
      parameters = jsonencode({
        # userAssignedManagedIdentityName          = regex("[^/]+$", var.user_assigned_identity_id)
        # userAssignedManagedIdentityResourceGroup = regex("/resourceGroups/([^/]+)/", var.user_assigned_identity_id)[0]
        dcrResourceId = { value = var.data_collection_rule_id }
      })
      identity_type = "SystemAssigned"
      identity_id   = "" #var.user_assigned_identity_id
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302",
        "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
      ]
    },

    # ── 5 ─────────────────────────────────────────────────────────────────────
    # Enable ChangeTracking and Inventory for VMs
    # Initiative | DeployIfNotExists | GUID: 92a36f05-ebc9-4bba-9128-b47ad2ea3354
    {
      assignment_name = "Deploy-ChangeTracking-VM"
      display_name    = "Test-Enable ChangeTracking and Inventory for VMs"
      definition_id   = "92a36f05-ebc9-4bba-9128-b47ad2ea3354"
      type            = "initiative"
      description     = "Enables ChangeTracking and Inventory for VMs using a Data Collection Rule and user-assigned identity."
      effect          = "DeployIfNotExists"
      scope           = var.scope
      parameters = jsonencode({
        userAssignedIdentityResourceId          = { value = var.user_assigned_identity_id }
        dcrResourceId                           = { value = var.data_collection_rule_id }
        bringYourOwnUserAssignedManagedIdentity = { value = false }
      })
      identity_type = "SystemAssigned"
      identity_id   = "" #var.user_assigned_identity_id
      role_definition_ids = [
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
      ]
    },

    # ── 6 ─────────────────────────────────────────────────────────────────────
    # Enable ChangeTracking and Inventory for VMSS
    # Initiative | DeployIfNotExists | GUID: c4a70814-96be-461c-889f-2b27429120dc
    {
      assignment_name = "Deploy-Chngtrck-VMSS"
      display_name    = "Test-Enable ChangeTracking and Inventory for VMSS"
      definition_id   = "c4a70814-96be-461c-889f-2b27429120dc"
      type            = "initiative"
      description     = "Enables ChangeTracking and Inventory for VM Scale Sets using a Data Collection Rule."
      effect          = "DeployIfNotExists"
      scope           = var.scope
      parameters = jsonencode({
        #userAssignedIdentityResourceId = var.user_assigned_identity_id
        dcrResourceId                           = { value = var.data_collection_rule_id }
        bringYourOwnUserAssignedManagedIdentity = { value = false }


      })
      identity_type = "SystemAssigned"
      identity_id   = "" #var.user_assigned_identity_id
      role_definition_ids = [
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
      ]
    },

    # ── 7 ─────────────────────────────────────────────────────────────────────
    # Enable ChangeTracking and Inventory for Arc-enabled VMs
    # Initiative | DeployIfNotExists | GUID: 53448c70-089b-4f52-8f38-89196d7f2de1
    {
      assignment_name = "Deploy-ChngTrck-Arc"
      display_name    = "Test-Enable ChangeTracking and Inventory for Arc-enabled VMs"
      definition_id   = "53448c70-089b-4f52-8f38-89196d7f2de1"
      type            = "initiative"
      description     = "Enables ChangeTracking and Inventory for Arc-enabled servers using a Data Collection Rule."
      effect          = "DeployIfNotExists"
      scope           = var.scope
      parameters = jsonencode({
        # userAssignedIdentityResourceId = var.user_assigned_identity_id
        dcrResourceId = { value = var.data_collection_rule_id }
      })
      identity_type = "SystemAssigned"
      identity_id   = "" #var.user_assigned_identity_id
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302",
        "/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
      ]
    },

    # ── 8 ─────────────────────────────────────────────────────────────────────
    # Enable Defender for SQL on SQL VMs and Arc-enabled SQL Servers
    # Initiative | DeployIfNotExists | GUID: de01d381-bae9-4670-8870-786f89f49e26
    {
      assignment_name = "Deploy-DefenderSQL-AMA"
      display_name    = "Test-Enable Defender for SQL on SQL VMs and Arc-enabled SQL Servers"
      definition_id   = "de01d381-bae9-4670-8870-786f89f49e26"
      type            = "initiative"
      description     = "Enables Microsoft Defender for SQL and AMA on SQL VMs and Arc-enabled SQL Servers."
      effect          = "DeployIfNotExists"
      scope           = var.scope
      parameters = jsonencode({
        userAssignedIdentityResourceId = { value = var.user_assigned_identity_id }
        dcrResourceId                  = { value = var.data_collection_rule_id }
        userWorkspaceResourceId        = { value = var.log_analytics_workspace_id }
      })
      identity_type = "SystemAssigned"
      identity_id   = ""
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c"
      ]
    },

    # ── 9 ─────────────────────────────────────────────────────────────────────
    # Do not allow deletion of resource types (protects AMA User Identity)
    # Policy | DenyAction | GUID: 78460a36-508a-49a4-b2b2-2f5ec564f4bb
    {
      assignment_name     = "Deny-PRT-AMA-Identity"
      display_name        = "Test-Do not allow deletion of resource types (protect AMA identity)"
      definition_id       = "78460a36-508a-49a4-b2b2-2f5ec564f4bb"
      type                = "policy"
      description         = "Blocks deletion of the User Assigned Managed Identity used by AMA policies."
      effect              = "DenyAction"
      scope               = var.scope
      parameters          = jsonencode({ listOfResourceTypesDisallowedForDeletion = { value = ["Microsoft.ManagedIdentity/userAssignedIdentities"] } })
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 10 ────────────────────────────────────────────────────────────────────
    # Configure Guest Attestation on Trusted Launch enabled VMs
    # Initiative | DeployIfNotExists | GUID: 281d9e47-d14d-4f05-b8eb-18f2c4a034ff
    {
      assignment_name = "Deploy-TrstLch-Attest"
      display_name    = "Test-Configure Guest Attestation on Trusted Launch enabled VMs"
      definition_id   = "281d9e47-d14d-4f05-b8eb-18f2c4a034ff"
      type            = "initiative"
      description     = "Enables Guest Attestation on Trusted Launch enabled VMs."
      effect          = "DeployIfNotExists"
      scope           = var.scope
      parameters      = jsonencode({})
      identity_type   = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830",
        "/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/Microsoft.Authorization/roleDefinitions/e40ec5ca-96e0-45a2-b4ff-59039f2c2b59"
      ]
    },
    # CUSTOM POLICIES
    # ── 1 ─────────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Enforce-KVGuardrails"
      display_name        = "Enforce recommended guardrails for Azure Key Vault"
      definition_id       = "Enforce-Guardrails-KeyVault"
      type                = "custom_initiative"
      description         = "Enables recommended ALZ guardrails for Azure Key Vault."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 2 ─────────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Enforce-Backup"
      display_name        = "Enforce enhanced recovery and backup policies"
      definition_id       = "Enforce enhanced recovery and backup policies"
      type                = "custom_initiative"
      description         = "Enables recommended audit policies for Azure Backup and Site Recovery."
      effect              = "Audit"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 3 ─────────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Modify-AUM-CheckUpdates"
      display_name        = "Configure periodic checking for missing system updates on azure virtual machines and Arc-enabled virtual machines"
      definition_id       = "Deploy-AUM-CheckUpdates"
      type                = "custom_initiative"
      description         = "Enables automatic OS update assessment every 24 hours for VMs and Arc-enabled VMs."
      effect              = "Modify"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = []
    },
  ]
}


module "policy_assignment_engine" {
  source                = "../policy_assignment_engine"
  assignments           = local.platform_mg_policies
  custom_policy_ids     = var.custom_policy_ids
  custom_initiative_ids = var.custom_initiative_ids
}