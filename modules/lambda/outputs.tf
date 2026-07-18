output "create_file_lambda_arn" { 
  value = aws_lambda_function.create_file.invoke_arn 
}

output "create_file_function_name" {
  value = aws_lambda_function.create_file.function_name
}

output "get_files_lambda_arn" { 
  value = aws_lambda_function.get_files.invoke_arn 
}

output "get_files_function_name" {
  value = aws_lambda_function.get_files.function_name
}

output "get_file_by_id_lambda_arn" { 
  value = aws_lambda_function.get_file_by_id.invoke_arn 
}

output "get_file_by_id_function_name" {
  value = aws_lambda_function.get_file_by_id.function_name
}

output "update_file_lambda_arn" { 
  value = aws_lambda_function.update_file.invoke_arn 
}

output "update_file_function_name" {
  value = aws_lambda_function.update_file.function_name
}

output "delete_file_lambda_arn" { 
  value = aws_lambda_function.delete_file.invoke_arn 
}

output "delete_file_function_name" {
  value = aws_lambda_function.delete_file.function_name
}