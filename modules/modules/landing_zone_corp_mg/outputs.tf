##############################################################################
# modules/landing_zone_corp_mg/outputs.tf
##############################################################################

output "assignment_ids" {
  description = "Map of assignment_name => Azure resource ID for all Landing Zone/Corp MG assignments"
  value       = module.policy_assignment_engine.assignment_ids
}
