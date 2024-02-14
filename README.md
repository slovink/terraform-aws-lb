# Terraform-aws-lb

# Terraform AWS Cloud lb Module

## Table of Contents
- [Introduction](#introduction)
- [Usage](#usage)
- [Examples](#Examples)
- [Author](#Author)
- [License](#license)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Introduction
This Terraform module creates an AWS load balancer (lb) along with additional configuration options.
## Usage
To use this module, you can include it in your Terraform configuration. Here's an example of how to use it:

# Examples:

## Example: alb

```hcl
module "alb" {
  source                     =  "./../../"
  name                       = local.name
  enable                     = true
  internal                   = true
  load_balancer_type         = "application"
  instance_count             = 1
  subnets                    = module.subnet.public_subnet_id
  target_id                  = module.ec2.instance_id
  vpc_id                     = module.vpc.vpc_id
  allowed_ip                 = [module.vpc.vpc_cidr_block]
  allowed_ports              = [3306]
  enable_deletion_protection = false
  with_target_group          = true
  https_enabled              = true
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
```

## Example: clb

```hcl
module "clb" {
  source             = "./../../"
  name               = "app"
  load_balancer_type = "classic"
  clb_enable         = true
  internal           = true
  vpc_id             = module.vpc.vpc_id
  target_id          = module.ec2.instance_id
  subnets            = module.public_subnets.public_subnet_id
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
```
## Example: nlb

```hcl
module "nlb" {
  source                     =  "./../../"
  version                    =  "1.0.1"
  name                       = "app"
  enable                     = true
  internal                   = false
  load_balancer_type         = "network"
  instance_count             = 1
  subnets                    = module.public_subnets.public_subnet_id
  target_id                  = module.ec2.instance_id
  vpc_id                     = module.vpc.vpc_id
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
      certificate_arn    = ""
    },
    {
      port               = 84
      protocol           = "TLS"
      target_group_index = 1
      certificate_arn    = ""
    },
  ]
}
```

## Example
For detailed examples on how to use this module, please refer to the '[example](https://github.com/slovink/terraform-aws-lb/tree/master/example)' directory within this repository.

## Author
Your Name Replace **MIT** and **slovink** with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

## License
This project is licensed under the **MIT** License - see the [LICENSE](https://github.com/slovink/terraform-aws-lb/blob/master/LICENSE) file for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4, < 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.32.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.32.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_labels"></a> [labels](#module\_labels) | git@github.com:slovink/terraform-aws-labels.git | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_elb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.nhttp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.nhttps](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.https_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.http_tcp_listener_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.https_listener_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.nattachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs"></a> [access\_logs](#input\_access\_logs) | Map containing access logging configuration for load balancer. | `map(string)` | `{}` | no |
| <a name="input_allowed_ip"></a> [allowed\_ip](#input\_allowed\_ip) | List of allowed ip. | `list(any)` | `[]` | no |
| <a name="input_allowed_ports"></a> [allowed\_ports](#input\_allowed\_ports) | List of allowed ingress ports | `list(any)` | `[]` | no |
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_clb_enable"></a> [clb\_enable](#input\_clb\_enable) | If true, create clb. | `bool` | `false` | no |
| <a name="input_connection_draining"></a> [connection\_draining](#input\_connection\_draining) | TBoolean to enable connection draining. Default: false. | `bool` | `false` | no |
| <a name="input_connection_draining_timeout"></a> [connection\_draining\_timeout](#input\_connection\_draining\_timeout) | The time after which connection draining is aborted in seconds. | `number` | `300` | no |
| <a name="input_desync_mitigation_mode"></a> [desync\_mitigation\_mode](#input\_desync\_mitigation\_mode) | Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. | `string` | `"defensive"` | no |
| <a name="input_egress_protocol"></a> [egress\_protocol](#input\_egress\_protocol) | equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference | `number` | `-1` | no |
| <a name="input_egress_rule"></a> [egress\_rule](#input\_egress\_rule) | Enable to create egress rule | `bool` | `true` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | If true, create alb. | `bool` | `false` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable\_cross\_zone\_load\_balancing](#input\_enable\_cross\_zone\_load\_balancing) | Indicates whether cross zone load balancing should be enabled in application load balancers. | `bool` | `true` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | Indicates whether HTTP/2 is enabled in application load balancers. | `bool` | `true` | no |
| <a name="input_enable_security_group"></a> [enable\_security\_group](#input\_enable\_security\_group) | Enable default Security Group with only Egress traffic allowed. | `bool` | `true` | no |
| <a name="input_enable_tls_version_and_cipher_suite_headers"></a> [enable\_tls\_version\_and\_cipher\_suite\_headers](#input\_enable\_tls\_version\_and\_cipher\_suite\_headers) | Indicates whether the two headers (x-amzn-tls-version and x-amzn-tls-cipher-suite), which contain information about the negotiated TLS version and cipher suite, are added to the client request before sending it to the target. | `bool` | `false` | no |
| <a name="input_enable_waf_fail_open"></a> [enable\_waf\_fail\_open](#input\_enable\_waf\_fail\_open) | Indicates whether to route requests to targets if lb fails to forward the request to AWS WAF | `bool` | `false` | no |
| <a name="input_enable_xff_client_port"></a> [enable\_xff\_client\_port](#input\_enable\_xff\_client\_port) | Indicates whether the X-Forwarded-For header should preserve the source port that the client used to connect to the load balancer in application load balancers. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| <a name="input_extra_ssl_certs"></a> [extra\_ssl\_certs](#input\_extra\_ssl\_certs) | A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Required key/values: certificate\_arn, https\_listener\_index (the index of the listener within https\_listeners which the cert applies toward). | `list(map(string))` | `[]` | no |
| <a name="input_from_port"></a> [from\_port](#input\_from\_port) | (Required) Start port (or ICMP type number if protocol is icmp or icmpv6). | `number` | `0` | no |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | The number of successful health checks before an instance is put into service. | `number` | `10` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | The time between health check attempts in seconds. | `number` | `30` | no |
| <a name="input_health_check_target"></a> [health\_check\_target](#input\_health\_check\_target) | The target to use for health checks. | `string` | `"TCP:80"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | The time after which a health check is considered failed in seconds. | `number` | `5` | no |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | The number of failed health checks before an instance is taken out of service. | `number` | `2` | no |
| <a name="input_http_enabled"></a> [http\_enabled](#input\_http\_enabled) | A boolean flag to enable/disable HTTP listener. | `bool` | `true` | no |
| <a name="input_http_listener_type"></a> [http\_listener\_type](#input\_http\_listener\_type) | The type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc. | `string` | `"redirect"` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | The port on which the load balancer is listening. like 80 or 443. | `number` | `80` | no |
| <a name="input_http_tcp_listener_rules"></a> [http\_tcp\_listener\_rules](#input\_http\_tcp\_listener\_rules) | A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, http\_tcp\_listener\_index (default to http\_tcp\_listeners[count.index]) | `any` | `[]` | no |
| <a name="input_http_tcp_listeners"></a> [http\_tcp\_listeners](#input\_http\_tcp\_listeners) | A list of maps describing the HTTP listeners or TCP ports for this ALB. Required key/values: port, protocol. Optional key/values: target\_group\_index (defaults to http\_tcp\_listeners[count.index]) | `any` | `[]` | no |
| <a name="input_https_enabled"></a> [https\_enabled](#input\_https\_enabled) | A boolean flag to enable/disable HTTPS listener. | `bool` | `true` | no |
| <a name="input_https_listener_rules"></a> [https\_listener\_rules](#input\_https\_listener\_rules) | A list of maps describing the Listener Rules for this ALB. Required key/values: actions, conditions. Optional key/values: priority, https\_listener\_index (default to https\_listeners[count.index]) | `any` | `[]` | no |
| <a name="input_https_listeners"></a> [https\_listeners](#input\_https\_listeners) | A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate\_arn. Optional key/values: ssl\_policy (defaults to ELBSecurityPolicy-2016-08), target\_group\_index (defaults to 0) | `list(map(string))` | `[]` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | The port on which the load balancer is listening. like 80 or 443. | `number` | `443` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | The time in seconds that the connection is allowed to be idle. | `number` | `60` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | The count of instances. | `number` | `0` | no |
| <a name="input_internal"></a> [internal](#input\_internal) | If true, the LB will be internal. | `string` | `""` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack. | `string` | `"ipv4"` | no |
| <a name="input_ipv6_cidr_blocks"></a> [ipv6\_cidr\_blocks](#input\_ipv6\_cidr\_blocks) | Enable to create egress rule | `list(string)` | <pre>[<br>  "::/0"<br>]</pre> | no |
| <a name="input_is_external"></a> [is\_external](#input\_is\_external) | enable to udated existing security Group | `bool` | `false` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| <a name="input_listener_certificate_arn"></a> [listener\_certificate\_arn](#input\_listener\_certificate\_arn) | The ARN of the SSL server certificate. Exactly one certificate is required if the protocol is HTTPS. | `string` | `""` | no |
| <a name="input_listener_https_fixed_response"></a> [listener\_https\_fixed\_response](#input\_listener\_https\_fixed\_response) | Have the HTTPS listener return a fixed response for the default action. | <pre>object({<br>    content_type = string<br>    message_body = string<br>    status_code  = string<br>  })</pre> | `null` | no |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | The protocol for connections from clients to the load balancer. Valid values are TCP, HTTP and HTTPS. Defaults to HTTP. | `string` | `"HTTPS"` | no |
| <a name="input_listener_type"></a> [listener\_type](#input\_listener\_type) | The type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc. | `string` | `"forward"` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | A list of listener configurations for the ELB. | <pre>list(object({<br>    lb_port : number<br>    lb_protocol : string<br>    instance_port : number<br>    instance_protocol : string<br>    ssl_certificate_id : string<br>  }))</pre> | `[]` | no |
| <a name="input_load_balancer_create_timeout"></a> [load\_balancer\_create\_timeout](#input\_load\_balancer\_create\_timeout) | Timeout value when creating the ALB. | `string` | `"10m"` | no |
| <a name="input_load_balancer_delete_timeout"></a> [load\_balancer\_delete\_timeout](#input\_load\_balancer\_delete\_timeout) | Timeout value when deleting the ALB. | `string` | `"10m"` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | The type of load balancer to create. Possible values are application or network. The default value is application. | `string` | `""` | no |
| <a name="input_load_balancer_update_timeout"></a> [load\_balancer\_update\_timeout](#input\_load\_balancer\_update\_timeout) | Timeout value when updating the ALB. | `string` | `"10m"` | no |
| <a name="input_managedby"></a> [managedby](#input\_managedby) | ManagedBy, eg 'slovink'. | `string` | `"slovink"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| <a name="input_preserve_host_header"></a> [preserve\_host\_header](#input\_preserve\_host\_header) | Indicates whether Host header should be preserve and forward to targets without any change. Defaults to false. | `bool` | `false` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | The protocol. If not icmp, tcp, udp, or all use the. | `string` | `"tcp"` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Terraform current module repo | `string` | `"https://github.com/slovink/terraform-aws-lb"` | no |
| <a name="input_sg_description"></a> [sg\_description](#input\_sg\_description) | The security group description. | `string` | `"Instance default security group (only egress access is allowed)."` | no |
| <a name="input_sg_egress_description"></a> [sg\_egress\_description](#input\_sg\_egress\_description) | Description of the egress and ingress rule | `string` | `"Description of the rule."` | no |
| <a name="input_sg_egress_ipv6_description"></a> [sg\_egress\_ipv6\_description](#input\_sg\_egress\_ipv6\_description) | Description of the egress\_ipv6 rule | `string` | `"Description of the rule."` | no |
| <a name="input_sg_ids"></a> [sg\_ids](#input\_sg\_ids) | of the security group id. | `list(any)` | `[]` | no |
| <a name="input_sg_ingress_description"></a> [sg\_ingress\_description](#input\_sg\_ingress\_description) | Description of the ingress rule | `string` | `"Description of the ingress rule use elasticache."` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | Name of the SSL Policy for the listener. Required if protocol is HTTPS or TLS. | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| <a name="input_status_code"></a> [status\_code](#input\_status\_code) | The HTTP redirect code. The redirect is either permanent (HTTP\_301) or temporary (HTTP\_302). | `string` | `"HTTP_301"` | no |
| <a name="input_subnet_mapping"></a> [subnet\_mapping](#input\_subnet\_mapping) | A list of subnet mapping blocks describing subnets to attach to network load balancer | `list(map(string))` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value will for load balancers of type network will force a recreation of the resource. | `list(any)` | `[]` | no |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | The port on which targets receive traffic, unless overridden when registering a specific target. | `string` | `80` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend\_protocol, backend\_port. Optional key/values are in the target\_groups\_defaults variable. | `any` | `[]` | no |
| <a name="input_target_id"></a> [target\_id](#input\_target\_id) | The ID of the target. This is the Instance ID for an instance, or the container ID for an ECS container. If the target type is ip, specify an IP address. | `list(any)` | `null` | no |
| <a name="input_to_port"></a> [to\_port](#input\_to\_port) | equal to 0. The supported values are defined in the IpProtocol argument on the IpPermission API reference | `number` | `65535` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The identifier of the VPC in which to create the target group. | `string` | `""` | no |
| <a name="input_with_target_group"></a> [with\_target\_group](#input\_with\_target\_group) | Create LoadBlancer without target group | `bool` | `true` | no |
| <a name="input_xff_header_processing_mode"></a> [xff\_header\_processing\_mode](#input\_xff\_header\_processing\_mode) | Determines how the load balancer modifies the X-Forwarded-For header in the HTTP request before sending the request to the target. | `string` | `"append"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the ALB. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix of the ALB. |
| <a name="output_clb_arn"></a> [clb\_arn](#output\_clb\_arn) | The ARN of the CLB. |
| <a name="output_clb_name"></a> [clb\_name](#output\_clb\_name) | DNS name of CLB. |
| <a name="output_clb_zone_id"></a> [clb\_zone\_id](#output\_clb\_zone\_id) | The ID of the zone which ALB is provisioned. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | DNS name of ALB. |
| <a name="output_http_listener_arn"></a> [http\_listener\_arn](#output\_http\_listener\_arn) | The ARN of the HTTP listener. |
| <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn) | The ARN of the HTTPS listener. |
| <a name="output_listener_arns"></a> [listener\_arns](#output\_listener\_arns) | A list of all the listener ARNs. |
| <a name="output_main_target_group_arn"></a> [main\_target\_group\_arn](#output\_main\_target\_group\_arn) | The main target group ARN. |
| <a name="output_name"></a> [name](#output\_name) | The ARN suffix of the ALB. |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | Amazon Resource Name (ARN) of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_tags"></a> [tags](#output\_tags) | A mapping of tags to assign to the resource. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The ID of the zone which ALB is provisioned. |
<!-- END_TF_DOCS -->