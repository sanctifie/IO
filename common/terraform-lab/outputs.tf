output "public_ips" {
  value = { for k, s in aws_instance.server : k => s.public_ip }
}

output "private_ips" {
  value = { for k, s in aws_instance.server : k => s.private_ip }
}

output "ssh_commands" {
  value = { for k, s in aws_instance.server : k => "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${s.public_ip}" }
}
