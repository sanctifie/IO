variable "name" {
  description = "Préfixe des ressources (minuscules)"
  type        = string
  default     = "devopsjourney"
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "acr_name" {
  description = "Nom UNIQUE AU MONDE de l'ACR (lettres et chiffres)"
  type        = string
}

variable "keyvault_name" {
  description = "Nom UNIQUE AU MONDE du Key Vault (3-24 caractères)"
  type        = string
}

variable "aks_admin_group_object_id" {
  description = "ID du groupe Entra devopsthehardway-aks-group (lab 1.4)"
  type        = string
}

variable "node_count" {
  type    = number
  default = 1
}

variable "node_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "environment" {
  type    = string
  default = "production"
}
