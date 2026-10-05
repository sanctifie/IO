terraform {
  backend "s3" {
    bucket       = "io-tfstate-PRENOM" # ← ton bucket d'état
    key          = "eks/terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true
  }
}
