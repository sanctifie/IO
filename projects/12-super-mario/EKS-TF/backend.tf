terraform {
  backend "s3" {
    bucket       = "io-tfstate-PRENOM" # ← ton bucket d'état (bible, leçon 10)
    key          = "EKS/terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true
  }
}
