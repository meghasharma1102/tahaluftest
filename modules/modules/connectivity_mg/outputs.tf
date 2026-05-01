##############################################################################
# modules/connectivity_mg/outputs.tf
##############################################################################

output "assignment_ids" {
  description = "Map of assignment_name => Azure resource ID for all Connectivity MG assignments"
  value       = module.policy_assignment_engine.assignment_ids
}
