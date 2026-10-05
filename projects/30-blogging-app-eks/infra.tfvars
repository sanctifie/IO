# cd common/terraform-lab && terraform apply -var-file=../../projects/30-blogging-app-eks/infra.tfvars -state=io-30.tfstate
project = "io-30"
my_ip   = "203.0.113.10/32" # ← ton IP
servers = {
  jenkins    = { type = "t3.large", disk = 30 }
  sonarqube  = { type = "t3.medium", disk = 20 }
  nexus      = { type = "t3.medium", disk = 20 }
  monitoring = { type = "t3.medium", disk = 25 }
}
open_ports     = [8080, 9000, 8081, 9090, 9115, 3000]
open_nodeports = false
