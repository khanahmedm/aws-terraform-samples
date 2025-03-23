variable "lambda_name" {}
variable "s3_bucket_name" {}

resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda_s3_policy"
  description = "Allow Lambda to write to S3"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.bucket.bucket
    }
  }
}

output "lambda_arn" {
  value = aws_lambda_function.lambda.arn
}

output "step_function_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}
