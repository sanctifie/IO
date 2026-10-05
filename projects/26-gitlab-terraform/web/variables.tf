variable "sg" {
  description = "ID du security group (sortie du module vpc)"
  type        = string
}

variable "sn" {
  description = "ID du subnet (sortie du module vpc)"
  type        = string
}

variable "key_name" {
  description = "Paire de clés EC2 (optionnelle)"
  type        = string
  default     = null
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
