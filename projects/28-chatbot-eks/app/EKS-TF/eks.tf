# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.37"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version # 1.29 d'origine : hors support standard (facturé 6× plus cher)

  cluster_endpoint_public_access = true

  # Indispensable depuis la v20 : l'identité qui crée le cluster (le rôle de Jenkins)
  # devient admin Kubernetes. Sans ça : "Unauthorized" au kubectl apply.
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Add-ons gérés par EKS (mis à jour par AWS)
  cluster_addons = {
    coredns                = { most_recent = true }
    kube-proxy             = { most_recent = true }
    eks-pod-identity-agent = { most_recent = true }
    vpc-cni = {
      most_recent    = true
      before_compute = true # le réseau des pods doit exister avant les nœuds
    }
  }

  eks_managed_node_groups = {
    nodes = {
      ami_type       = "AL2023_x86_64_STANDARD" # les AMI EKS Amazon Linux 2 n'existent plus pour les versions récentes
      instance_types = [var.instance_type]      # t2.small d'origine : trop petit (11 pods max, 2 Go)
      capacity_type  = var.capacity_type

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}
