##############################################################################
# modules/policy_assignment_engine/outputs.tf
##############################################################################

output "assignment_ids" {
  description = "Map of assignment_name => Azure resource ID"
  value       = { for k, v in azurerm_management_group_policy_assignment.this : k => v.id }
}

output "assignment_principal_ids" {
  description = "Map of assignment_name => managed identity principal ID (null if no identity)"
  value = {
    for k, v in azurerm_management_group_policy_assignment.this : k => (
      length(v.identity) > 0 ? v.identity[0].principal_id : null
    )
  }
}
output "assignments_summary" {
  description = "Summary of all policy assignments made by this engine instance"
  value = {
    for k, v in azurerm_management_group_policy_assignment.this : k => {
      assignment_name      = v.name
      display_name         = v.display_name
      description          = v.description
      scope                = v.management_group_id
      policy_definition_id = v.policy_definition_id
      type                 = strcontains(v.policy_definition_id, "policySetDefinitions") ? "Initiative" : "Policy"
      enforcement_mode     = v.enforce ? "Default" : "DoNotEnforce"
      parameters           = v.parameters
    }
  }
}
# TEMPORARY — revert azurerm_subscription_policy_assignment → azurerm_management_group_policy_assignment when done
# output "assignment_ids" {
#   description = "Map of assignment_name => Azure resource ID"
#   value       = { for k, v in azurerm_subscription_policy_assignment.this : k => v.id }
# }

# output "assignment_principal_ids" {
#   description = "Map of assignment_name => managed identity principal ID (null if no identity)"
#   value = {
#     for k, v in azurerm_subscription_policy_assignment.this : k => (
#       length(v.identity) > 0 ? v.identity[0].principal_id : null
#     )
#   }
# }