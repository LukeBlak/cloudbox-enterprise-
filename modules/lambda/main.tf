data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "archive_file" "create_file_zip" {

  type = "zip"

  source_dir = "${path.root}/lambda/createFile"

  output_path = "${path.root}/lambda/createFile.zip"

}

resource "aws_lambda_function" "create_file" {

  function_name = "createFile"

  filename = data.archive_file.create_file_zip.output_path

  source_code_hash = data.archive_file.create_file_zip.output_base64sha256

  runtime = "nodejs20.x"

  handler = "index.handler"

  role = var.lambda_role_arn

  environment {

    variables = {

      QUEUE_URL = "https://sqs.${data.aws_region.current.name}.amazonaws.com/${data.aws_caller_identity.current.account_id}/documents-queue"

    }
  }
}

data "archive_file" "get_files_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/getFiles"
  output_path = "${path.root}/lambda/getFiles.zip"
}

resource "aws_lambda_function" "get_files" {
  function_name    = "getFiles"
  filename         = data.archive_file.get_files_zip.output_path
  source_code_hash = data.archive_file.get_files_zip.output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
}

data "archive_file" "get_file_by_id_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/getFileById"
  output_path = "${path.root}/lambda/getFileById.zip"
}

resource "aws_lambda_function" "get_file_by_id" {
  function_name    = "getFileById"
  filename         = data.archive_file.get_file_by_id_zip.output_path
  source_code_hash = data.archive_file.get_file_by_id_zip.output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
}

data "archive_file" "update_file_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/updateFile"
  output_path = "${path.root}/lambda/updateFile.zip"
}

resource "aws_lambda_function" "update_file" {
  function_name    = "updateFile"
  filename         = data.archive_file.update_file_zip.output_path
  source_code_hash = data.archive_file.update_file_zip.output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
}

data "archive_file" "delete_file_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/deleteFile"
  output_path = "${path.root}/lambda/deleteFile.zip"
}

resource "aws_lambda_function" "delete_file" {
  function_name    = "deleteFile"
  filename         = data.archive_file.delete_file_zip.output_path
  source_code_hash = data.archive_file.delete_file_zip.output_base64sha256
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  role             = var.lambda_role_arn
}

# 1. Empaquetar el código de la Lambda Consumidora
data "archive_file" "consumer_zip" {
  type        = "zip"
  source_dir  = "${path.root}/lambda/consumer"
  output_path = "${path.root}/lambda/consumer.zip"
}

# 2. Crear la Lambda Consumidora
resource "aws_lambda_function" "consumer" {
  filename         = data.archive_file.consumer_zip.output_path
  function_name    = "documents-consumer"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.consumer_zip.output_base64sha256
  runtime          = "nodejs20.x"

  environment {
    variables = {
      TABLE_NAME = "Files" # O la variable de tu tabla DynamoDB si la pasas por variables
    }
  }
}

# 3. Conectar la cola SQS con la Lambda (Event Source Mapping)
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_queue_arn # Ver nota en el Paso 3
  function_name    = aws_lambda_function.consumer.arn
  batch_size       = 1
}

