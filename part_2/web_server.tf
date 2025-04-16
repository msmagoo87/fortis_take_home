

resource "aws_security_group" "web" {
  vpc_id      = module.vpc.vpc_id
  description = "Define access to the web server."

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "web_bastion_ssh" {
  type                     = "ingress"
  security_group_id        = aws_security_group.web.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion.security_group_id
}

resource "aws_security_group_rule" "web_alb_8080" {
  type                     = "ingress"
  security_group_id        = aws_security_group.web.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.alb.security_group_id
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name           = "web"
  create_private_key = true
}

resource "aws_secretsmanager_secret" "web_key" {
  name = "web_key"
}

# Generate a key pair and store it in secretsmanager so it can be placed on the bastion host
resource "aws_secretsmanager_secret_version" "web_key" {
  secret_id     = aws_secretsmanager_secret.web_key.id
  secret_string = module.key_pair.private_key_pem
}

data "aws_ami" "az2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.az2.id
  instance_type          = var.web_server_instance_type
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = module.key_pair.key_pair_name

  # Use a user data script to install the web server on port 8080.
  user_data = file("${path.module}/web_user_data.sh")

  tags = merge(var.tags, {
    Name = "example-web"
  })
}