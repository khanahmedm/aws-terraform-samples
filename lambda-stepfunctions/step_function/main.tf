variable "lambda_arn" {}
variable "role_arn" {}

resource "aws_iam_role" "step_function_role" {
  name = "step_function_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "step_function_policy" {
  name = "step_function_policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["lambda:InvokeFunction"]
        Effect   = "Allow"
        Resource = var.lambda_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_policy_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}

resource "aws_sfn_state_machine" "step_function" {
  name     = "LambdaStepFunction"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "Invoke Lambda to write Hello World to S3",
    StartAt = "InvokeLambda",
    States = {
      InvokeLambda = {
        Type     = "Task",
        Resource = var.lambda_arn,
        End      = true
      }
    }
  })
}
