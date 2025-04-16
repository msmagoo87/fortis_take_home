module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.0.1"

  create_certificate = true
  domain_name        = var.domain_name
  validation_method  = "DNS"
  zone_id            = var.zone_id
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.8"

  name    = "example-part-2"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  enable_deletion_protection = true

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port     = 443
      protocol = "HTTPS"
      forward = {
        target_group_key = "web"
      }
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = module.acm.acm_certificate_arn
    }
  }

  target_groups = {
    web = {
      name_prefix          = "web"
      protocol             = "HTTP"
      port                 = 8080
      target_type          = "instance"
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }

      protocol_version = "HTTP1"
      target_id        = aws_instance.web.id
      port             = 8080

      tags = var.tags
    }
  }

  # Creates an alias record on the zone to the ALB
  route53_records = {
    alb = {
      name    = var.domain_name
      type    = "A"
      zone_id = var.zone_id
    }
  }
}