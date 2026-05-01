terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.38.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }

  # Keep the existing remote backend for stateful runs.
  # The GitHub workflow uses `-backend=false` so CI can validate and plan
  # without writing into this legacy storage account.
  # backend "azurerm" {
  #   resource_group_name  = "RG-TAH-UAEN-MGMT-TF-01"
  #   storage_account_name = "sttahuaentf01"
  #   container_name       = "terraform-state-files"
  #   key                  = "07-tah-azpolicy.tfstate"
  # }

}
provider "azurerm" {
  features {
    
  }
  subscription_id = "7b8f8a16-fc9d-49db-b186-7eff08883016"
}