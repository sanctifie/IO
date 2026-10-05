# Namespace Service Bus (le "serveur" qui héberge les files)
resource "azurerm_servicebus_namespace" "sbus" {
  name                = "${var.project}-${var.environment}-sbns" # doit être unique dans tout Azure
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  local_auth_enabled            = false # pas de clés SAS : accès uniquement par Entra ID (RBAC)
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  tags = local.tags
}

# Les deux files : même configuration → une seule ressource avec for_each (DRY)
resource "azurerm_servicebus_queue" "queues" {
  for_each     = toset(["queue01", "queue02"])
  name         = each.key
  namespace_id = azurerm_servicebus_namespace.sbus.id

  default_message_ttl                     = "P14D" # format ISO 8601 : 14 jours
  lock_duration                           = "PT1M" # 1 minute pour traiter un message
  duplicate_detection_history_time_window = "PT10M"
  max_delivery_count                      = 10 # après 10 échecs → file des messages morts
  max_size_in_megabytes                   = 1024
  dead_lettering_on_message_expiration    = false
  requires_duplicate_detection            = false
  requires_session                        = false
  # azurerm v4 : enable_batched_operations → batched_operations_enabled, enable_partitioning → partitioning_enabled
  batched_operations_enabled = true
  partitioning_enabled       = false
}

output "servicebus_namespace" {
  value = azurerm_servicebus_namespace.sbus.name
}

output "queues" {
  value = [for q in azurerm_servicebus_queue.queues : q.name]
}
