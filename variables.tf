##############################################################################
# variables.tf  (ROOT)
#
# All input variables for the root module.
# Values are supplied via terraform.tfvars
##############################################################################

# ─── DEPLOYMENT TOGGLE FLAGS ─────────────────────────────────────────────────
# true  → module runs, Azure policy assignments are created
# false → module is skipped entirely, zero changes to Azure

variable "deploy_intermediate_root_mg" {
  type        = bool
  default     = false
  description = "Deploy 10 policies to the Intermediate Root (Parent Group) MG"
}

variable "deploy_platform_mg" {
  type        = bool
  default     = false
  description = "Deploy 10 policies to the Platform MG"
}

variable "deploy_landing_zone_mg" {
  type        = bool
  default     = false
  description = "Deploy 21 policies to the Landing Zone MG"
}

variable "deploy_landing_zone_corp_mg" {
  type        = bool
  default     = false
  description = "Deploy 3 Corp-specific policies to the Landing Zone/Corp MG"
}

variable "deploy_connectivity_mg" {
  type        = bool
  default     = false
  description = "Deploy 1 policy to the Connectivity MG (child of Platform)"
}

variable "deploy_identity_mg" {
  type        = bool
  default     = false
  description = "Deploy 1 policy to the Identity MG (child of Platform)"
}

variable "deploy_management_mg" {
  type        = bool
  default     = false
  description = "Deploy policies to the Management MG — placeholder, no policies yet"
}

variable "deploy_amba" {
  type        = bool
  default     = false
  description = "Deploy Azure Monitor Baseline Alerts before the management group policy assignments"
}

variable "amba_interpreter" {
  type        = list(string)
  default     = ["PowerShell", "-ExecutionPolicy", "Bypass", "-File"]
  description = "Interpreter used to execute the AMBA helper script. Override this to pwsh on Linux runners."
}

##CUSTOM-POLICY VARIABLES

variable "custom_policy_ids" {
  type    = map(object({ name = string, id = string }))
  default = {}
}

variable "custom_initiative_ids" {
  type    = map(object({ name = string, id = string }))
  default = {}
}

# ─── MANAGEMENT GROUP RESOURCE IDs ───────────────────────────────────────────
# Format: /providers/Microsoft.Management/managementGroups/<mg-name>

variable "intermediate_root_mg_id" {
  type        = string
  description = "Resource ID of the Intermediate Root (Parent Group) Management Group"
}

variable "platform_mg_id" {
  type        = string
  description = "Resource ID of the Platform Management Group"
}

variable "landing_zone_mg_id" {
  type        = string
  description = "Resource ID of the Landing Zone (Application) Management Group"
}

variable "landing_zone_corp_mg_id" {
  type        = string
  description = "Resource ID of the Landing Zone/Corp Management Group"
}

variable "connectivity_mg_id" {
  type        = string
  description = "Resource ID of the Connectivity Management Group (child of Platform)"
}

variable "identity_mg_id" {
  type        = string
  description = "Resource ID of the Identity Management Group (child of Platform)"
}

variable "management_mg_id" {
  type        = string
  description = "Resource ID of the Management Management Group (child of Platform)"
}

variable "root_management_group_name" {
  description = "Short name of the intermediate root management group (e.g. 'myorg')"
  type        = string
}

# ─── SHARED RESOURCE IDs ─────────────────────────────────────────────────────
# Pre-existing Azure resources referenced by DINE / Modify policies

variable "amba_resource_group_name" {
  type        = string
  default     = ""
  description = "Resource group name used by the AMBA deployment"
}

variable "amba_location" {
  type        = string
  default     = ""
  description = "Azure region used by the AMBA management group deployment"
}

variable "amba_alert_emails" {
  type        = list(string)
  default     = []
  description = "Alert email recipients for the AMBA action group"
}

variable "amba_management_subscription_id" {
  type        = string
  default     = ""
  description = "Subscription ID that AMBA should use for management-scoped resources"
}

variable "amba_template_uri" {
  type        = string
  default     = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/2025-10-01/patterns/alz/alzArm.json"
  description = "Template URI for the AMBA management group deployment"
}

variable "amba_param_uri" {
  type        = string
  default     = "https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/2025-10-01/patterns/alz/alzArm.param.json"
  description = "Parameter file URI for the AMBA management group deployment"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Resource ID of the central Log Analytics Workspace"
}

variable "ddos_protection_plan_id" {
  type        = string
  default     = ""
  description = "Resource ID of the Azure DDoS Protection Plan"
}

variable "user_assigned_identity_id" {
  type        = string
  default     = ""
  description = "Resource ID of the User Assigned Managed Identity used by AMA policies"
}

variable "data_collection_rule_id" {
  type        = string
  default     = ""
  description = "Resource ID of the Data Collection Rule used by ChangeTracking and Defender SQL policies"
}
