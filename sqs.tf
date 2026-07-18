resource "aws_sqs_queue" "documents_dlq" {

  name = "documents-dlq"

}
resource "aws_sqs_queue" "documents_queue" {

  name = "documents-queue"

  visibility_timeout_seconds = 30

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.documents_dlq.arn
    maxReceiveCount     = 3
  })

}
