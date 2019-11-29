output "function_name" {
  description = "Name of lambda function"
  value       = aws_lambda_function.lambda.function_name
}

output "arn" {
  description = "AWS arn of lambda function"
  value       = aws_lambda_function.lambda.arn
}

output "role_arn" {
  description = "ARN of IAM role to be attached to Lambda Function."
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "Name of IAM role to be attached to Lambda Function."
  value       = aws_iam_role.lambda.name
}