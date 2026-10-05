output "ec2_instance_ip" {
  value = module.ec2_instance.public_ip
}

output "jenkins_url" {
  value = "http://${module.ec2_instance.public_ip}:8080"
}

output "jenkins_role_arn" {
  description = "Rôle IAM utilisé par Jenkins (c'est lui qui créera, et administrera, le cluster EKS)"
  value       = module.ec2_instance.iam_role_arn
}
