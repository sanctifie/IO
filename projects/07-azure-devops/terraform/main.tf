locals {
  tags = { Environment = var.environment, Project = "io-07" }
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.location
  tags     = local.tags
}

# ---------- Réseau ----------
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.7.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.7.0.0/20"]
}

# ---------- Observabilité ----------
resource "azurerm_log_analytics_workspace" "la" {
  name                = "${var.name}-la"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_application_insights" "ai" {
  name                = var.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.la.id
  application_type    = "web"
  tags                = local.tags
}

# ---------- Registre ----------
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false # AKS tire les images avec son identité (AcrPull), pas avec un mot de passe
  tags                = local.tags
}

# ---------- Cluster AKS ----------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name}aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.name}aks"
  node_resource_group = "${var.name}aks-node-rg"

  default_node_pool {
    name           = "agentpool"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.70.0.0/16"
    dns_service_ip    = "10.70.0.10"
  }

  # Authentification Entra ID : les membres du groupe admin administrent le cluster avec kubectl
  azure_active_directory_role_based_access_control {
    admin_group_object_ids = [var.aks_admin_group_object_id]
    azure_rbac_enabled     = false
  }

  # Container Insights (logs et métriques des conteneurs dans Log Analytics)
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  }

  tags = local.tags
}

# Les NŒUDS (identité kubelet) peuvent tirer les images de l'ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}

# ---------- Coffre à secrets ----------
resource "azurerm_key_vault" "kv" {
  name                       = var.keyvault_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = false
  tags                       = local.tags
}

# Le pipeline (identité courante) et le groupe admin peuvent gérer les secrets
resource "azurerm_role_assignment" "kv_pipeline" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "kv_admins" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.aks_admin_group_object_id
}

# La clé Application Insights est rangée directement dans le Key Vault (plus besoin de la copier à la main)
resource "azurerm_key_vault_secret" "aikey" {
  name         = "AIKEY"
  value        = azurerm_application_insights.ai.connection_string
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_pipeline]
}
