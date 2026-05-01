##############################################################################
# terraform.tfvars  (ROOT)
#
# This is the ONLY file you need to edit for deployments.
# Set the boolean toggles and fill in your resource IDs.
##############################################################################

# DEPLOYMENT TOGGLES
# true  = deploy all policies for that MG scope
# false = skip that MG entirely (no Azure changes)

deploy_intermediate_root_mg = true
deploy_platform_mg          = false # Disabled for the Delphi test run until a real user_assigned_identity_id is available.
deploy_landing_zone_mg      = false # Disabled for the Delphi test run until real DDoS and AMA identity values are available.
deploy_landing_zone_corp_mg = true
deploy_connectivity_mg      = false # Disabled for the Delphi test run until a real ddos_protection_plan_id is available.
deploy_identity_mg          = true
deploy_management_mg        = true

# MANAGEMENT GROUP RESOURCE IDs
# Replace the placeholder names with your actual management group names.

deploy_amba = false # Leave false for now; AMBA still needs Delphi-specific RG/location values.

# AMBA settings - keep these ready, but update the commented RG/location values
# before turning deploy_amba on for the Delphi environment.
amba_interpreter = ["pwsh", "-NoLogo", "-NoProfile", "-NonInteractive", "-File"]
# amba_resource_group_name = "RG-DELPHI-<replace-with-management-rg>"
# amba_location            = "<replace-with-azure-region>"
amba_alert_emails               = ["MSharma@delphime.com"]
amba_management_subscription_id = "7b8f8a16-fc9d-49db-b186-7eff08883016"

intermediate_root_mg_id    = "/providers/Microsoft.Management/managementGroups/DELPHI_CTS_DEV_02"
platform_mg_id             = "/providers/Microsoft.Management/managementGroups/Platform"
landing_zone_mg_id         = "/providers/Microsoft.Management/managementGroups/Application"
landing_zone_corp_mg_id    = "/providers/Microsoft.Management/managementGroups/Production"
connectivity_mg_id         = "/providers/Microsoft.Management/managementGroups/Connectivity"
identity_mg_id             = "/providers/Microsoft.Management/managementGroups/Identity"
management_mg_id           = "/providers/Microsoft.Management/managementGroups/Management"
root_management_group_name = "DELPHI_CTS_DEV_02"

# SHARED RESOURCE IDs

log_analytics_workspace_id = "/subscriptions/7b8f8a16-fc9d-49db-b186-7eff08883016/resourceGroups/DefaultResourceGroup-DXB/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-7b8f8a16-fc9d-49db-b186-7eff08883016-DXB"
# ddos_protection_plan_id  = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Network/ddosProtectionPlans/<ddos-plan-name>"
# user_assigned_identity_id = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity-name>"
# data_collection_rule_id   = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Insights/dataCollectionRules/<dcr-name>"
