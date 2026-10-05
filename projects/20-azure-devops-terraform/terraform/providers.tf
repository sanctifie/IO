terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  # La clé (key) est fournie à l'init : -backend-config="key=tfdemo.env01.tfstate"
  # → un fichier d'état distinct par environnement, avec le même code.
  backend "azurerm" {
    resource_group_name  = "tfstate-tfdemo-rg"
    storage_account_name = "tfstatetfdemoREMPLACER" # ← le nom de TON storage account
    container_name       = "tfstate"
    use_azuread_auth     = true # authentification Entra ID au lieu de la clé du storage
  }
}

provider "azurerm" {
  features {}
  # azurerm v4 : subscription_id obligatoire, lu dans la variable d'environnement ARM_SUBSCRIPTION_ID
}
