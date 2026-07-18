terraform { 
 backend "s3" { 
   bucket         = "cloudbox-terraform-state-58769423" 
   key            = "cloudbox-enterprise/terraform.tfstate" 
   region         = "us-east-1" 
   dynamodb_table = "terraform-lock" 
   encrypt        = true 
 }
} 