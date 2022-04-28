# Introduction

This stack sets up foundational components which are shared across us-east-1. This includes the VPC, subnets, routes, dhcp option sets, team secrets via secrets manager, and a regional logging bucket. Other items that are useful to other Terraform stacks may be added here.

## SSH secrets

The `secrets.tf` file produces two AWS Secrets Manager resources. One for a public ssh key, one for a private ssh key. These keys are to guard against team members leaving while having the only copies of ssh keys.

Upon first-run of this Terraform, it will error when trying to create the EC2 keypair from the secrets manager secret value. This is expected, and it's because no public key is entered into Secrets Manager yet. After first-run, you can generate a new SSH keypair like so locally:

```
cd ~/.ssh
ssh-keygen -b 4086
# Do not add a password.
```

Place a copy of the public key into the public key secrets manager resource, and a copy of the private key into the private secrets manaer resource. Then run Terraform again, it should succeed.

Team members whom have access to the AWS account are free to use this SSH key, as well as rotate this SSH key. Though, when the key is rotated, downstream instances configured to use this key via Terraform will be rebuilt by Terraform. So this should be considered during key rotation. Instances, if rebuilt, should self-configure via user_data or other automation by themselves.




