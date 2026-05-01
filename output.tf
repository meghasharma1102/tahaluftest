##############################################################################
# outputs.tf — All policy assignments across all MG modules
##############################################################################

output "all_policy_assignments" {
  description = "All policy assignments across all management groups"
  value = merge(
    # Intermediate Root MG
    try(module.intermediate_root_mg[0].module.policy_assignment_engine.assignments_summary, {}),

    # Landing Zone MG
    try(module.landing_zone_mg[0].module.policy_assignment_engine.assignments_summary, {}),

    # Landing Zone Corp MG
    try(module.landing_zone_corp_mg[0].module.policy_assignment_engine.assignments_summary, {}),

    # Platform MG
    try(module.platform_mg[0].module.policy_assignment_engine.assignments_summary, {}),

    # Connectivity MG
    try(module.connectivity_mg[0].module.policy_assignment_engine.assignments_summary, {}),

    # Management MG
    try(module.management_mg[0].module.policy_assignment_engine.assignments_summary, {}),

    # Identity MG
    try(module.identity_mg[0].module.policy_assignment_engine.assignments_summary, {}),
  )
}