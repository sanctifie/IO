output "site_url" { value = "http://${aws_lb.web.dns_name}/" }
output "whoami_url" { value = "http://${aws_lb.web.dns_name}/whoami.html" }
output "bastion_ip" { value = aws_eip.bastion.public_ip }
output "ssh_via_bastion" {
  value = "ssh-add ~/.ssh/${var.key_name}.pem && ssh -J ec2-user@${aws_eip.bastion.public_ip} ec2-user@<IP_PRIVEE_SERVEUR_WEB>"
}
