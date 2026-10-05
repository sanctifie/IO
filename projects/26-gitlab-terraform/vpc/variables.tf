# (Le fichier d'origine contenait par erreur la création du bucket d'état : déplacée dans bootstrap/)
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "ssh_cidr" {
  description = "CIDR autorisé en SSH"
  type        = string
}
