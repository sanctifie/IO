variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "aws_profile" {
  description = "Profil AWS CLI local (null en CI : les identifiants viennent d'OIDC)"
  type        = string
  default     = null
}

variable "name" {
  description = "Préfixe des noms de ressources"
  type        = string
  default     = "dev"
}

variable "cidr_block" {
  type    = string
  default = "10.20.0.0/16"
}

variable "private_subnets" {
  type    = number
  default = 2
}

variable "artifact_location" {
  description = "Zip de la Lambda, relatif à ce dossier (construit par npm ci --omit=dev && zip)"
  type        = string
  default     = "serverless-api.zip"
}

variable "domain" {
  description = "Domaine personnalisé (ex. api.exemple.com) ; vide = pas de domaine, URL API Gateway"
  type        = string
  default     = ""
}

variable "api_stage" {
  type    = string
  default = "v1"
}
