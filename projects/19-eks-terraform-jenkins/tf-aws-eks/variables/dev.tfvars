aws_region      = "eu-west-3"
vpc_name        = "my-eks-vpc"
vpc_cidr        = "192.168.0.0/16"
public_subnets  = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
private_subnets = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
instance_type   = "t3.medium"
capacity_type   = "SPOT"
