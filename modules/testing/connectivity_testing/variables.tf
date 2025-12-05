variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "connectivity"
}

variable "vpc_id" {
  description = "VPC ID for connectivity testing"
  type        = string
  default     = ""
}

variable "subnets" {
  description = "List of subnet IDs for connectivity testing"
  type        = list(string)
  default     = []
}

variable "deploy_in_vpc" {
  description = "Whether to deploy the Lambda function inside a VPC"
  type        = bool
  default     = true
}

variable "test_types" {
  description = "Types of connectivity tests to run"
  type        = list(string)
  default     = [
    "site-to-site-vpn",
    "client-vpn",
    "privatelink",
    "internet-gateway",
    "aws-sftp",
    "route53",
    "vpc-endpoints",
    "network-firewall",
    "nat-gateway",
    "transit-gateway"
  ]
}

variable "schedule_expression" {
  description = "Schedule expression for running tests (cron or rate expression)"
  type        = string
  default     = "rate(1 hour)"
}

variable "enable_scheduled_tests" {
  description = "Whether to enable scheduled connectivity tests"
  type        = bool
  default     = true
}

variable "alert_emails" {
  description = "List of email addresses to notify on test failures"
  type        = list(string)
  default     = []
}

variable "results_retention_days" {
  description = "Number of days to retain test results in S3"
  type        = number
  default     = 30
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "enable_detailed_logs" {
  description = "Enable detailed logging for connectivity tests"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}