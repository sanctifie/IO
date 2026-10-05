variable "aws_region" {
  description = "Région de déploiement"
  type        = string
}

variable "vpc_name" {
  description = "Nom du VPC du serveur Jenkins"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR du VPC du serveur Jenkins"
  type        = string
}

variable "public_subnets" {
  description = "CIDR des subnets publics"
  type        = list(string)
}

variable "instance_type" {
  description = "Type d'instance du serveur Jenkins"
  type        = string
}

variable "jenkins_security_group" {
  description = "Nom du security group"
  type        = string
}

variable "jenkins_ec2_instance" {
  description = "Nom de l'instance EC2"
  type        = string
}

variable "key_name" {
  description = "Nom de la paire de clés EC2 (créée dans la console ou avec aws ec2 create-key-pair)"
  type        = string
}

variable "my_ip_cidr" {
  description = "Ton IP publique en /32 pour SSH (curl -s https://checkip.amazonaws.com)"
  type        = string
}
