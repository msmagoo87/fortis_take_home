module "bastion" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.30.1"

  name                        = "example-bastion"
  subnets                     = module.vpc.public_subnets
  vpc_id                      = module.vpc.vpc_id
  instance_type               = var.bastion_instance_type
  associate_public_ip_address = true

  security_group_rules = [
    {
      "cidr_blocks" : [
        "0.0.0.0/0"
      ],
      "description" : "Allow all outbound traffic",
      "from_port" : 0,
      "protocol" : -1,
      "to_port" : 0,
      "type" : "egress"
    },
    {
      "cidr_blocks" : var.bastion_access_cidr,
      "description" : "Allow ssh from specified cidr.",
      "from_port" : 22,
      "protocol" : "tcp",
      "to_port" : 22,
      "type" : "ingress"
    }
  ]

  tags = var.tags
}

data "aws_iam_policy_document" "get_web_key" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecret",
      "secretsmanager:GetSecretValue"
    ]
    resources = [aws_secretsmanager_secret.web_key.arn]
  }
}

resource "aws_iam_policy" "get_web_key" {
  name        = "example_get_web_key"
  description = "Allow access to the web key from the bastion host."
  policy      = data.aws_iam_policy_document.get_web_key.json
}

resource "aws_iam_role_policy_attachment" "get_web_key" {
  policy_arn = aws_iam_policy.get_web_key.arn
  role       = module.bastion.role
}

data "aws_iam_policy_document" "bastion_access" {
  statement {
    effect    = "Allow"
    actions   = ["ec2-instance-connect:SendSSHPublicKey"]
    resources = [module.bastion.arn]
    condition {
      test     = "StringEquals"
      variable = "ec2:osuser"
      values   = ["ec2-user"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}

# Attach this policy to a role or a user to allow them access to the bastion host
resource "aws_iam_policy" "user_bastion_access" {
  name        = "example_user_bastion_access"
  description = "Allow users to access the bastion host."
  policy      = data.aws_iam_policy_document.bastion_access.json
}

resource "aws_iam_role" "bastion_access" {
  name = "example-bastion-access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.bastion_access.name
  policy_arn = aws_iam_policy.user_bastion_access.arn
}