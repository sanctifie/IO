# Correctif : un ID d'AMI est propre à une région → recherche de la dernière Ubuntu 24.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.sn
  key_name      = var.key_name
  # Correctif : dans un VPC, on passe des IDs avec vpc_security_group_ids
  # (security_groups attend des NOMS et force la recréation de l'instance à chaque apply)
  vpc_security_group_ids = [var.sg]

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  tags = {
    Name = "my_server"
  }
}
