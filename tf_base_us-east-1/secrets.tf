
resource "aws_secretsmanager_secret" "ssh_private_key" {
  name = "ssh_private_key"
  description = "This is meant to be a team-accessible key, not belonging to any one person."
}
resource "aws_secretsmanager_secret_version" "ssh_private_key" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key.id
  secret_string = "Private ssh key is manually entered via AWS Console. Must be OpenSSH format."
  lifecycle {
    ignore_changes = [secret_string]
  }
}
output "ssh_private_key_id" {
  value = aws_secretsmanager_secret.ssh_private_key.id
}



resource "aws_secretsmanager_secret" "ssh_public_key" {
  name = "ssh_public_key"
  description = "This is meant to be a team-accessible key, not belonging to any one person."
}
resource "aws_secretsmanager_secret_version" "ssh_public_key" {
  secret_id     = aws_secretsmanager_secret.ssh_public_key.id
  secret_string = "Public ssh key is manually entered via AWS Console. Must be OpenSSH format."
  lifecycle {
    ignore_changes = [secret_string]
  }
}
output "ssh_public_key_id" {
  value = aws_secretsmanager_secret.ssh_public_key.id
}