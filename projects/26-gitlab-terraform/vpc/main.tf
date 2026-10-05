data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "pb_sn" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.azs.names[0] # "us-east-1a" codé en dur à l'origine
  tags = {
    Name = "pb_sn1"
  }
}

# Ajout : sans Internet Gateway ni route, le subnet "public" ne l'est pas vraiment
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "myvpc-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "myvpc-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.pb_sn.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.myvpc.id
  name        = "my_sg"
  description = "Public Security Group"

  ingress {
    description = "SSH depuis mon IP uniquement"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
