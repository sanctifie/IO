provider "aws" {
  region  = var.region
  profile = var.aws_profile
  default_tags {
    tags = {
      Project   = "io-22-serverless"
      ManagedBy = "terraform"
    }
  }
}
