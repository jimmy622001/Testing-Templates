/**
 * # Connectivity Testing Module
 * 
 * This module creates infrastructure to test various AWS connectivity patterns including:
 * - Site-to-Site VPN
 * - Client VPN
 * - Private Link
 * - Internet Gateway
 * - AWS SFTP
 * - Route 53 (Public/Private Hosted Zones)
 * - DNS Firewall
 * - VPC endpoints
 * - Network Firewall
 * - Transit Gateway
 * - NAT Gateway
 * - Load Balancers
 */

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

locals {
  lambda_function_name = "${var.name_prefix}-connectivity-tester"
  role_name           = "${var.name_prefix}-connectivity-tester-role"
  s3_bucket_name      = "${var.name_prefix}-connectivity-test-results-${data.aws_caller_identity.current.account_id}"
  log_group_name      = "/aws/lambda/${local.lambda_function_name}"
  
  connectivity_test_types = [
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

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Lambda IAM Role
resource "aws_iam_role" "connectivity_tester" {
  name = local.role_name
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda IAM Policy
resource "aws_iam_policy" "connectivity_tester" {
  name = "${var.name_prefix}-connectivity-tester-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "ec2:DescribeVpnConnections",
          "ec2:DescribeClientVpnEndpoints",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "network-firewall:DescribeFirewall",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:TestDNSAnswer",
          "route53resolver:ListFirewallRuleGroups",
          "route53resolver:ListFirewallRules",
          "route53resolver:ListFirewallDomainLists",
          "route53resolver:ListResolverEndpoints",
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "transfer:ListServers",
          "transfer:DescribeServer",
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "connectivity_tester" {
  role       = aws_iam_role.connectivity_tester.name
  policy_arn = aws_iam_policy.connectivity_tester.arn
}

# S3 bucket for test results
resource "aws_s3_bucket" "test_results" {
  bucket = local.s3_bucket_name

  tags = merge(var.tags, {
    Name = local.s3_bucket_name
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "test_results" {
  bucket = aws_s3_bucket.test_results.id

  rule {
    id     = "auto-expire"
    status = "Enabled"

    expiration {
      days = var.results_retention_days
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "connectivity_tester" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_days
}

# Zip the Lambda function code
data "archive_file" "connectivity_tester" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/connectivity_tester.zip"
}

# Lambda function
resource "aws_lambda_function" "connectivity_tester" {
  function_name    = local.lambda_function_name
  role             = aws_iam_role.connectivity_tester.arn
  handler          = "index.handler"
  filename         = data.archive_file.connectivity_tester.output_path
  source_code_hash = data.archive_file.connectivity_tester.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = 300
  memory_size      = 512

  environment {
    variables = {
      RESULTS_BUCKET       = aws_s3_bucket.test_results.bucket
      VPC_ID               = var.vpc_id
      SUBNETS              = join(",", var.subnets)
      TEST_TYPES           = join(",", var.test_types)
      ENABLE_DETAILED_LOGS = var.enable_detailed_logs ? "true" : "false"
    }
  }

  vpc_config {
    subnet_ids         = var.deploy_in_vpc ? var.subnets : []
    security_group_ids = var.deploy_in_vpc ? [aws_security_group.lambda[0].id] : []
  }

  tags = var.tags

  depends_on = [
    aws_cloudwatch_log_group.connectivity_tester
  ]
}

# Security group for Lambda function when deployed in VPC
resource "aws_security_group" "lambda" {
  count = var.deploy_in_vpc ? 1 : 0
  
  name        = "${var.name_prefix}-connectivity-tester-sg"
  description = "Security group for connectivity tester Lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-connectivity-tester-sg"
  })
}

# CloudWatch Event Rule - Schedule the connectivity tests
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.name_prefix}-connectivity-test-schedule"
  description         = "Schedule for running connectivity tests"
  schedule_expression = var.schedule_expression
  is_enabled          = var.enable_scheduled_tests
}

# CloudWatch Event Target - Trigger Lambda on schedule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "TriggerConnectivityTests"
  arn       = aws_lambda_function.connectivity_tester.arn
}

# Lambda permission - Allow CloudWatch Events to invoke Lambda
resource "aws_lambda_permission" "cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connectivity_tester.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

# SNS Topic for alerts
resource "aws_sns_topic" "connectivity_alerts" {
  name = "${var.name_prefix}-connectivity-alerts"
  
  tags = var.tags
}

# SNS Subscription for email alerts
resource "aws_sns_topic_subscription" "email" {
  count     = length(var.alert_emails) > 0 ? length(var.alert_emails) : 0
  topic_arn = aws_sns_topic.connectivity_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_emails[count.index]
}

# CloudWatch Alarm for failed connectivity tests
resource "aws_cloudwatch_metric_alarm" "failed_tests" {
  alarm_name          = "${var.name_prefix}-connectivity-test-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "This alarm monitors for connectivity test failures"
  
  dimensions = {
    FunctionName = aws_lambda_function.connectivity_tester.function_name
  }
  
  alarm_actions = [aws_sns_topic.connectivity_alerts.arn]
}