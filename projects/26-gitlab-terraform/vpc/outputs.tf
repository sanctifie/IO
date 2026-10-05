output "pb_sn" {
  description = "ID du subnet public"
  value       = aws_subnet.pb_sn.id
}

output "sg" {
  description = "ID du security group"
  value       = aws_security_group.sg.id
}
