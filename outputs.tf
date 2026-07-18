output "frontend_url" {

  value = module.frontend.frontend_url

}

output "bucket_name" {

  value = module.frontend.bucket_name

}

output "cloudfront_domain" {

  value = module.frontend.cloudfront_domain

}

output "documents_queue_url" {
  value = aws_sqs_queue.documents_queue.id

}
