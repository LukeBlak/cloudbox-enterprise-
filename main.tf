# Laboratorio 10 CI/CD 

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "cognito" {
  source = "./modules/cognito"
}

module "iam" {
  source = "./modules/iam"
}

module "lambda" {
  source          = "./modules/lambda"
  lambda_role_arn = module.iam.lambda_role_arn
  sqs_queue_arn   = aws_sqs_queue.documents_queue.arn
}

module "apigateway" {
  source = "./modules/apigateway"

  create_file_lambda_arn       = module.lambda.create_file_lambda_arn
  create_file_function_name    = module.lambda.create_file_function_name
  get_files_lambda_arn         = module.lambda.get_files_lambda_arn
  get_files_function_name      = module.lambda.get_files_function_name
  get_file_by_id_lambda_arn    = module.lambda.get_file_by_id_lambda_arn
  get_file_by_id_function_name = module.lambda.get_file_by_id_function_name
  update_file_lambda_arn       = module.lambda.update_file_lambda_arn
  update_file_function_name    = module.lambda.update_file_function_name
  delete_file_lambda_arn       = module.lambda.delete_file_lambda_arn
  delete_file_function_name    = module.lambda.delete_file_function_name

  cognito_user_pool_arn = module.cognito.user_pool_arn
}

module "frontend" {

  source = "./modules/frontend"

  project_name = var.project_name

  region = var.aws_region

  api_url = var.api_url

  user_pool_id = var.user_pool_id

  client_id = var.client_id

}
