variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "ssh_cidr" {
  description = "CIDR autorisé en SSH (ton IP en /32). Par défaut : documentation (aucun accès réel)"
  type        = string
  default     = "203.0.113.10/32"
}

variable "key_name" {
  description = "Paire de clés EC2 pour SSH (null = pas de clé)"
  type        = string
  default     = null
}
