terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  # Décommente pour stocker l'état dans S3 (bible, leçon 10)
  # backend "s3" {
  #   bucket       = "io-tfstate-<prenom>"
  #   key          = "projet-02/terraform.tfstate"
  #   region       = "eu-west-3"
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.region
  default_tags { tags = { Project = "io-02", ManagedBy = "terraform" } }
}
