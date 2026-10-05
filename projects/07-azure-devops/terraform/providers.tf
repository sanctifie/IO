terraform {
  required_version = ">= 1.10"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
  # Valeurs fournies par la tâche TerraformTaskV4 du pipeline (backendAzureRm*)
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  # subscription_id : variable d'environnement ARM_SUBSCRIPTION_ID (fournie par la service connection)
}

data "azurerm_client_config" "current" {}
