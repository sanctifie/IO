# cd common/terraform-lab && terraform apply -var-file=../../projects/25-petshop-ansible/infra.tfvars -state=io-25.tfstate
project = "io-25"
my_ip   = "203.0.113.10/32" # ← ton IP
servers = {
  jenkins    = { type = "t3.large", disk = 30 }
  k8s-master = { type = "t3.medium", disk = 20 }
  k8s-worker = { type = "t3.medium", disk = 20 }
}
open_ports     = [8080, 9000, 8081]
open_nodeports = true
