output "bastion_public_dns" {
  value = module.bastion.public_dns
}

output "web_private_ip" {
  value = aws_instance.web.private_ip
}

output "bastion_role_arn" {
  value = aws_iam_role.bastion_access.arn
}

output "db_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_secret_arn" {
  value = module.rds.db_instance_master_user_secret_arn
}

output "web_key_secret_arn" {
  value = aws_secretsmanager_secret.web_key.arn
}