data "aws_availability_zones" "az" { state = "available" }

locals {
  az_a = data.aws_availability_zones.az.names[0]
  az_b = data.aws_availability_zones.az.names[1]
}

# ---------------- VPC bastion 192.168.0.0/16 ----------------
resource "aws_vpc" "bastion" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "io-bastion-vpc" }
}

resource "aws_internet_gateway" "bastion" {
  vpc_id = aws_vpc.bastion.id
  tags   = { Name = "io-bastion-igw" }
}

resource "aws_subnet" "bastion_public_a" {
  vpc_id                  = aws_vpc.bastion.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = local.az_a
  map_public_ip_on_launch = true
  tags                    = { Name = "bastion-public-a" }
}

resource "aws_route_table" "bastion_public" {
  vpc_id = aws_vpc.bastion.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bastion.id
  }
  route {
    cidr_block         = aws_vpc.app.cidr_block
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  tags       = { Name = "bastion-public-rt" }
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.bastion]
}

resource "aws_route_table_association" "bastion_public_a" {
  subnet_id      = aws_subnet.bastion_public_a.id
  route_table_id = aws_route_table.bastion_public.id
}

# ---------------- VPC app 172.32.0.0/16 ----------------
resource "aws_vpc" "app" {
  cidr_block           = "172.32.0.0/16" # (plage du projet ; en entreprise : une plage privée, ex 10.32.0.0/16)
  enable_dns_hostnames = true
  tags                 = { Name = "io-app-vpc" }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = { Name = "io-app-igw" }
}

resource "aws_subnet" "app_public" {
  for_each                = { a = { cidr = "172.32.1.0/24", az = local.az_a }, b = { cidr = "172.32.2.0/24", az = local.az_b } }
  vpc_id                  = aws_vpc.app.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags                    = { Name = "app-public-${each.key}" }
}

resource "aws_subnet" "app_private" {
  for_each          = { a = { cidr = "172.32.3.0/24", az = local.az_a }, b = { cidr = "172.32.4.0/24", az = local.az_b } }
  vpc_id            = aws_vpc.app.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = { Name = "app-private-${each.key}" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "io-app-nat-eip" }
}

resource "aws_nat_gateway" "app" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.app_public["a"].id # la NAT va dans un subnet PUBLIC
  tags          = { Name = "io-app-nat" }
  depends_on    = [aws_internet_gateway.app]
}

resource "aws_route_table" "app_public" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
  tags = { Name = "app-public-rt" }
}

resource "aws_route_table_association" "app_public" {
  for_each       = aws_subnet.app_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app_public.id
}

resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.app.id
  }
  route {
    cidr_block         = aws_vpc.bastion.cidr_block # route RETOUR vers le bastion
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }
  tags       = { Name = "app-private-rt" }
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.app]
}

resource "aws_route_table_association" "app_private" {
  for_each       = aws_subnet.app_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app_private.id
}

# ---------------- Transit Gateway ----------------
resource "aws_ec2_transit_gateway" "tgw" {
  description = "io-tgw : relie le VPC bastion et le VPC app"
  tags        = { Name = "io-tgw" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "bastion" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.bastion.id
  subnet_ids         = [aws_subnet.bastion_public_a.id]
  tags               = { Name = "io-tgw-att-bastion" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.app.id
  subnet_ids         = [for s in aws_subnet.app_private : s.id]
  tags               = { Name = "io-tgw-att-app" }
}

# ---------------- Flow Logs ----------------
resource "aws_cloudwatch_log_group" "flow" {
  name              = "/io/vpc-flow-logs"
  retention_in_days = 3
}

resource "aws_iam_role" "flow" {
  name = "io-flowlogs-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "vpc-flow-logs.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}

resource "aws_iam_role_policy" "flow" {
  role = aws_iam_role.flow.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups", "logs:DescribeLogStreams"]
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "vpc" {
  for_each             = { bastion = aws_vpc.bastion.id, app = aws_vpc.app.id }
  vpc_id               = each.value
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow.arn
  iam_role_arn         = aws_iam_role.flow.arn
  tags                 = { Name = "io-flowlog-${each.key}" }
}
