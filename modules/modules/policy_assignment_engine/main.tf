##############################################################################
# modules/policy_assignment_engine/main.tf
#
# THE ONLY PLACE Azure policy resources are created.
# All MG modules pass their assignment lists here — zero duplication.
#
# Step 1 → Data lookups  : resolve GUIDs to full Azure definition resource IDs
# Step 2 → Assignments   : create azurerm_management_group_policy_assignment
# Step 3 → Role assigns  : create azurerm_role_assignment for DINE/Modify
##############################################################################

# ── Step 1a: Resolve built-in Policy definitions ──────────────────────────────
data "azurerm_policy_definition" "builtin_policy" {
  for_each = {
    for a in var.assignments : a.assignment_name => a
    if a.type == "policy"
  }
  name = each.value.definition_id
}

# ── Step 1b: Resolve built-in Initiative (PolicySet) definitions ──────────────
data "azurerm_policy_set_definition" "builtin_initiative" {
  for_each = {
    for a in var.assignments : a.assignment_name => a
    if a.type == "initiative"
  }
  name = each.value.definition_id
}

# ── Step 2: Create one assignment per item in the list ────────────────────────
resource "azurerm_management_group_policy_assignment" "this" {
  for_each = { for a in var.assignments : a.assignment_name => a }

  name                = each.value.assignment_name
  display_name        = each.value.display_name
  description         = each.value.description
  management_group_id = each.value.scope
  location            = "uaenorth"

  # policy_definition_id = each.value.type == "policy" ? (
  #   data.azurerm_policy_definition.builtin_policy[each.key].id
  # ) : (
  #   data.azurerm_policy_set_definition.builtin_initiative[each.key].id
  # )

  policy_definition_id = (
    each.value.type == "policy" ? data.azurerm_policy_definition.builtin_policy[each.key].id
    : each.value.type == "initiative" ? data.azurerm_policy_set_definition.builtin_initiative[each.key].id
    : each.value.type == "custom_policy" ? var.custom_policy_ids[each.value.definition_id].id
    : each.value.type == "custom_initiative" ? var.custom_initiative_ids[each.value.definition_id].id
    : each.value.definition_id
  )

  # parameters = length(each.value.parameters) > 0 ? jsonencode(
  #   { for k, v in each.value.parameters : k => { value = v } }
  # ) : null
  parameters = each.value.parameters != "" ? each.value.parameters : null
  # Identity block — only rendered when identity_type is not "None"
  dynamic "identity" {
    for_each = each.value.identity_type != "None" ? [each.value.identity_type] : []
    content {
      type         = identity.value
      identity_ids = identity.value == "UserAssigned" ? [each.value.identity_id] : null
    }
  }
}
# resource "azurerm_subscription_policy_assignment" "this" {
#   for_each = { for a in var.assignments : a.assignment_name => a }

#   name                = each.value.assignment_name
#   display_name        = each.value.display_name
#   description         = each.value.description
#   subscription_id     = each.value.scope
#   location            = "uaenorth"

#   policy_definition_id = each.value.type == "policy" ? (
#     data.azurerm_policy_definition.builtin_policy[each.key].id
#   ) : (
#     data.azurerm_policy_set_definition.builtin_initiative[each.key].id
#   )

#   parameters = length(each.value.parameters) > 0 ? jsonencode(
#     { for k, v in each.value.parameters : k => { value = v } }
#   ) : null

#   # Identity block — only rendered when identity_type is not "None"
#   dynamic "identity" {
#     for_each = each.value.identity_type != "None" ? [each.value.identity_type] : []
#     content {
#       type         = identity.value
#       identity_ids = identity.value == "UserAssigned" ? [each.value.identity_id] : null
#     }
#   }
# }
# ── Step 3: Role assignments for DINE / Modify remediation ───────────────────
# locals {
#   role_records = flatten([
#     for a in var.assignments : [
#       for role_id in a.role_definition_ids : {
#         key             = "${a.assignment_name}--${replace(role_id, "/", "-")}"
#         assignment_name = a.assignment_name
#         scope           = a.scope
#         role_id         = role_id
#         identity_type   = a.identity_type
#         identity_id     = a.identity_id
#       }
#     ]
#     if length(a.role_definition_ids) > 0 && a.identity_type != "None"
#   ])
# }

locals {
  role_records = flatten([
    for a in var.assignments : [
      for role_id in(
        a.type == "custom_policy" ? try(var.custom_policy_ids[a.definition_id].role_definition_ids, a.role_definition_ids)
        : a.type == "custom_initiative" ? try(var.custom_initiative_ids[a.definition_id].role_definition_ids, a.role_definition_ids)
        : a.role_definition_ids
        ) : {
        key             = "${a.assignment_name}--${replace(role_id, "/", "-")}"
        assignment_name = a.assignment_name
        scope           = a.scope
        role_id         = role_id
        identity_type   = a.identity_type
        identity_id     = a.identity_id
      }
    ]
    if a.identity_type != "None"
  ])
}

data "azurerm_user_assigned_identity" "lookup" {
  for_each = {
    for a in var.assignments : a.assignment_name => a
    if a.identity_type == "UserAssigned" && length(a.role_definition_ids) > 0
  }
  name                = regex("[^/]+$", each.value.identity_id)
  resource_group_name = regex("/resourceGroups/([^/]+)/", each.value.identity_id)[0]
}

resource "azurerm_role_assignment" "remediation" {
  for_each = { for r in local.role_records : r.key => r }

  scope              = each.value.scope
  role_definition_id = each.value.role_id

  principal_id = each.value.identity_type == "UserAssigned" ? (
    data.azurerm_user_assigned_identity.lookup[each.value.assignment_name].principal_id
    ) : (
    azurerm_management_group_policy_assignment.this[each.value.assignment_name].identity[0].principal_id
  )

  depends_on = [azurerm_management_group_policy_assignment.this]
}

# resource "azurerm_role_assignment" "remediation" {
#   for_each = { for r in local.role_records : r.key => r }

#   scope              = each.value.scope
#   role_definition_id = each.value.role_id

#   principal_id = each.value.identity_type == "UserAssigned" ? (
#     data.azurerm_user_assigned_identity.lookup[each.value.assignment_name].principal_id
#   ) : (
#     azurerm_subscription_policy_assignment.this[each.value.assignment_name].identity[0].principal_id
#   )

#   depends_on = [azurerm_subscription_policy_assignment.this]
# }