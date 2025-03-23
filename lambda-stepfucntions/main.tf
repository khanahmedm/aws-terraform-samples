provider "aws" {
  region = "us-east-1"
}

module "lambda" {
  source          = "./lambda"
  lambda_name     = "hello-world-lambda"
  s3_bucket_name  = "hello-world-s3-bucket-amk"
}

module "step_function" {
  source       = "./step_function"
  lambda_arn   = module.lambda.lambda_arn
  role_arn     = module.lambda.step_function_role_arn
}
