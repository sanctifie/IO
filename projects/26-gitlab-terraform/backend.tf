terraform {
  # Configuration PARTIELLE : les valeurs viennent de tfstate.config
  #   terraform init -backend-config=tfstate.config
  # (un bloc backend ne peut pas utiliser de variables Terraform)
  backend "s3" {}
}
