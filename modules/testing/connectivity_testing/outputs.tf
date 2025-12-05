output "lambda_function_name" {
  description = "Name of the connectivity testing Lambda function"
  value       = aws_lambda_function.connectivity_tester.function_name
}

output "lambda_function_arn" {
  description = "ARN of the connectivity testing Lambda function"
  value       = aws_lambda_function.connectivity_tester.arn
}

output "results_bucket_name" {
  description = "Name of the S3 bucket storing connectivity test results"
  value       = aws_s3_bucket.test_results.bucket
}

output "results_bucket_arn" {
  description = "ARN of the S3 bucket storing connectivity test results"
  value       = aws_s3_bucket.test_results.arn
}

output "alerts_topic_arn" {
  description = "ARN of the SNS topic for connectivity test alerts"
  value       = aws_sns_topic.connectivity_alerts.arn
}

output "lambda_security_group_id" {
  description = "ID of the security group attached to the Lambda function"
  value       = var.deploy_in_vpc ? aws_security_group.lambda[0].id : null
}

output "schedule_expression" {
  description = "Schedule expression for running connectivity tests"
  value       = var.schedule_expression
}

output "test_types" {
  description = "Types of connectivity tests being run"
  value       = var.test_types
}