provider "aws" {
  region = var.REGION
  default_tags { tags = { Project = "io-11" } }
}
