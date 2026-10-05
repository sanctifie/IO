variable "project" {
  description = "Préfixe des noms, ex. io-25"
  type        = string
}

variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "my_ip" {
  description = "Ton IP publique en /32 (curl -s https://checkip.amazonaws.com)"
  type        = string
}

variable "key_name" {
  description = "Paire de clés EC2 existante"
  type        = string
  default     = "io-key"
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "servers" {
  description = "Machines à créer : nom => { type, disk (Go) }"
  type = map(object({
    type = string
    disk = number
  }))
}

variable "open_ports" {
  description = "Ports TCP ouverts depuis my_ip (en plus de 22)"
  type        = list(number)
  default     = []
}

variable "open_nodeports" {
  description = "Ouvre 30000-32767 depuis my_ip (Services NodePort)"
  type        = bool
  default     = false
}
