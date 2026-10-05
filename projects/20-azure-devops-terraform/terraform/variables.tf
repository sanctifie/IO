variable "project" {
  type        = string
  description = "Nom du projet, ex. tfdemo"
}

variable "environment" {
  type        = string
  description = "Nom de l'environnement, ex. env01, env02"
}

variable "location" {
  type        = string
  description = "Région Azure, ex. francecentral"
}

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
