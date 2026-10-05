variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "my_ip_cidr" {
  description = "Ton IP publique en /32 (accès SSH au bastion). Ex : 82.64.10.5/32"
  type        = string
}

variable "key_name" {
  description = "Nom de la key pair EC2 existante"
  type        = string
  default     = "io-key"
}

variable "golden_ami_id" {
  description = "ID de ta Golden AMI (io-golden-web-v1). Vide = Amazon Linux 2023 + installation d'Apache au démarrage."
  type        = string
  default     = ""
}

variable "repo_url" {
  description = "Dépôt Git contenant projects/02-vpc/app (public)"
  type        = string
}

variable "config_bucket_name" {
  description = "Nom unique au monde du bucket de configuration"
  type        = string
}

variable "domain_zone" {
  description = "Zone Route 53 existante (ex : exemple.com). Vide = pas d'enregistrement DNS."
  type        = string
  default     = ""
}
