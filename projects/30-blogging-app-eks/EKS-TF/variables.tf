variable "aws_region" {
  description = "Région de déploiement"
  type        = string
}

variable "cluster_name" {
  description = "Nom du cluster EKS (repris dans le Jenkinsfile)"
  type        = string
  default     = "blogging-eks"
}

variable "cluster_version" {
  description = "Version Kubernetes : une version en support STANDARD (aws eks describe-cluster-versions --query 'clusterVersions[?versionStatus==`STANDARD_SUPPORT`].clusterVersion')"
  type        = string
  default     = "1.35"
}

variable "vpc_name" {
  description = "Nom du VPC du cluster"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR du VPC du cluster"
  type        = string
}

variable "public_subnets" {
  description = "CIDR des subnets publics (load balancers, NAT)"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR des subnets privés (nœuds)"
  type        = list(string)
}

variable "instance_type" {
  description = "Type d'instance des nœuds"
  type        = string
}

variable "capacity_type" {
  description = "SPOT (jusqu'à -70 %, reprenable par AWS) ou ON_DEMAND"
  type        = string
  default     = "SPOT"
}
