# terraform { 
#  backend "s3" { 
#    bucket         = "cloudbox-terraform-state-35671859" 
#    key            = "cloudbox-enterprise/terraform.tfstate" 
#    region         = "us-east-1" 
#    dynamodb_table = "terraform-lock" 
#    encrypt        = true 
#  }
# } 

# Crear el bucket de S3 para el estado
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "cloudbox-terraform-state-35671859"
  force_destroy = true # Permite borrarlo fácilmente si vacías el lab
}

# Habilitar el cifrado del bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Crear la tabla de DynamoDB para el bloqueo de estado
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}