# locals {
#   _initiative_files = fileset("${path.module}/lib/initiatives", "*.json")
#   _policy_files     = fileset("${path.module}/lib/policies", "*.json")
#
#   _initiatives_decoded = {
#     for f in local._initiative_files :
#     trimsuffix(f, ".json") => jsondecode(
#       file("${path.module}/lib/initiatives/${f}")
#     )
#   }
#
#   _policies_decoded = {
#     for f in local._policy_files :
#     trimsuffix(f, ".json") => jsondecode(
#       file("${path.module}/lib/policies/${f}")
#     )
#   }
#
#   custom_initiatives = {
#     for k, v in local._initiatives_decoded :
#     k => try(v.properties, v)
#   }
#
#   custom_policies = {
#     for k, v in local._policies_decoded :
#     k => try(v.properties, v)
#   }
# }

locals {
  _initiative_files       = fileset("${path.module}/lib/initiatives", "*.json")
  _policy_files           = fileset("${path.module}/lib/policies", "*.json")
  _legacy_mg_scope_prefix = "/providers/Microsoft.Management/managementGroups/Tahaluf/providers/"
  _target_mg_scope_prefix = "/providers/Microsoft.Management/managementGroups/${var.management_group_name}/providers/"

  # _initiatives_decoded = {
  #   for f in local._initiative_files :
  #   trimsuffix(f, ".json") => jsondecode(
  #     # Replace [[ with [ so ARM parameter references work via Terraform
  #     replace(
  #       file("${path.module}/lib/initiatives/${f}"),
  #       "\"[[",
  #       "\"["
  #     )
  #   )
  # }

  _initiatives_decoded = {
    for f in local._initiative_files :
    trimsuffix(f, ".json") => jsondecode(
      replace(
        replace(
          replace(
            file("${path.module}/lib/initiatives/${f}"),
            "\"[[",
            "\"["
          ),
          local._legacy_mg_scope_prefix,
          local._target_mg_scope_prefix
        ),
        "NonProdManagementGroup",
        var.management_group_name
      )
    )
  }

  _policies_decoded = {
    for f in local._policy_files :
    trimsuffix(f, ".json") => jsondecode(
      replace(
        file("${path.module}/lib/policies/${f}"),
        "\"[[",
        "\"["
      )
    )
  }

  custom_initiatives = {
    for k, v in local._initiatives_decoded :
    k => try(v.properties, v)
  }

  custom_policies = {
    for k, v in local._policies_decoded :
    k => try(v.properties, v)
  }
}

resource "azurerm_policy_set_definition" "custom" {
  for_each = local.custom_initiatives

  name                = each.key
  display_name        = each.value.displayName
  description         = each.value.description
  policy_type         = "Custom"
  management_group_id = var.management_group_id
  metadata            = jsonencode(each.value.metadata)
  parameters          = jsonencode(each.value.parameters)

  dynamic "policy_definition_reference" {
    for_each = each.value.policyDefinitions
    content {
      policy_definition_id = policy_definition_reference.value.policyDefinitionId
      reference_id         = policy_definition_reference.value.policyDefinitionReferenceId
      parameter_values     = jsonencode(policy_definition_reference.value.parameters)
    }
  }

  depends_on = [azurerm_policy_definition.custom]
}

resource "azurerm_policy_definition" "custom" {
  for_each = local.custom_policies

  name                = each.key
  display_name        = each.value.displayName
  description         = each.value.description
  policy_type         = "Custom"
  mode                = try(each.value.mode, "All")
  management_group_id = var.management_group_id
  metadata            = jsonencode(try(each.value.metadata, {}))
  parameters          = jsonencode(try(each.value.parameters, {}))
  policy_rule         = jsonencode(try(each.value.policyRule, try(each.value.PolicyRule, {})))
}
