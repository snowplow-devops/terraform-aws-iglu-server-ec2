[![Release][release-image]][release] [![CI][ci-image]][ci] [![License][license-image]][license] [![Registry][registry-image]][registry] [![Source][source-image]][source]

# terraform-aws-iglu-server-ec2

A Terraform module which deploys a Snowplow Iglu Server application on AWS running on top of EC2.  If you want to use a custom AMI for this deployment you will need to ensure it is based on top of Amazon Linux 2.

## Telemetry

This module by default collects and forwards telemetry information to Snowplow to understand how our applications are being used.  No identifying information about your sub-account or account fingerprints are ever forwarded to us - it is very simple information about what modules and applications are deployed and active.

If you wish to subscribe to our mailing list for updates to these modules or security advisories please set the `user_provided_id` variable to include a valid email address which we can reach you at.

### How do I disable it?

To disable telemetry simply set variable `telemetry_enabled = false`.

### What are you collecting?

For details on what information is collected please see this module: https://github.com/snowplow-devops/terraform-snowplow-telemetry

## Usage

The Iglu Server stack requires a Load Balancer and a Postgres instance to save information into for its backend.  Here we are using several managed modules to facilitate this requirement but you can also sub in your own Postgres Host and Load Balancer if you prefer to do so.

```hcl
locals {
  iglu_db_name     = "iglu"
  iglu_db_username = "iglu"

  # Keep this secret!!
  iglu_db_password = "Hell0W0rld!"

  # Used for API actions on the Iglu Server. Keep this secret!!
  iglu_super_api_key = "2f48ad70-b70c-4f58-af3b-f19d8b7706e1"
}

module "iglu_rds" {
  source  = "snowplow-devops/rds/aws"
  version = "0.2.0"

  name        = "iglu-rds"
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids
  db_name     = local.iglu_db_name
  db_username = local.iglu_db_username
  db_password = local.iglu_db_password
}

module "iglu_lb" {
  source  = "snowplow-devops/alb/aws"
  version = "0.2.0"

  name              = "iglu-lb"
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  health_check_path = "/api/meta/health"
}

module "iglu_server" {
  source = "snowplow-devops/iglu-server-ec2/aws"

  accept_limited_use_license = true

  name                 = "iglu-server"
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
  iglu_server_lb_sg_id = module.iglu_lb.sg_id
  iglu_server_lb_tg_id = module.iglu_lb.tg_id
  ingress_port         = module.iglu_lb.tg_egress_port
  db_sg_id             = module.iglu_rds.sg_id
  db_host              = module.iglu_rds.address
  db_port              = module.iglu_rds.port
  db_name              = local.iglu_db_name
  db_username          = local.iglu_db_username
  db_password          = local.iglu_db_password
  super_api_key        = local.iglu_super_api_key

  ssh_key_name     = "your-key-name"
  ssh_ip_allowlist = ["0.0.0.0/0"]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_instance_type_metrics"></a> [instance\_type\_metrics](#module\_instance\_type\_metrics) | snowplow-devops/ec2-instance-type-metrics/aws | 0.1.2 |
| <a name="module_service"></a> [service](#module\_service) | snowplow-devops/service-ec2/aws | 0.2.1 |
| <a name="module_telemetry"></a> [telemetry](#module\_telemetry) | snowplow-devops/telemetry/snowplow | 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_instance_profile.instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_tcp_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_tcp_80](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_tcp_webserver_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress_udp_123](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_tcp_22](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_tcp_webserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.lb_egress_tcp_webserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.rds_egress_tcp_webserver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_host"></a> [db\_host](#input\_db\_host) | The hostname of the database to connect to | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name of the database to connect to | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | The password to use to connect to the database | `string` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | The port the database is running on | `number` | n/a | yes |
| <a name="input_db_sg_id"></a> [db\_sg\_id](#input\_db\_sg\_id) | The ID of the RDS security group that sits downstream of the webserver | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | The username to use to connect to the database | `string` | n/a | yes |
| <a name="input_iglu_server_lb_sg_id"></a> [iglu\_server\_lb\_sg\_id](#input\_iglu\_server\_lb\_sg\_id) | The ID of the load-balancer security group that sits upstream of the webserver | `string` | n/a | yes |
| <a name="input_iglu_server_lb_tg_id"></a> [iglu\_server\_lb\_tg\_id](#input\_iglu\_server\_lb\_tg\_id) | The ID of the load-balancer target group to direct traffic from the load-balancer to the webserver | `string` | n/a | yes |
| <a name="input_ingress_port"></a> [ingress\_port](#input\_ingress\_port) | The port that the Iglu Server will be bound to and expose over HTTP | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A name which will be pre-pended to the resources created | `string` | n/a | yes |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | The name of the SSH key-pair to attach to all EC2 nodes deployed | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The list of subnets to deploy the Iglu Server across | `list(string)` | n/a | yes |
| <a name="input_super_api_key"></a> [super\_api\_key](#input\_super\_api\_key) | A UUIDv4 string to use as the master API key for Iglu Server management | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC to deploy the Iglu Server within | `string` | n/a | yes |
| <a name="input_accept_limited_use_license"></a> [accept\_limited\_use\_license](#input\_accept\_limited\_use\_license) | Acceptance of the SLULA terms (https://docs.snowplow.io/limited-use-license-1.0/) | `bool` | `false` | no |
| <a name="input_amazon_linux_2_ami_id"></a> [amazon\_linux\_2\_ami\_id](#input\_amazon\_linux\_2\_ami\_id) | The AMI ID to use which must be based of of Amazon Linux 2; by default the latest community version is used | `string` | `""` | no |
| <a name="input_app_version"></a> [app\_version](#input\_app\_version) | App version to use. This variable facilitates dev flow, the modules may not work with anything other than the default value. | `string` | `"0.12.0"` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to assign a public ip address to this instance | `bool` | `true` | no |
| <a name="input_cloudwatch_logs_enabled"></a> [cloudwatch\_logs\_enabled](#input\_cloudwatch\_logs\_enabled) | Whether application logs should be reported to CloudWatch | `bool` | `true` | no |
| <a name="input_cloudwatch_logs_retention_days"></a> [cloudwatch\_logs\_retention\_days](#input\_cloudwatch\_logs\_retention\_days) | The length of time in days to retain logs for | `number` | `7` | no |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Whether to enable auto-scaling policies for the service (WARN: ensure you have sufficient db\_connections available for the max number of nodes in the ASG) | `bool` | `true` | no |
| <a name="input_iam_permissions_boundary"></a> [iam\_permissions\_boundary](#input\_iam\_permissions\_boundary) | The permissions boundary ARN to set on IAM roles created | `string` | `""` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use | `string` | `"t3a.micro"` | no |
| <a name="input_java_opts"></a> [java\_opts](#input\_java\_opts) | Custom JAVA Options | `string` | `"-XX:InitialRAMPercentage=75 -XX:MaxRAMPercentage=75"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum number of servers in this server-group | `number` | `2` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum number of servers in this server-group | `number` | `1` | no |
| <a name="input_patches_allowed"></a> [patches\_allowed](#input\_patches\_allowed) | Whether or not patches are allowed for published Iglu Schemas | `bool` | `true` | no |
| <a name="input_private_ecr_registry"></a> [private\_ecr\_registry](#input\_private\_ecr\_registry) | The URL of an ECR registry that the sub-account has access to (e.g. '000000000000.dkr.ecr.cn-north-1.amazonaws.com.cn/') | `string` | `""` | no |
| <a name="input_scale_down_cooldown_sec"></a> [scale\_down\_cooldown\_sec](#input\_scale\_down\_cooldown\_sec) | Time (in seconds) until another scale-down action can occur | `number` | `600` | no |
| <a name="input_scale_down_cpu_threshold_percentage"></a> [scale\_down\_cpu\_threshold\_percentage](#input\_scale\_down\_cpu\_threshold\_percentage) | The average CPU percentage that we must be below to scale-down | `number` | `20` | no |
| <a name="input_scale_down_eval_minutes"></a> [scale\_down\_eval\_minutes](#input\_scale\_down\_eval\_minutes) | The number of consecutive minutes that we must be below the threshold to scale-down | `number` | `60` | no |
| <a name="input_scale_up_cooldown_sec"></a> [scale\_up\_cooldown\_sec](#input\_scale\_up\_cooldown\_sec) | Time (in seconds) until another scale-up action can occur | `number` | `180` | no |
| <a name="input_scale_up_cpu_threshold_percentage"></a> [scale\_up\_cpu\_threshold\_percentage](#input\_scale\_up\_cpu\_threshold\_percentage) | The average CPU percentage that must be exceeded to scale-up | `number` | `60` | no |
| <a name="input_scale_up_eval_minutes"></a> [scale\_up\_eval\_minutes](#input\_scale\_up\_eval\_minutes) | The number of consecutive minutes that the threshold must be breached to scale-up | `number` | `5` | no |
| <a name="input_ssh_ip_allowlist"></a> [ssh\_ip\_allowlist](#input\_ssh\_ip\_allowlist) | The list of CIDR ranges to allow SSH traffic from | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to append to this resource | `map(string)` | `{}` | no |
| <a name="input_telemetry_enabled"></a> [telemetry\_enabled](#input\_telemetry\_enabled) | Whether or not to send telemetry information back to Snowplow Analytics Ltd | `bool` | `true` | no |
| <a name="input_user_provided_id"></a> [user\_provided\_id](#input\_user\_provided\_id) | An optional unique identifier to identify the telemetry events emitted by this stack | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_id"></a> [asg\_id](#output\_asg\_id) | ID of the ASG |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Name of the ASG |
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | ID of the security group attached to the Iglu Server node |

# Copyright and license

Copyright 2021-current Snowplow Analytics Ltd.

Licensed under the [Snowplow Limited Use License Agreement][license]. _(If you are uncertain how it applies to your use case, check our answers to [frequently asked questions][license-faq].)_

[release]: https://github.com/snowplow-devops/terraform-aws-iglu-server-ec2/releases/latest
[release-image]: https://img.shields.io/github/v/release/snowplow-devops/terraform-aws-iglu-server-ec2

[ci]: https://github.com/snowplow-devops/terraform-aws-iglu-server-ec2/actions?query=workflow%3Aci
[ci-image]: https://github.com/snowplow-devops/terraform-aws-iglu-server-ec2/workflows/ci/badge.svg

[license]: https://docs.snowplow.io/limited-use-license-1.1/
[license-image]: https://img.shields.io/badge/license-Snowplow--Limited--Use-blue.svg?style=flat
[license-faq]: https://docs.snowplow.io/docs/contributing/limited-use-license-faq/

[registry]: https://registry.terraform.io/modules/snowplow-devops/iglu-server-ec2/aws/latest
[registry-image]: https://img.shields.io/static/v1?label=Terraform&message=Registry&color=7B42BC&logo=terraform

[source]: https://github.com/snowplow-incubator/iglu-server
[source-image]: https://img.shields.io/static/v1?label=Snowplow&message=Iglu%20Server&color=0E9BA4&logo=GitHub
