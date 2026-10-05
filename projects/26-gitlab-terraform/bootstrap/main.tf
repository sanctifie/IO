# À appliquer UNE fois, en local, AVANT le reste : crée le bucket d'état (si tu n'en as pas déjà un).
#   cd bootstrap && terraform init && terraform apply -var bucket_name=io-tfstate-<prenom>
# Son propre état reste local (on ne range pas l'état du bucket dans le bucket lui-même).
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "bucket_name" {
  description = "Nom unique du bucket d'état"
  type        = string
}

resource "aws_s3_bucket" "state" {
  bucket = var.bucket_name
  lifecycle {
    prevent_destroy = true # protège l'état de toute l'infrastructure
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled" # permet de récupérer une version précédente de l'état
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Plus besoin de table DynamoDB : use_lockfile = true (Terraform >= 1.10) verrouille dans S3.
