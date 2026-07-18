# ============================================
# PARTE IX - Recursos de la API
# ============================================

resource "aws_api_gateway_rest_api" "files_api" { 
  name        = "FilesAPI" 
  description = "API REST para gestión de archivos" 
}

resource "aws_api_gateway_resource" "v1" { 
  rest_api_id = aws_api_gateway_rest_api.files_api.id 
  parent_id   = aws_api_gateway_rest_api.files_api.root_resource_id 
  path_part   = "v1" 
}

resource "aws_api_gateway_resource" "files" { 
  rest_api_id = aws_api_gateway_rest_api.files_api.id 
  parent_id   = aws_api_gateway_resource.v1.id 
  path_part   = "files" 
}

resource "aws_api_gateway_resource" "file_id" { 
  rest_api_id = aws_api_gateway_rest_api.files_api.id 
  parent_id   = aws_api_gateway_resource.files.id 
  path_part   = "{id}" 
}

# ============================================
# PARTE XII - Cognito Authorizer (ANTES DE LOS MÉTODOS)
# ============================================

resource "aws_api_gateway_authorizer" "cognito" { 
  name          = "CloudBoxAuthorizer" 
  rest_api_id   = aws_api_gateway_rest_api.files_api.id 
  type          = "COGNITO_USER_POOLS" 
  provider_arns = [var.cognito_user_pool_arn]
}

# ============================================
# PARTE X - Métodos REST
# ============================================

resource "aws_api_gateway_method" "post_files" { 
  rest_api_id      = aws_api_gateway_rest_api.files_api.id 
  resource_id      = aws_api_gateway_resource.files.id 
  http_method      = "POST" 
  authorization    = "COGNITO_USER_POOLS" 
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = true 
}

resource "aws_api_gateway_method" "get_files" { 
  rest_api_id      = aws_api_gateway_rest_api.files_api.id 
  resource_id      = aws_api_gateway_resource.files.id 
  http_method      = "GET" 
  authorization    = "COGNITO_USER_POOLS" 
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = true 
}

resource "aws_api_gateway_method" "get_file_by_id" { 
  rest_api_id      = aws_api_gateway_rest_api.files_api.id 
  resource_id      = aws_api_gateway_resource.file_id.id 
  http_method      = "GET" 
  authorization    = "COGNITO_USER_POOLS" 
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = true 
}

resource "aws_api_gateway_method" "update_file" { 
  rest_api_id      = aws_api_gateway_rest_api.files_api.id 
  resource_id      = aws_api_gateway_resource.file_id.id 
  http_method      = "PUT" 
  authorization    = "COGNITO_USER_POOLS" 
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = true 
}

resource "aws_api_gateway_method" "delete_file" { 
  rest_api_id      = aws_api_gateway_rest_api.files_api.id 
  resource_id      = aws_api_gateway_resource.file_id.id 
  http_method      = "DELETE" 
  authorization    = "COGNITO_USER_POOLS" 
  authorizer_id    = aws_api_gateway_authorizer.cognito.id
  api_key_required = true 
}

# ============================================
# PARTE XI - Integraciones
# ============================================

resource "aws_api_gateway_integration" "create_file" { 
  rest_api_id             = aws_api_gateway_rest_api.files_api.id 
  resource_id             = aws_api_gateway_resource.files.id 
  http_method             = aws_api_gateway_method.post_files.http_method 
  integration_http_method = "POST" 
  type                    = "AWS_PROXY" 
  uri                     = var.create_file_lambda_arn
}

resource "aws_api_gateway_integration" "get_files" { 
  rest_api_id             = aws_api_gateway_rest_api.files_api.id 
  resource_id             = aws_api_gateway_resource.files.id 
  http_method             = aws_api_gateway_method.get_files.http_method 
  integration_http_method = "POST" 
  type                    = "AWS_PROXY" 
  uri                     = var.get_files_lambda_arn
}

resource "aws_api_gateway_integration" "get_file_by_id" { 
  rest_api_id             = aws_api_gateway_rest_api.files_api.id
  resource_id             = aws_api_gateway_resource.file_id.id
  http_method             = aws_api_gateway_method.get_file_by_id.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.get_file_by_id_lambda_arn
}

resource "aws_api_gateway_integration" "update_file" { 
  rest_api_id             = aws_api_gateway_rest_api.files_api.id 
  resource_id             = aws_api_gateway_resource.file_id.id 
  http_method             = aws_api_gateway_method.update_file.http_method 
  integration_http_method = "POST" 
  type                    = "AWS_PROXY" 
  uri                     = var.update_file_lambda_arn
}

resource "aws_api_gateway_integration" "delete_file" { 
  rest_api_id             = aws_api_gateway_rest_api.files_api.id 
  resource_id             = aws_api_gateway_resource.file_id.id 
  http_method             = aws_api_gateway_method.delete_file.http_method 
  integration_http_method = "POST" 
  type                    = "AWS_PROXY" 
  uri                     = var.delete_file_lambda_arn
}

# ============================================
# PARTE XI - Permisos Lambda
# ============================================

resource "aws_lambda_permission" "allow_create" { 
  statement_id  = "AllowExecutionFromAPIGateway" 
  action        = "lambda:InvokeFunction" 
  function_name = var.create_file_function_name
  principal     = "apigateway.amazonaws.com" 
}

resource "aws_lambda_permission" "allow_get_files" { 
  statement_id  = "AllowExecutionFromAPIGateway" 
  action        = "lambda:InvokeFunction" 
  function_name = var.get_files_function_name
  principal     = "apigateway.amazonaws.com" 
}

resource "aws_lambda_permission" "allow_get_file_by_id" { 
  statement_id  = "AllowExecutionFromAPIGateway" 
  action        = "lambda:InvokeFunction" 
  function_name = var.get_file_by_id_function_name
  principal     = "apigateway.amazonaws.com" 
}

resource "aws_lambda_permission" "allow_update" { 
  statement_id  = "AllowExecutionFromAPIGateway" 
  action        = "lambda:InvokeFunction" 
  function_name = var.update_file_function_name
  principal     = "apigateway.amazonaws.com" 
}

resource "aws_lambda_permission" "allow_delete" { 
  statement_id  = "AllowExecutionFromAPIGateway" 
  action        = "lambda:InvokeFunction" 
  function_name = var.delete_file_function_name
  principal     = "apigateway.amazonaws.com" 
}

# ============================================
# PARTE XIII - API Key y Usage Plan
# ============================================

resource "aws_api_gateway_api_key" "files_api_key" { 
  name    = "FilesAPIKey" 
  enabled = true 
} 

resource "aws_api_gateway_usage_plan" "files_usage_plan" { 
  name = "FilesUsagePlan" 

  # --- AGREGAR ESTE BLOQUE ---
  api_stages {
    api_id = aws_api_gateway_rest_api.files_api.id
    stage  = aws_api_gateway_stage.dev.stage_name
  }
  # ---------------------------

  throttle_settings { 
    burst_limit = 20 
    rate_limit  = 10 
  } 
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" { 
  key_id        = aws_api_gateway_api_key.files_api_key.id 
  key_type      = "API_KEY" 
  usage_plan_id = aws_api_gateway_usage_plan.files_usage_plan.id 
}

# ============================================
# PARTE XIV - Deployment y Stage
# ============================================

resource "aws_api_gateway_deployment" "deployment" { 
  rest_api_id = aws_api_gateway_rest_api.files_api.id 

  depends_on = [ 
    aws_api_gateway_integration.create_file,
    aws_api_gateway_integration.get_files,
    aws_api_gateway_integration.get_file_by_id,
    aws_api_gateway_integration.update_file,
    aws_api_gateway_integration.delete_file,
    aws_api_gateway_integration.options_files_integration,
    aws_api_gateway_integration.options_file_id_integration
  ] 
}

resource "aws_api_gateway_stage" "dev" { 
  deployment_id = aws_api_gateway_deployment.deployment.id 
  rest_api_id   = aws_api_gateway_rest_api.files_api.id 
  stage_name    = "dev" 
}

# ============================================
# SOPORTE CORS (MÉTODO OPTIONS PARA RECURSO /files)
# ============================================

resource "aws_api_gateway_method" "options_files" {
  rest_api_id   = aws_api_gateway_rest_api.files_api.id
  resource_id   = aws_api_gateway_resource.files.id
  http_method   = "OPTIONS"
  authorization = "NONE" # Las solicitudes Preflight de CORS no llevan autenticación
}

resource "aws_api_gateway_integration" "options_files_integration" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.options_files.http_method
  type        = "MOCK" # Respondemos directamente sin ir a la Lambda

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_files_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.options_files.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "get_files_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.get_files.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "post_files_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.post_files.http_method
  status_code = "201"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "options_files_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.options_files.http_method
  status_code = aws_api_gateway_method_response.options_files_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_files_integration]
}

resource "aws_api_gateway_integration_response" "get_files_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.get_files.http_method
  status_code = aws_api_gateway_method_response.get_files_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.get_files]
}

resource "aws_api_gateway_integration_response" "post_files_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.post_files.http_method
  status_code = aws_api_gateway_method_response.post_files_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.create_file]
}
resource "aws_api_gateway_integration_response" "get_file_by_id_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.get_file_by_id.http_method
  status_code = aws_api_gateway_method_response.get_file_by_id_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.get_file_by_id]
}

resource "aws_api_gateway_integration_response" "update_file_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.update_file.http_method
  status_code = aws_api_gateway_method_response.update_file_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.update_file]
}

resource "aws_api_gateway_integration_response" "delete_file_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.delete_file.http_method
  status_code = aws_api_gateway_method_response.delete_file_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.delete_file]
}
# ============================================
# SOPORTE CORS (MÉTODO OPTIONS PARA RECURSO /{id})
# ============================================

resource "aws_api_gateway_method" "options_file_id" {
  rest_api_id   = aws_api_gateway_rest_api.files_api.id
  resource_id   = aws_api_gateway_resource.file_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_file_id_integration" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.options_file_id.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_file_id_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.options_file_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "get_file_by_id_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.get_file_by_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "update_file_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.update_file.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "delete_file_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.delete_file.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "options_file_id_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.files_api.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.options_file_id.http_method
  status_code = aws_api_gateway_method_response.options_file_id_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_file_id_integration]
}