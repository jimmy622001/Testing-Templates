locals {
  default_tags = {
    Environment = var.environment
    Owner       = var.owner
    Project     = var.project
    Terraform   = "true"
  }
}

# Lambda IAM role for connectivity testing
resource "aws_iam_role" "connectivity_test_role" {
  name = "${var.project}-${var.environment}-connectivity-test-role"

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

  tags = local.default_tags
}

# IAM policy for connectivity testing
resource "aws_iam_policy" "connectivity_test_policy" {
  name        = "${var.project}-${var.environment}-connectivity-test-policy"
  description = "Policy for connectivity testing Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeNatGateways",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpnConnections",
          "ec2:DescribeClientVpnEndpoints",
          "ec2:DescribeSecurityGroups",
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53resolver:ListResolverEndpoints",
          "route53resolver:ListResolverRules",
          "route53resolver:ListFirewallRuleGroups",
          "route53resolver:ListFirewallRuleGroupAssociations",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "networkfirewall:ListFirewalls",
          "networkfirewall:DescribeFirewall",
          "securityhub:GetFindings",
          "secretsmanager:ListSecrets",
          "kms:ListKeys",
          "kms:DescribeKey",
          "acm-pca:ListCertificateAuthorities",
          "iam:ListRoles",
          "iam:GetRole",
          "transfer:ListServers",
          "inspector2:ListFindings",
          "guardduty:ListDetectors",
          "eks:ListClusters",
          "eks:DescribeCluster",
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters",
          "autoscaling:DescribeAutoScalingGroups",
          "ses:GetSendQuota",
          "sns:ListTopics",
          "sqs:ListQueues",
          "ecr:DescribeRepositories",
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "wafv2:ListWebACLs",
          "cloudfront:ListDistributions",
          "apigateway:GET",
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "ecs:ListServices",
          "lambda:ListFunctions",
          "kafka:ListClusters",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })

  tags = local.default_tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "connectivity_test_policy_attachment" {
  role       = aws_iam_role.connectivity_test_role.name
  policy_arn = aws_iam_policy.connectivity_test_policy.arn
}

# Lambda function for connectivity testing
resource "aws_lambda_function" "connectivity_test" {
  function_name = "${var.project}-${var.environment}-connectivity-test"
  role          = aws_iam_role.connectivity_test_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 300
  memory_size   = 256

  filename         = "${path.module}/lambda/connectivity_test.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/connectivity_test.zip")

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      LOG_LEVEL                 = "INFO"
      VPC_ID                    = var.vpc_id
      TRANSIT_GATEWAY_ID        = var.transit_gateway_id
      ROUTE53_HOSTED_ZONE_IDS   = join(",", var.route53_hosted_zone_ids)
      ENDPOINT_SERVICE_NAMES    = join(",", var.endpoint_service_names)
      S3_BUCKET_NAME            = var.s3_bucket_name
      ELB_NAMES                 = join(",", var.elb_names)
      RDS_ENDPOINTS             = join(",", var.rds_endpoints)
      EKS_CLUSTER_NAME          = var.eks_cluster_name
      CLOUDFRONT_DISTRIBUTIONS  = join(",", var.cloudfront_distribution_ids)
      API_GATEWAY_IDS           = join(",", var.api_gateway_ids)
      SNS_TOPIC_ARNS            = join(",", var.sns_topic_arns)
      SQS_QUEUE_URLS            = join(",", var.sqs_queue_urls)
      ECR_REPOSITORY_NAMES      = join(",", var.ecr_repository_names)
      LAMBDA_FUNCTION_NAMES     = join(",", var.lambda_function_names)
      MSK_CLUSTER_ARN           = var.msk_cluster_arn
      VPN_CONNECTION_IDS        = join(",", var.vpn_connection_ids)
      CLIENT_VPN_ENDPOINT_IDS   = join(",", var.client_vpn_endpoint_ids)
    }
  }

  tags = local.default_tags

  depends_on = [aws_iam_role_policy_attachment.connectivity_test_policy_attachment]
}

# CloudWatch Log Group for Lambda function
resource "aws_cloudwatch_log_group" "connectivity_test_logs" {
  name              = "/aws/lambda/${aws_lambda_function.connectivity_test.function_name}"
  retention_in_days = 14
  tags              = local.default_tags
}

# SNS Topic for test results
resource "aws_sns_topic" "connectivity_test_results" {
  name = "${var.project}-${var.environment}-connectivity-test-results"
  tags = local.default_tags
}

# CloudWatch Event Rule to trigger the test
resource "aws_cloudwatch_event_rule" "connectivity_test_schedule" {
  name                = "${var.project}-${var.environment}-connectivity-test-schedule"
  description         = "Schedule for connectivity testing"
  schedule_expression = var.schedule_expression
  is_enabled          = var.enable_scheduled_tests
  tags                = local.default_tags
}

# Target for the CloudWatch Event Rule
resource "aws_cloudwatch_event_target" "connectivity_test_target" {
  rule      = aws_cloudwatch_event_rule.connectivity_test_schedule.name
  target_id = "ConnectivityTest"
  arn       = aws_lambda_function.connectivity_test.arn
}

# Permission for CloudWatch Events to invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.connectivity_test.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.connectivity_test_schedule.arn
}