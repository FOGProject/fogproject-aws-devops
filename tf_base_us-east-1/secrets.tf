
resource "random_string" "ssh_key_random_name_append" {
  length  = 4
  special = false
  lower   = true
  numeric  = true
  upper   = false
}


resource "aws_secretsmanager_secret" "ssh_private_key" {
  name        = "ssh_private_key_${random_string.ssh_key_random_name_append.result}"
  description = "This is meant to be a team-accessible key, not belonging to any one person."
}
resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key.id
  secret_string = "Private ssh key is manually entered via AWS Console. Must be OpenSSH format."
  lifecycle {
    ignore_changes = [secret_string]
  }
}
output "ssh_private_key_arn" {
  value = aws_secretsmanager_secret.ssh_private_key.arn
}



resource "aws_secretsmanager_secret" "ssh_public_key" {
  name        = "ssh_public_key_${random_string.ssh_key_random_name_append.result}"
  description = "This is meant to be a team-accessible key, not belonging to any one person."
}
resource "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id     = aws_secretsmanager_secret.ssh_public_key.id
  secret_string = "Public ssh key is manually entered via AWS Console. Must be OpenSSH format."
  lifecycle {
    ignore_changes = [secret_string]
  }
}
data "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id = aws_secretsmanager_secret.ssh_public_key.id
}
resource "aws_key_pair" "ssh_public_key" {
  key_name   = "ssh_public_key_${random_string.ssh_key_random_name_append.result}"
  public_key = data.aws_secretsmanager_secret_version.ssh_public_key.secret_string
}
output "ssh_public_key_name" {
  value = aws_key_pair.ssh_public_key.key_name
}