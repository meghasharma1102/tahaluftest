##############################################################################
# modules/management_mg/outputs.tf
##############################################################################

output "assignment_ids" {
  description = "Map of assignment_name => Azure resource ID for all Management MG assignments"
  value       = module.policy_assignment_engine.assignment_ids
}
