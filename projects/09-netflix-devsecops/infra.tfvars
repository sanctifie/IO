# cd common/terraform-lab && terraform apply -var-file=../../projects/09-netflix-devsecops/infra.tfvars -state=io-09.tfstate
project = "io-09"
my_ip   = "203.0.113.10/32" # ← ton IP
servers = {
  netflix    = { type = "t3.large", disk = 30 }
  monitoring = { type = "t3.medium", disk = 20 }
  k8s-master = { type = "t3.medium", disk = 20 }
  k8s-worker = { type = "t3.medium", disk = 20 }
}
open_ports     = [8080, 9000, 8081, 9090, 3000]
open_nodeports = true
