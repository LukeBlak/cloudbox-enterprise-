resource "aws_cognito_user_pool" "users" { 

 name = "CloudBoxUsers" 

 username_attributes = [ 

   "email" 

 ] 

 password_policy { 

   minimum_length = 8 

   require_lowercase = true 

   require_uppercase = true 

   require_numbers = true 

   require_symbols = true 

 } 

 mfa_configuration = "OFF" 

} 

resource "aws_cognito_user_pool_client" "client" {
  name         = "CloudBoxClient"
  user_pool_id = aws_cognito_user_pool.users.id

  # Agrega este bloque:
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",       # <--- ¡ESTA ES LA QUE TE ARREGLA EL ERROR!
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_AUTH"            # <--- Muy recomendada para las versiones más recientes de SDKs
  ]
}