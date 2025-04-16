resource "aws_security_group" "db" {
  vpc_id      = module.vpc.vpc_id
  description = "Define access to the DB from the web server."

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "web_access" {
  type                     = "ingress"
  security_group_id        = aws_security_group.db.id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.11.0"

  identifier           = "example-part-2"
  engine               = "mysql"
  engine_version       = "8.0.36"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t3.micro"

  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.db.id]
  create_db_subnet_group = true
  skip_final_snapshot    = true # Set for easier cleanup, wouldn't want to do this in reality

  username          = "admin"
  allocated_storage = "20"

  tags = var.tags
}