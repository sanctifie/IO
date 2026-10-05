terraform {
  backend "s3" {
    bucket       = "io-tfstate-PRENOM" # ← ton bucket d'état
    key          = "projet-11/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # remplace la table DynamoDB "Lock-Files" (Terraform >= 1.10)
  }
  required_version = ">= 1.10"
  required_providers {
    aws = {
      version = "~> 5.0"
      source  = "hashicorp/aws"
    }
  }
}
