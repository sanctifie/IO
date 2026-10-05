# cd common/terraform-lab && terraform apply -var-file=../../projects/13-zomato-devsecops/infra.tfvars -state=io-13.tfstate
project = "io-13"
my_ip   = "203.0.113.10/32" # ← ton IP
servers = {
  jenkins = { type = "t3.large", disk = 30 }
}
open_ports     = [8080, 9000, 3000]
open_nodeports = false
