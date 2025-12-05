output "lambda_function_name" {
  description = "Name of the Lambda function for connectivity testing"
  value       = aws_lambda_function.connectivity_test.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function for connectivity testing"
  value       = aws_lambda_function.connectivity_test.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for connectivity test results"
  value       = aws_sns_topic.connectivity_test_results.arn
}