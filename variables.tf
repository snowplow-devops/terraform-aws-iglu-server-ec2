variable "accept_limited_use_license" {
  description = "Acceptance of the SLULA terms (https://docs.snowplow.io/limited-use-license-1.0/)"
  type        = bool
  default     = false

  validation {
    condition     = var.accept_limited_use_license
    error_message = "Please accept the terms of the Snowplow Limited Use License Agreement to proceed."
  }
}

variable "name" {
  description = "A name which will be pre-pended to the resources created"
  type        = string
}

variable "app_version" {
  description = "App version to use. This variable facilitates dev flow, the modules may not work with anything other than the default value."
  type        = string
  default     = "0.13.1"
}

variable "vpc_id" {
  description = "The VPC to deploy the Iglu Server within"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnets to deploy the Iglu Server across"
  type        = list(string)
}

variable "iglu_server_lb_sg_id" {
  description = "The ID of the load-balancer security group that sits upstream of the webserver"
  type        = string
}

variable "iglu_server_lb_tg_id" {
  description = "The ID of the load-balancer target group to direct traffic from the load-balancer to the webserver"
  type        = string
}

variable "ingress_port" {
  description = "The port that the Iglu Server will be bound to and expose over HTTP"
  type        = number
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3a.micro"
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public ip address to this instance"
  type        = bool
  default     = true
}

variable "ssh_key_name" {
  description = "The name of the SSH key-pair to attach to all EC2 nodes deployed"
  type        = string
}

variable "ssh_ip_allowlist" {
  description = "The list of CIDR ranges to allow SSH traffic from"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "iam_permissions_boundary" {
  description = "The permissions boundary ARN to set on IAM roles created"
  default     = ""
  type        = string
}

variable "min_size" {
  description = "The minimum number of servers in this server-group"
  default     = 1
  type        = number
}

variable "max_size" {
  description = "The maximum number of servers in this server-group"
  default     = 2
  type        = number
}

variable "amazon_linux_2_ami_id" {
  description = "The AMI ID to use which must be based of of Amazon Linux 2; by default the latest community version is used"
  default     = ""
  type        = string
}

variable "tags" {
  description = "The tags to append to this resource"
  default     = {}
  type        = map(string)
}

variable "cloudwatch_logs_enabled" {
  description = "Whether application logs should be reported to CloudWatch"
  default     = true
  type        = bool
}

variable "cloudwatch_logs_retention_days" {
  description = "The length of time in days to retain logs for"
  default     = 7
  type        = number
}

variable "java_opts" {
  description = "Custom JAVA Options"
  default     = "-XX:InitialRAMPercentage=75 -XX:MaxRAMPercentage=75"
  type        = string
}

# --- Auto-scaling options

variable "enable_auto_scaling" {
  description = "Whether to enable auto-scaling policies for the service (WARN: ensure you have sufficient db_connections available for the max number of nodes in the ASG)"
  default     = true
  type        = bool
}

variable "scale_up_cooldown_sec" {
  description = "Time (in seconds) until another scale-up action can occur"
  default     = 180
  type        = number
}

variable "scale_up_cpu_threshold_percentage" {
  description = "The average CPU percentage that must be exceeded to scale-up"
  default     = 60
  type        = number
}

variable "scale_up_eval_minutes" {
  description = "The number of consecutive minutes that the threshold must be breached to scale-up"
  default     = 5
  type        = number
}

variable "scale_down_cooldown_sec" {
  description = "Time (in seconds) until another scale-down action can occur"
  default     = 600
  type        = number
}

variable "scale_down_cpu_threshold_percentage" {
  description = "The average CPU percentage that we must be below to scale-down"
  default     = 20
  type        = number
}

variable "scale_down_eval_minutes" {
  description = "The number of consecutive minutes that we must be below the threshold to scale-down"
  default     = 60
  type        = number
}

# --- Configuration options

variable "db_sg_id" {
  description = "The ID of the RDS security group that sits downstream of the webserver"
  type        = string
}

variable "db_host" {
  description = "The hostname of the database to connect to"
  type        = string
}

variable "db_port" {
  description = "The port the database is running on"
  type        = number
}

variable "db_name" {
  description = "The name of the database to connect to"
  type        = string
}

variable "db_username" {
  description = "The username to use to connect to the database"
  type        = string
}

variable "db_password" {
  description = "The password to use to connect to the database"
  type        = string
  sensitive   = true
}

variable "super_api_key" {
  description = "A UUIDv4 string to use as the master API key for Iglu Server management"
  type        = string
  sensitive   = true
}

variable "patches_allowed" {
  description = "Whether or not patches are allowed for published Iglu Schemas"
  type        = bool
  default     = true
}

# --- Telemetry

variable "telemetry_enabled" {
  description = "Whether or not to send telemetry information back to Snowplow Analytics Ltd"
  type        = bool
  default     = true
}

variable "user_provided_id" {
  description = "An optional unique identifier to identify the telemetry events emitted by this stack"
  type        = string
  default     = ""
}

# --- Image Repositories

variable "private_ecr_registry" {
  description = "The URL of an ECR registry that the sub-account has access to (e.g. '000000000000.dkr.ecr.cn-north-1.amazonaws.com.cn/')"
  type        = string
  default     = ""
}
