provider "aws" {
  region = "eu-west-1"
}

locals {
  name        = "alb"
  environment = "test"
}

module "vpc" {
  source = "git::git@github.com:slovink/terraform-aws-vpc.git?ref=1.0.0"
  #  version     = "1.0.1"
  name        = local.name
  environment = local.environment
  cidr_block  = "172.16.0.0/16"
}


module "subnet" {
  source = "git::git@github.com:slovink/terraform-aws-subnet.git?ref=1.0.0"
  #  version            = "1.0.1"
  name               = local.name
  environment        = local.environment
  availability_zones = ["eu-west-1b", "eu-west-1c"]
  type               = "public"
  vpc_id             = module.vpc.id
  cidr_block         = module.vpc.vpc_cidr_block
  igw_id             = module.vpc.igw_id
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

module "iam-role" {
  source = "git@github.com:slovink/terraform-aws-iam-role.git?ref=1.0.0"
  #  version            = "1.0.1"
  name               = local.name
  environment        = local.environment
  assume_role_policy = data.aws_iam_policy_document.default.json
  policy_enabled     = true
  policy             = data.aws_iam_policy_document.iam-policy.json
}

data "aws_iam_policy_document" "default" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam-policy" {
  statement {
    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
    "ssmmessages:OpenDataChannel"]
    effect    = "Allow"
    resources = ["*"]
  }
}

module "ec2" {
  source = "git@github.com:slovink/terraform-aws-ec2.git?ref=1.0.0"
  #  version                     = "1.0.1"
  name              = "alb"
  environment       = local.environment
  vpc_id            = module.vpc.id
  ssh_allowed_ip    = ["0.0.0.0/0"]
  ssh_allowed_ports = [22]
  public_key        = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx= vinod@vinod"
  instance_count    = 1
  ami               = "ami-xxxxxxxxxxxxxxx"
  instance_type     = "t2.micro"
  monitoring        = true
  tenancy           = "default"
  subnet_ids        = tolist(module.subnet.public_subnet_id)
  #  iam_instance_profile        = tolist(module.ec2.name)
  assign_eip_address          = false
  associate_public_ip_address = true
  #  instance_profile_enabled    = true
  ebs_optimized      = false
  ebs_volume_enabled = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 30
}



module "alb" {
  source                     = "./../../"
  name                       = local.name
  enable                     = true
  internal                   = true
  load_balancer_type         = "application"
  instance_count             = 1
  subnets                    = module.subnet.public_subnet_id
  target_id                  = module.ec2.instance_id
  vpc_id                     = module.vpc.id
  allowed_ip                 = [module.vpc.vpc_cidr_block]
  allowed_ports              = [3306]
  enable_deletion_protection = false
  with_target_group          = true
  https_enabled              = false
  http_enabled               = true
  https_port                 = 443
  listener_type              = "forward"
  target_group_port          = 80

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
  ]
  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      target_group_index = 0
      certificate_arn    = ""
    },
    {
      port               = 84
      protocol           = "TLS"
      target_group_index = 0
      certificate_arn    = ""
    },
  ]

  target_groups = [
    {
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 300
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]

}
