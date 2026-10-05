terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95" # le module EKS v20 exige aws >= 5.95 et < 6
    }
  }
}

provider "aws" {
  region = var.aws_region
}
