output "policy_ids" {
  value = {
    for k, v in azurerm_policy_definition.custom : k => {
      name                = v.name
      id                  = v.id
      role_definition_ids = try(local.custom_policies[k].policyRule.then.details.roleDefinitionIds, [])
    }
  }
}

output "initiative_ids" {
  value = {
    for k, v in azurerm_policy_set_definition.custom : k => {
      name = v.name
      id   = v.id
      role_definition_ids = distinct(flatten([
        for pd in local.custom_initiatives[k].policyDefinitions :
        try(
          local.custom_policies[
            reverse(split("/", pd.policyDefinitionId))[0]
          ].policyRule.then.details.roleDefinitionIds,
          []
        )
      ]))
    }
  }
}