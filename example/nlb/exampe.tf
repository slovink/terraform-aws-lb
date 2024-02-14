provider "aws" {
  region = "eu-west-1"
}

locals {
  name        = "nlb"
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
  instance_count    = 1
  ami               = "ami-xxxxxxxxxxxxx"
  instance_type     = "t2.micro"
  monitoring        = false
  vpc_id            = module.vpc.id
  ssh_allowed_ip    = ["0.0.0.0/0"]
  ssh_allowed_ports = [22]
  tenancy           = "default"
  subnet_ids        = tolist(module.subnet.public_subnet_id)
  public_key        = "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx= vinod@vinod"
  #  iam_instance_profile        = module.iam-role.name
  assign_eip_address          = true
  associate_public_ip_address = true
  #  instance_profile_enabled    = true
  ebs_optimized      = false
  ebs_volume_enabled = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 30
}



##-----------------------------------------------------------------------------
## nlb module call.
##-----------------------------------------------------------------------------
module "nlb" {
  source = "./../../"

  name                       = local.name
  enable                     = true
  internal                   = false
  load_balancer_type         = "network"
  instance_count             = module.ec2.instance_count
  subnets                    = module.subnet.public_subnet_id
  target_id                  = module.ec2.instance_id
  vpc_id                     = module.vpc.id
  enable_deletion_protection = false
  with_target_group          = true
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 81
      protocol           = "TCP"
      target_group_index = 0
    },
  ]
  target_groups = [
    {
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "instance"
    },
    {
      backend_protocol = "TCP"
      backend_port     = 81
      target_type      = "instance"
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      target_group_index = 1
      certificate_arn    = module.nlb.arn
    },
    {
      port               = 84
      protocol           = "TLS"
      target_group_index = 1
      certificate_arn    = module.nlb.arn
    },
  ]
}