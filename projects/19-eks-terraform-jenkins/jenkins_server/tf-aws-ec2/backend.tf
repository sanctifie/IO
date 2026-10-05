terraform {
  backend "s3" {
    bucket       = "io-tfstate-PRENOM" # ← ton bucket d'état (créé au projet 11)
    key          = "jenkins/terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true # verrou natif S3 (plus besoin de DynamoDB)
  }
}
