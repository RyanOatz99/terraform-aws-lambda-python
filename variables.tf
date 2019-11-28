
variable "description" {
  description = "Description of what your Lambda Function does."
}

variable "function_name" {
  description = "A unique name for your Lambda Function"
}

variable "handler_name" {
  description = "The function entrypoint in your code."
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime."
  default     = "128"
}

variable "runtime" {
  description = "runtime"
  default     = "python3.7"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds. Defaults to 5 minutes"
  default     = "300"
}

variable "source_code_path" {
  description = "Path to the source file or directory containing your Lambda source code & requirements.txt if applicable"
}

variable "output_path" {
  description = "Path to the function's deployment package within local filesystem. eg: /path/to/lambda.zip"
  default     = "lambda.zip"
}

variable "environment" {
  description = "Environment variables for the Lambda function"
  type        = map(any)
  default     = {}
}

variable "vpc_config" {
  description = "Provide this to allow your function to access your VPC (if both 'subnet_ids' and 'security_group_ids' are empty then vpc_config is considered to be empty or unset, see https://docs.aws.amazon.com/lambda/latest/dg/vpc.html for details)."
  type        = map(list(string))
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to the Lambda function."
  type        = map(string)
  default     = {}
}

variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Defaults to 7 days."
  default     = 7
}
