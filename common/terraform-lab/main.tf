# Infrastructure de lab réutilisable (Partie 5) : VPC public + SG restreint + N instances Ubuntu 24.04.
# Usage, depuis ce dossier :
#   terraform init
#   terraform apply -var-file=../../projects/25-petshop-ansible/infra.tfvars -state=io-25.tfstate
#   terraform destroy -var-file=../../projects/25-petshop-ansible/infra.tfvars -state=io-25.tfstate
# (un fichier d'état local par projet, grâce à -state ; ou un backend S3 si tu préfères)
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
    }
  }
}

data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_vpc" "lab" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.azs.names[0]
  tags = {
    Name = "${var.project}-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "lab" {
  name        = "${var.project}-sg"
  description = "Lab ${var.project} : ports ouverts depuis mon IP uniquement"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH depuis mon IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  dynamic "ingress" {
    for_each = toset(var.open_ports)
    content {
      description = "Port ${ingress.value} depuis mon IP"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
    }
  }

  dynamic "ingress" {
    for_each = var.open_nodeports ? [1] : []
    content {
      description = "NodePorts Kubernetes depuis mon IP"
      from_port   = 30000
      to_port     = 32767
      protocol    = "tcp"
      cidr_blocks = [var.my_ip]
    }
  }

  ingress {
    description = "Tout le trafic entre les machines du lab"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  for_each               = var.servers
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = each.value.type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.lab.id]

  root_block_device {
    volume_size = each.value.disk
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  tags = {
    Name = "${var.project}-${each.key}"
  }
}
