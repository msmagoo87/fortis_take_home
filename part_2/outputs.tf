output "bastion_public_dns" {
  value = module.bastion.public_dns
}

output "web_private_ip" {
  value = aws_instance.web.private_ip
}