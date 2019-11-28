resource "random_string" "name" {
  length  = 4
  special = false
  upper   = false
}

data "archive_file" "dir_hash_zip" {
  type        = "zip"
  source_dir  = "${var.source_code_path}/"
  output_path = "${path.module}/dir_hash_zip"
}

resource "null_resource" "install_python_dependencies" {
  triggers = {
    requirements = filesha1("${var.source_code_path}/requirements.txt")
    dir_hash     = data.archive_file.dir_hash_zip.output_base64sha256
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/py_pkg.sh"

    environment = {
      source_code_path = var.source_code_path
      path_cwd         = path.cwd
      path_module      = path.module
      runtime          = var.runtime
      function_name    = var.function_name
      random_string    = random_string.name.result
    }
  }
}

data "archive_file" "lambda_zip" {
  depends_on  = [null_resource.install_python_dependencies]
  type        = "zip"
  source_dir  = "${path.cwd}/lambda_pkg_${random_string.name.result}/"
  output_path = var.output_path
}

resource "aws_lambda_function" "lambda" {
  filename         = var.output_path
  description      = var.description
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda.arn
  function_name    = var.function_name
  handler          = var.handler_name
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  dynamic "environment" {
    for_each = length(var.environment) < 1 ? [] : [var.environment]
    content {
      variables = environment.value.variables
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_config) < 1 ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }

  tags = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = var.function_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_attachment" {
  count = length(var.vpc_config) < 1 ? 0 : 1
  role  = aws_iam_role.lambda.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_cloudwatch_log_group" "cloudwatch_logs" {
  name = "/aws/lambda/${var.function_name}"

  dynamic "retention_in_days" {
    for_each = length(var.retention_in_days) < 0 ? [] : [var.retention_in_days]
    content {
      retention_in_days = var.retention_in_days
    }
  }

  tags = var.tags
}