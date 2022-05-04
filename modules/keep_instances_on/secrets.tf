variable "email_creds_template" {
  default = {
    fromaddr = "username@domain here"
    server_fqdn = "fqdn of mail server"
    server_port = 587
    login_username = "username@domain here"
    login_password = "the users password here"
  }
  type = map
}


resource "aws_secretsmanager_secret" "email" {
  name = "keep-instances-running"
}

resource "aws_secretsmanager_secret_version" "email" {
  secret_id = aws_secretsmanager_secret.email.id
  secret_string = jsonencode(var.email_creds_template)
  lifecycle {
    ignore_changes = [secret_string]
  }
}



