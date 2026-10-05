# Projet 06 — VPC + Security Group + 3 instances (Ansible, Jenkins master, Jenkins agent)
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.region
  default_tags { tags = { Project = "io-06" } }
}

variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "my_ip" {
  description = "Ton IP publique en /32, ex: 82.64.10.5/32"
  type        = string
}

variable "key_name" {
  type    = string
  default = "io-key"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.6.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "io-06-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.6.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "devops" {
  name   = "io-06-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH depuis mon IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    description = "Jenkins depuis mon IP (ajouter les IP des webhooks GitHub si besoin)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    description = "Tout le trafic interne au VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

locals {
  servers = {
    ansible        = "t3.micro"
    jenkins-master = "t3.small"
    jenkins-agent  = "t3.medium" # Maven + Docker ont besoin de mémoire
  }
}

resource "aws_instance" "server" {
  for_each               = local.servers
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = each.value
  key_name               = var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.devops.id]
  root_block_device { volume_size = 20 }
  tags = { Name = "io-06-${each.key}" }
}

output "public_ips" { value = { for k, s in aws_instance.server : k => s.public_ip } }
output "private_ips" { value = { for k, s in aws_instance.server : k => s.private_ip } }

output "ansible_inventory" {
  description = "À coller dans ansible/hosts.ini sur le contrôleur Ansible"
  value       = <<-INV
    [jenkins_master]
    master ansible_host=${aws_instance.server["jenkins-master"].private_ip}

    [jenkins_agent]
    agent ansible_host=${aws_instance.server["jenkins-agent"].private_ip}

    [all:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem
    ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'
  INV
}
