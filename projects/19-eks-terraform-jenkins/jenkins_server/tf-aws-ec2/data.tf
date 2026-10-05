data "aws_availability_zones" "azs" {
  state = "available"
}

# Correctif : l'AMI codée en dur (ami-0e8a34246278c21e4) n'existait qu'en us-east-1.
# Un ID d'AMI est propre à une région : on cherche la dernière Amazon Linux 2023.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
