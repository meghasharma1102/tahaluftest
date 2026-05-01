##############################################################################
# modules/landing_zone_mg/main.tf
#
# 21 policies assigned at the Landing Zone MG level.
# Apply to ALL application workload subscriptions.
#
# Sheet: Assignment Scope = "Landing Zones"
#
# Count breakdown:
#   Network     (4): Deny-IP-Forwarding, Deny-Storage-No-HTTPS,
#                    Modify-DDoS-Protection, Audit-WAF-AppGateway
#   Kubernetes  (4): Deploy-AKS-Policy-Addon, Deny-AKS-Privileged-Containers,
#                    Deny-AKS-Priv-Escalation, Deny-AKS-No-HTTPS
#   SQL         (3): Deploy-SQL-Auditing, Deploy-SQL-ThreatDetection, Deploy-SQL-TDE
#   Compute     (2): Deploy-VM-Backup, Enforce-Subnet-Private
#   Monitoring  (3): Deploy-VM-Monitor-AMA, Deploy-VMSS-Monitor-AMA,
#                    Deploy-HybridVM-Monitor-AMA
#   Tracking    (3): Deploy-ChangeTracking-VM, Deploy-ChangeTracking-VMSS,
#                    Deploy-ChangeTracking-Arc
#   Security    (2): Deploy-DefenderSQL-AMA, Deploy-TrustedLaunch-Attestation
##############################################################################

locals {
  landing_zone_mg_policies = [

    # ── NETWORK ───────────────────────────────────────────────────────────────

    # ── 1 ─────────────────────────────────────────────────────────────────────
    # Network interfaces should disable IP forwarding
    # Policy | Deny | GUID: 88c0b9da-ce96-4b03-9635-f29a937e2900
    {
      assignment_name     = "Deny-IP-Forwarding"
      display_name        = "Network interfaces should disable IP forwarding"
      definition_id       = "88c0b9da-ce96-4b03-9635-f29a937e2900"
      type                = "policy"
      description         = "Denies network interfaces which have IP forwarding enabled. IP forwarding disables Azure's check of source and destination."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 2 ─────────────────────────────────────────────────────────────────────
    # Secure transfer to storage accounts should be enabled
    # Policy | Deny | GUID: 404c3081-a854-4457-ae30-26a93ef643f9
    {
      assignment_name     = "Deny-Storage-No-HTTPS"
      display_name        = "Secure transfer to storage accounts should be enabled"
      definition_id       = "404c3081-a854-4457-ae30-26a93ef643f9"
      type                = "policy"
      description         = "Enforce Secure Transfer on storage accounts. Forces acceptance of requests only from HTTPS connections."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 3 ─────────────────────────────────────────────────────────────────────
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

    # ── 4 ─────────────────────────────────────────────────────────────────────
    # WAF should be enabled for Application Gateway
    # Policy | Audit | GUID: 564feb30-bf6a-4854-b4bb-0d2d2d1e6c66
    {
      assignment_name     = "Audit-WAF-AppGateway"
      display_name        = "Web Application Firewall (WAF) should be enabled for Application Gateway"
      definition_id       = "564feb30-bf6a-4854-b4bb-0d2d2d1e6c66"
      type                = "policy"
      description         = "Audits that WAF is enabled for Application Gateway."
      effect              = "Audit"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── KUBERNETES ────────────────────────────────────────────────────────────

    # ── 5 ─────────────────────────────────────────────────────────────────────
    # Deploy Azure Policy Add-on to AKS clusters
    # Policy | DeployIfNotExists | GUID: a8eff44f-8c92-45c3-a3fb-9880802d67a7
    {
      assignment_name     = "Deploy-AKS-Policy-Addon"
      display_name        = "Deploy Azure Policy Add-on to AKS clusters"
      definition_id       = "a8eff44f-8c92-45c3-a3fb-9880802d67a7"
      type                = "policy"
      description         = "Use Azure Policy Add-on to manage and report on the compliance state of AKS clusters."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8", "/providers/Microsoft.Authorization/roleDefinitions/18ed5180-3e48-46fd-8541-4ea054d57064"]
    },

    # ── 6 ─────────────────────────────────────────────────────────────────────
    # Kubernetes cluster should not allow privileged containers
    # Policy | Deny | GUID: 95edb821-ddaf-4404-9732-666045e056b4
    {
      assignment_name     = "Deny-AKS-Pvg-Cnters"
      display_name        = "Kubernetes cluster should not allow privileged containers"
      definition_id       = "95edb821-ddaf-4404-9732-666045e056b4"
      type                = "policy"
      description         = "Do not allow privileged containers in a Kubernetes cluster. CIS 5.2.1."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 7 ─────────────────────────────────────────────────────────────────────
    # Kubernetes clusters should not allow container privilege escalation
    # Policy | Deny | GUID: 1c6e92c9-99f0-4e55-9cf2-0c234dc48f99
    {
      assignment_name     = "Deny-AKS-Priv-Escalation"
      display_name        = "Kubernetes clusters should not allow container privilege escalation"
      definition_id       = "1c6e92c9-99f0-4e55-9cf2-0c234dc48f99"
      type                = "policy"
      description         = "Do not allow containers to run with privilege escalation to root. CIS 5.2.5."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 8 ─────────────────────────────────────────────────────────────────────
    # Kubernetes clusters should be accessible only over HTTPS
    # Policy | Deny | GUID: 1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d
    {
      assignment_name     = "Deny-AKS-No-HTTPS"
      display_name        = "Kubernetes clusters should be accessible only over HTTPS"
      definition_id       = "1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d"
      type                = "policy"
      description         = "Use of HTTPS ensures authentication and protects data in transit from eavesdropping attacks."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── SQL ───────────────────────────────────────────────────────────────────

    # ── 9 ─────────────────────────────────────────────────────────────────────
    # Configure SQL servers to have auditing enabled to Log Analytics
    # Policy | DeployIfNotExists | GUID: 25da7dfb-0666-4a15-a8f5-402127efd8bb
    {
      assignment_name = "Deploy-SQL-Auditing"
      display_name    = "Configure SQL servers to have auditing enabled to Log Analytics"
      definition_id   = "25da7dfb-0666-4a15-a8f5-402127efd8bb"
      type            = "policy"
      description     = "Configures auditing events to flow to the specified Log Analytics workspace if auditing is not enabled."
      effect          = "DeployIfNotExists"
      scope           = var.scope
      parameters      = jsonencode({ logAnalyticsWorkspaceId = { value = var.log_analytics_workspace_id } })
      identity_type   = "SystemAssigned"
      role_definition_ids = [
        "/providers/Microsoft.Authorization/roleDefinitions/056cd41c-7e88-42e1-933e-88ba6a50c9c3",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
      ]
    },

    # ── 10 ────────────────────────────────────────────────────────────────────
    # Deploy Threat Detection on SQL servers
    # Policy | DeployIfNotExists | GUID: 50ea7265-7d8c-429e-9a7d-ca1f410191c3
    {
      assignment_name     = "Deploy-SQL-ThrtDetection"
      display_name        = "Deploy Threat Detection on SQL servers"
      definition_id       = "50ea7265-7d8c-429e-9a7d-ca1f410191c3"
      type                = "policy"
      description         = "Enable Azure Defender on Azure SQL Servers to detect anomalous activities."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/fb1c8493-542b-48eb-b624-b4c8fea62acd"]
    },

    # ── 11 ────────────────────────────────────────────────────────────────────
    # Deploy SQL DB Transparent Data Encryption (TDE)
    # Policy | DeployIfNotExists | GUID: 86a912f6-9a06-4e26-b447-11b16ba8659f
    {
      assignment_name     = "Deploy-SQL-TDE"
      display_name        = "Deploy TDE on SQL servers"
      definition_id       = "86a912f6-9a06-4e26-b447-11b16ba8659f"
      type                = "policy"
      description         = "Ensures that Transparent Data Encryption is enabled on SQL Servers."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/9b7fa17d-e63e-47b0-bb0a-15c516ac86ec"]
    },

    # ── COMPUTE ───────────────────────────────────────────────────────────────

    # ── 12 ────────────────────────────────────────────────────────────────────
    # Configure backup on VMs without a given tag
    # Policy | DeployIfNotExists | GUID: 98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86
    {
      assignment_name     = "Deploy-VM-Backup"
      display_name        = "Configure backup on VMs without a given tag to a new recovery services vault"
      definition_id       = "98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86"
      type                = "policy"
      description         = "Enforce backup for all VMs by deploying a recovery services vault in the same location and resource group."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c", "/providers/Microsoft.Authorization/roleDefinitions/5e467623-bb1f-42f4-a55d-6e525e11384b"]
    },

    # ── 13 ────────────────────────────────────────────────────────────────────
    # Subnets should be private
    # Policy | Audit (→ Deny when ready) | GUID: 7bca8353-aa3b-429b-904a-9229c4385837
    {
      assignment_name     = "Enforce-Subnet-Private"
      display_name        = "Subnets should be private"
      definition_id       = "7bca8353-aa3b-429b-904a-9229c4385837"
      type                = "policy"
      description         = "Ensure subnets are secure by default by preventing default outbound access."
      effect              = "Audit" # Change to "Deny" when ready to enforce
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── MONITORING (AMA) ──────────────────────────────────────────────────────

    # ── 14 ────────────────────────────────────────────────────────────────────
    # Enable Azure Monitor for VMs with AMA
    # Initiative | DeployIfNotExists | GUID: 924bfe3a-762f-40e7-86dd-5c8b95eb09e6
    {
      assignment_name = "Deploy-VM-Monitor-AMA"
      display_name    = "Enable Azure Monitor for VMs with AMA"
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
      identity_id   = var.user_assigned_identity_id
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
      ]
    },

    # ── 15 ────────────────────────────────────────────────────────────────────
    # Enable Azure Monitor for VMSS with AMA
    # Initiative | DeployIfNotExists | GUID: f5bf694c-cca7-4033-b883-3a23327d5485
    {
      assignment_name = "Deploy-VMSS-Monitor-AMA"
      display_name    = "Enable Azure Monitor for VMSS with AMA"
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
      identity_id   = var.user_assigned_identity_id
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
      ]
    },

    # ── 16 ────────────────────────────────────────────────────────────────────
    # Enable Azure Monitor for Hybrid VMs with AMA
    # Initiative | DeployIfNotExists | GUID: 2b00397d-c309-49c4-aa5a-f0b2c5bc6321
    {
      assignment_name = "Deploy-HybVM-Mntr-AMA"
      display_name    = "Enable Azure Monitor for Hybrid VMs with AMA"
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
      identity_id   = var.user_assigned_identity_id
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
      ]
    },

    # ── CHANGE TRACKING ───────────────────────────────────────────────────────

    # ── 17 ────────────────────────────────────────────────────────────────────
    # Enable ChangeTracking and Inventory for VMs
    # Initiative | DeployIfNotExists | GUID: 92a36f05-ebc9-4bba-9128-b47ad2ea3354
    {
      assignment_name = "Deploy-ChangeTracking-VM"
      display_name    = "Enable ChangeTracking and Inventory for VMs"
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
      identity_id   = var.user_assigned_identity_id
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9",
      ]
    },

    # ── 18 ────────────────────────────────────────────────────────────────────
    # Enable ChangeTracking and Inventory for VMSS
    # Initiative | DeployIfNotExists | GUID: c4a70814-96be-461c-889f-2b27429120dc
    {
      assignment_name = "Deploy-Chngtrck-VMSS"
      display_name    = "Enable ChangeTracking and Inventory for VMSS"
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
      identity_id   = var.user_assigned_identity_id
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/18d7d88d-d35e-4fb5-a5c3-7773c20a72d9",
      ]
    },

    # ── 19 ────────────────────────────────────────────────────────────────────
    # Enable ChangeTracking and Inventory for Arc-enabled VMs
    # Initiative | DeployIfNotExists | GUID: 53448c70-089b-4f52-8f38-89196d7f2de1
    {
      assignment_name = "Deploy-ChngTrck-Arc"
      display_name    = "Enable ChangeTracking and Inventory for Arc-enabled VMs"
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
      identity_id   = var.user_assigned_identity_id
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
      ]
    },

    # ── SECURITY ──────────────────────────────────────────────────────────────

    # ── 20 ────────────────────────────────────────────────────────────────────
    # Enable Defender for SQL on SQL VMs and Arc-enabled SQL Servers
    # Initiative | DeployIfNotExists | GUID: de01d381-bae9-4670-8870-786f89f49e26
    {
      assignment_name = "Deploy-DefenderSQL-AMA"
      display_name    = "Enable Defender for SQL on SQL VMs and Arc-enabled SQL Servers"
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
      identity_id   = var.user_assigned_identity_id
      role_definition_ids = ["/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa",
        "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c",
        "/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302",
        "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
        "/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c"
      ]
    },

    # ── 21 ────────────────────────────────────────────────────────────────────
    # Configure Guest Attestation on Trusted Launch enabled VMs
    # Initiative | DeployIfNotExists | GUID: 281d9e47-d14d-4f05-b8eb-18f2c4a034ff
    {
      assignment_name = "Deploy-TL-Attest"
      display_name    = "Configure Guest Attestation on Trusted Launch enabled VMs"
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
      "/providers/Microsoft.Authorization/roleDefinitions/e40ec5ca-96e0-45a2-b4ff-59039f2c2b59"]
    },
    ##############################################################################
    # modules/landing_zone_mg/main.tf
    # 8 Custom policies/initiatives assigned at the Landing Zones MG.
    ##############################################################################


    # ── 1 ─────────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Enforce-TLS-SSL"
      display_name        = "Deny or Deploy and append TLS requirements and SSL enforcement on resources without Encryption in transit"
      definition_id       = "Enforce-TLS-SSL-InTransit"
      type                = "custom_initiative"
      description         = "TLS/SSL enforcement on resources without encryption in transit."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = []
    },

    # ── 2 ─────────────────────────────────────────────────────────────────────
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

    # ── 3 ─────────────────────────────────────────────────────────────────────
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

    # ── 5 ─────────────────────────────────────────────────────────────────────
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
    # ── 7 ─────────────────────────────────────────────────────────────────────
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
    # ── 8 ─────────────────────────────────────────────────────────────────────
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
  assignments           = local.landing_zone_mg_policies
  custom_policy_ids     = var.custom_policy_ids
  custom_initiative_ids = var.custom_initiative_ids
}
