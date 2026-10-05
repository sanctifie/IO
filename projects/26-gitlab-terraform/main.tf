# Racine : relie les modules. Les SORTIES du module vpc deviennent les ENTRÉES du module web.
module "vpc" {
  source   = "./vpc"
  ssh_cidr = var.ssh_cidr
}

module "ec2" {
  source   = "./web"
  sn       = module.vpc.pb_sn
  sg       = module.vpc.sg
  key_name = var.key_name
}

output "server_public_ip" {
  value = module.ec2.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/<ta-cle>.pem ubuntu@${module.ec2.public_ip}"
}
