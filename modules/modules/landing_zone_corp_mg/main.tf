##############################################################################
# modules/landing_zone_corp_mg/main.tf
#
# 3 Corp-specific policies assigned at the Landing Zone/Corp MG level.
# Corp inherits all 21 Landing Zone policies from its parent.
# These 3 are ADDITIONAL Corp-only restrictions.
#
# Sheet: Assignment Scope = "Landing Zones/Corp"
#
# Count breakdown:
#   Policies (3): Deny-Public-IP-On-NIC, Audit-PrivateLink-DNS-Zones,
#                 Deny-Hybrid-Networking
##############################################################################

locals {
  landing_zone_corp_mg_policies = [

    # ── 1 ─────────────────────────────────────────────────────────────────────
    # Deny network interfaces having a public IP associated
    # Policy | Deny | GUID: 83a86a26-fd1f-447c-b59d-e51f44264114
    {
      assignment_name     = "Deny-Public-IP-On-NIC"
      display_name        = "Deny network interfaces having a public IP associated"
      definition_id       = "83a86a26-fd1f-447c-b59d-e51f44264114"
      type                = "policy"
      description         = "Denies network interfaces from having a public IP associated in the Corp landing zone."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 2 ─────────────────────────────────────────────────────────────────────
    # Audit the creation of Private Link Private DNS Zones
    # Policy | Audit
    # NOTE: This is an ALZ pattern policy. Replace "Audit-PrivateLinkDnsZones"
    #       with the actual GUID if available in your tenant.
    # {
    #   assignment_name     = "Audit-PrivateLink-DNS-Zones"
    #   display_name        = "Audit the creation of Private Link Private DNS Zones"
    #   definition_id       = "Audit-PrivateLinkDnsZones"
    #   type                = "policy"
    #   description         = "Audits the deployment of Private Link Private DNS Zone resources in the Corp landing zone."
    #   effect              = "Audit"
    #   scope               = var.scope
    #   parameters          = jsonencode({})
    #   identity_type       = "None"
    #   role_definition_ids = []
    # },

    # ── 3 ─────────────────────────────────────────────────────────────────────
    # Deny the deployment of vWAN/ER/VPN gateway resources
    # Policy | Deny | GUID: 6c112d4e-5bc7-47ae-a041-ea2d9dccd749
    {
      assignment_name = "Deny-Hybrid-Networking"
      display_name    = "Deny the deployment of vWAN/ER/VPN gateway resources"
      definition_id   = "6c112d4e-5bc7-47ae-a041-ea2d9dccd749"
      type            = "policy"
      description     = "Denies deployment of vWAN/ER/VPN gateway resources in the Corp landing zone to prevent bypassing centralized connectivity."
      effect          = "Deny"
      scope           = var.scope
      parameters = jsonencode({
        listOfResourceTypesNotAllowed = { value = ["microsoft.network/expressroutegateways,microsoft.network/expressrouteports,microsoft.network/virtualwans,microsoft.network/vpngateways,microsoft.network/p2svpngateways"] } }
      )
      identity_type       = "None"
      role_definition_ids = []
    },
    #--CUSTOM POLICY--
    # ── 1 ─────────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Deny-PublicEndpoints"
      display_name        = "Public network access should be disabled for PaaS services"
      definition_id       = "Public network access should be disabled for PaaS services"
      type                = "custom_initiative"
      description         = "Prevents creation of Azure PaaS services with exposed public endpoints."
      effect              = "Deny"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "None"
      role_definition_ids = []
    },

    # ── 2 ─────────────────────────────────────────────────────────────────────
    {
      assignment_name     = "Deploy-PAASPrivateDNS"
      display_name        = "Configure Azure PaaS services to use private DNS zones"
      definition_id       = "Configure Azure PaaS services to use private DNS zones"
      type                = "custom_initiative"
      description         = "Ensures private endpoints to Azure PaaS services are integrated with Azure Private DNS zones."
      effect              = "DeployIfNotExists"
      scope               = var.scope
      parameters          = jsonencode({})
      identity_type       = "SystemAssigned"
      role_definition_ids = []
    },

  ]
}

module "policy_assignment_engine" {
  source                = "../policy_assignment_engine"
  assignments           = local.landing_zone_corp_mg_policies
  custom_policy_ids     = var.custom_policy_ids
  custom_initiative_ids = var.custom_initiative_ids
}
