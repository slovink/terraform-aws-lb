provider "aws" {
  region = "eu-west-1"
}

locals {
  name        = "clb"
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

  policy_enabled = true
  policy         = data.aws_iam_policy_document.iam-policy.json
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
  name              = local.name
  environment       = local.environment
  vpc_id            = module.vpc.id
  ssh_allowed_ip    = ["0.0.0.0/0"]
  ssh_allowed_ports = [22]
  instance_count    = 2
  ami               = "ami-0905a3c97561e0b69"
  instance_type     = "t2.micro"
  monitoring        = false
  tenancy           = "default"
  public_key        = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx= vinod@vinod"
  subnet_ids        = tolist(module.subnet.public_subnet_id)
  #  iam_instance_profile        = module.iam-role.name
  assign_eip_address          = true
  associate_public_ip_address = true
  #  instance_profile_enabled    = true
  ebs_optimized      = false
  ebs_volume_enabled = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 30
}

module "clb" {
  source             = "./../../"
  name               = "app"
  load_balancer_type = "classic"
  clb_enable         = true
  internal           = true
  vpc_id             = module.vpc.id
  target_id          = module.ec2.instance_id
  subnets            = module.subnet.public_subnet_id
  with_target_group  = true
  listeners = [
    {
      lb_port            = 22000
      lb_protocol        = "TCP"
      instance_port      = 22000
      instance_protocol  = "TCP"
      ssl_certificate_id = null
    },
    {
      lb_port            = 4444
      lb_protocol        = "TCP"
      instance_port      = 4444
      instance_protocol  = "TCP"
      ssl_certificate_id = null
    }
  ]
  health_check_target              = "TCP:4444"
  health_check_timeout             = 10
  health_check_interval            = 30
  health_check_unhealthy_threshold = 5
  health_check_healthy_threshold   = 5
}
