# Modules publics du Terraform Registry : https://registry.terraform.io/namespaces/terraform-aws-modules
# On épingle toujours la version majeure d'un module (~> X.Y) : une v6 peut casser l'interface.

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.21"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                     = [data.aws_availability_zones.azs.names[0]]
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true

  tags = {
    Name        = var.vpc_name
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet"
  }
}

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = var.jenkins_security_group
  description = "Security Group for Jenkins Server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Jenkins"
      cidr_blocks = "0.0.0.0/0" # webhooks GitHub ; idéalement restreindre
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH depuis mon IP uniquement"
      cidr_blocks = var.my_ip_cidr
    },
    {
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      description = "SonarQube depuis mon IP uniquement"
      cidr_blocks = var.my_ip_cidr
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "jenkins-sg"
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.8"

  name = var.jenkins_ec2_instance

  instance_type               = var.instance_type
  ami                         = data.aws_ami.al2023.id
  key_name                    = var.key_name
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/../scripts/install_build_tools.sh")

  # Disque de 30 Go : Jenkins + Docker + SonarQube remplissent vite les 8 Go par défaut
  root_block_device = [{
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }]

  # IMDSv2 obligatoire
  metadata_options = {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2 # 2 pour que les conteneurs Docker atteignent aussi les métadonnées
  }

  # Rôle IAM de l'instance : Jenkins exécute Terraform et kubectl SANS clés d'accès stockées.
  create_iam_instance_profile = true
  iam_role_description        = "Role du serveur Jenkins (projet 19)"
  iam_role_policies = {
    admin = "arn:aws:iam::aws:policy/AdministratorAccess" # lab uniquement ; restreindre en entreprise
    ssm   = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Name        = "Jenkins-Server"
    Terraform   = "true"
    Environment = "dev"
  }
}
