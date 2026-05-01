##############################################################################
# main.tf  (ROOT)
#
# Orchestrator. Calls each MG module conditionally based on boolean toggles.
# No policy logic lives here — all policy definitions are inside each module.
#
# Structure:
#   main.tf          ← you are here (calls modules)
#   variables.tf     ← all input variable declarations
#   terraform.tfvars ← your actual values (MG IDs, resource IDs, toggles)
#
#   modules/
#     policy_assignment_engine/   ← shared engine (creates all Azure resources)
#     intermediate_root_mg/       ← 10 policies
#     platform_mg/                ← 10 policies
#     landing_zone_mg/            ← 21 policies
#     landing_zone_corp_mg/       ←  3 policies
#     connectivity_mg/            ←  1 policy
#     identity_mg/                ←  1 policy
#     management_mg/              ←  0 policies (placeholder)
##############################################################################

##############################################################
# AMBA (Azure Monitor Baseline Alerts) Deployment
# Runs once when deploy_amba = true in terraform.tfvars
# Set back to false after first successful deployment
##############################################################
resource "null_resource" "amba_deployment" {
  count = var.deploy_amba ? 1 : 0

  triggers = {
    management_group_name = var.root_management_group_name
    resource_group_name   = var.amba_resource_group_name
    location              = var.amba_location
    alert_emails          = join(",", var.amba_alert_emails)
    subscription_id       = var.amba_management_subscription_id
    template_uri          = var.amba_template_uri
    param_uri             = var.amba_param_uri
    script_hash           = filesha256("${path.module}/AMBA_Initiative.ps1")
  }

  lifecycle {
    precondition {
      condition = alltrue([
        length(trimspace(var.root_management_group_name)) > 0,
        length(trimspace(var.amba_resource_group_name)) > 0,
        length(trimspace(var.amba_location)) > 0,
        length(var.amba_alert_emails) > 0,
        alltrue([for email in var.amba_alert_emails : length(trimspace(email)) > 0]),
        length(trimspace(var.amba_management_subscription_id)) > 0,
      ])
      error_message = "When deploy_amba is true, set root_management_group_name, amba_resource_group_name, amba_location, amba_alert_emails, and amba_management_subscription_id."
    }
  }

  provisioner "local-exec" {
    environment = {
      AMBA_MANAGEMENT_GROUP_NAME = var.root_management_group_name
      AMBA_RESOURCE_GROUP_NAME   = var.amba_resource_group_name
      AMBA_LOCATION              = var.amba_location
      AMBA_ALERT_EMAILS          = join(",", var.amba_alert_emails)
      AMBA_SUBSCRIPTION_ID       = var.amba_management_subscription_id
      AMBA_TEMPLATE_URI          = var.amba_template_uri
      AMBA_PARAM_URI             = var.amba_param_uri
    }
    command     = "${path.module}/AMBA_Initiative.ps1"
    interpreter = var.amba_interpreter
  }
}
# ─────────────────────────────────────────────────────────────────────────────
# MODULE: Intermediate Root MG
# Scope  : Intermediate Root (Parent Group) — Level 0
# Policies: 10
# Toggle : deploy_intermediate_root_mg
# ─────────────────────────────────────────────────────────────────────────────
module "intermediate_root_mg" {
  count                      = var.deploy_intermediate_root_mg ? 1 : 0
  source                     = "./modules/modules/intermediate_root_mg"
  scope                      = var.intermediate_root_mg_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  depends_on                 = [module.custom_policy_definitions, null_resource.amba_deployment]
  custom_initiative_ids      = module.custom_policy_definitions.initiative_ids
  custom_policy_ids          = module.custom_policy_definitions.policy_ids
}

# ─────────────────────────────────────────────────────────────────────────────
# MODULE: Platform MG
# Scope  : Platform MG — Level 1
# Policies: 10
# Toggle : deploy_platform_mg
# ─────────────────────────────────────────────────────────────────────────────
module "platform_mg" {
  count  = var.deploy_platform_mg ? 1 : 0
  source = "./modules/modules/platform_mg"

  scope                      = var.platform_mg_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  user_assigned_identity_id  = var.user_assigned_identity_id
  data_collection_rule_id    = var.data_collection_rule_id
  custom_initiative_ids      = module.custom_policy_definitions.initiative_ids
  custom_policy_ids          = module.custom_policy_definitions.policy_ids
  depends_on                 = [module.custom_policy_definitions, null_resource.amba_deployment]

}

# ─────────────────────────────────────────────────────────────────────────────
# MODULE: Landing Zone MG
# Scope  : Landing Zone (Application) MG — Level 1
# Policies: 21
# Toggle : deploy_landing_zone_mg
# ─────────────────────────────────────────────────────────────────────────────
module "landing_zone_mg" {
  count  = var.deploy_landing_zone_mg ? 1 : 0
  source = "./modules/modules/landing_zone_mg"

  scope                      = var.landing_zone_mg_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  ddos_protection_plan_id    = var.ddos_protection_plan_id
  user_assigned_identity_id  = var.user_assigned_identity_id
  data_collection_rule_id    = var.data_collection_rule_id
  depends_on                 = [module.custom_policy_definitions, null_resource.amba_deployment]
  custom_initiative_ids      = module.custom_policy_definitions.initiative_ids
  custom_policy_ids          = module.custom_policy_definitions.policy_ids
}

# ─────────────────────────────────────────────────────────────────────────────
# MODULE: Landing Zone Corp MG
# Scope  : Landing Zone/Corp MG — Level 2 (child of Landing Zone)
# Policies: 3 (Corp-specific, on top of inherited Landing Zone policies)
# Toggle : deploy_landing_zone_corp_mg
# ─────────────────────────────────────────────────────────────────────────────
module "landing_zone_corp_mg" {
  count                 = var.deploy_landing_zone_corp_mg ? 1 : 0
  source                = "./modules/modules/landing_zone_corp_mg"
  custom_initiative_ids = module.custom_policy_definitions.initiative_ids
  custom_policy_ids     = module.custom_policy_definitions.policy_ids
  depends_on            = [module.custom_policy_definitions, null_resource.amba_deployment]
  scope                 = var.landing_zone_corp_mg_id
}

# ─────────────────────────────────────────────────────────────────────────────
# MODULE: Connectivity MG
# Scope  : Connectivity MG — Level 2 (child of Platform)
# Policies: 1
# Toggle : deploy_connectivity_mg
# ─────────────────────────────────────────────────────────────────────────────
module "connectivity_mg" {
  count  = var.deploy_connectivity_mg ? 1 : 0
  source = "./modules/modules/connectivity_mg"

  scope                      = var.connectivity_mg_id
  ddos_protection_plan_id    = var.ddos_protection_plan_id
  root_management_group_name = var.root_management_group_name
  depends_on                 = [module.custom_policy_definitions, null_resource.amba_deployment]
}

# ─────────────────────────────────────────────────────────────────────────────
# MODULE: Identity MG
# Scope  : Identity MG — Level 2 (child of Platform)
# Policies: 1
# Toggle : deploy_identity_mg
# ─────────────────────────────────────────────────────────────────────────────
module "identity_mg" {
  count                      = var.deploy_identity_mg ? 1 : 0
  source                     = "./modules/modules/identity_mg"
  root_management_group_name = var.root_management_group_name
  custom_initiative_ids      = module.custom_policy_definitions.initiative_ids
  custom_policy_ids          = module.custom_policy_definitions.policy_ids

  scope      = var.identity_mg_id
  depends_on = [module.custom_policy_definitions, null_resource.amba_deployment]
}

# ─────────────────────────────────────────────────────────────────────────────
# MODULE: Management MG
# Scope  : Management MG — Level 2 (child of Platform)
# Policies: 0 (placeholder — add policies to the module when needed)
# Toggle : deploy_management_mg
# ─────────────────────────────────────────────────────────────────────────────
module "management_mg" {
  count                      = var.deploy_management_mg ? 1 : 0
  source                     = "./modules/modules/management_mg"
  root_management_group_name = var.root_management_group_name

  scope      = var.management_mg_id
  depends_on = [module.custom_policy_definitions, null_resource.amba_deployment]
}

module "custom_policy_definitions" {
  source                = "./modules/modules/custom_policies"
  management_group_id   = var.intermediate_root_mg_id
  management_group_name = var.root_management_group_name
  depends_on            = [null_resource.amba_deployment]
}
