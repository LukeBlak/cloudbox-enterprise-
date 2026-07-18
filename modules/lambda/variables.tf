variable "lambda_role_arn" {
  description = "ARN del rol IAM para las funciones Lambda"
  type        = string
}
variable "sqs_queue_arn" {
  type        = string
  description = "ARN de la cola SQS para el trigger de la Lambda consumidora"
}
