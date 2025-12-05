variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to test connectivity"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Lambda function to run in"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for Lambda function"
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID to test connectivity"
  type        = string
  default     = ""
}

variable "route53_hosted_zone_ids" {
  description = "List of Route53 Hosted Zone IDs to test"
  type        = list(string)
  default     = []
}

variable "endpoint_service_names" {
  description = "List of VPC Endpoint Service Names to test"
  type        = list(string)
  default     = []
}

variable "s3_bucket_name" {
  description = "S3 bucket name to test connectivity"
  type        = string
  default     = ""
}

variable "elb_names" {
  description = "List of ELB names to test connectivity"
  type        = list(string)
  default     = []
}

variable "rds_endpoints" {
  description = "List of RDS endpoints to test connectivity"
  type        = list(string)
  default     = []
}

variable "eks_cluster_name" {
  description = "EKS cluster name to test connectivity"
  type        = string
  default     = ""
}

variable "cloudfront_distribution_ids" {
  description = "List of CloudFront distribution IDs to test"
  type        = list(string)
  default     = []
}

variable "api_gateway_ids" {
  description = "List of API Gateway IDs to test"
  type        = list(string)
  default     = []
}

variable "sns_topic_arns" {
  description = "List of SNS Topic ARNs to test"
  type        = list(string)
  default     = []
}

variable "sqs_queue_urls" {
  description = "List of SQS Queue URLs to test"
  type        = list(string)
  default     = []
}

variable "ecr_repository_names" {
  description = "List of ECR Repository names to test"
  type        = list(string)
  default     = []
}

variable "lambda_function_names" {
  description = "List of Lambda function names to test"
  type        = list(string)
  default     = []
}

variable "msk_cluster_arn" {
  description = "MSK Cluster ARN to test connectivity"
  type        = string
  default     = ""
}

variable "vpn_connection_ids" {
  description = "List of VPN Connection IDs to test"
  type        = list(string)
  default     = []
}

variable "client_vpn_endpoint_ids" {
  description = "List of Client VPN Endpoint IDs to test"
  type        = list(string)
  default     = []
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression for running the connectivity tests"
  type        = string
  default     = "rate(1 hour)"
}

variable "enable_scheduled_tests" {
  description = "Whether to enable scheduled tests"
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Email address to send test results to"
  type        = string
  default     = ""
}