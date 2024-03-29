variable "make_instances" {
  type        = bool
  default     = true
  description = "Allows destroying & recreating just the instances."
}

variable "region" {
  type    = string
  default = "us-east-1"
}


variable "project" {
  type    = string
  default = "fogtesting"
}


variable "fogproject-aws-devops-repo" {
  type    = string
  default = "https://github.com/FOGProject/fogproject-aws-devops.git"
}


variable "fog-project-repo" {
  type    = string
  default = "https://github.com/FOGProject/fogproject.git"
}



# Manual lookup of AMIs from official provider websites.
# debian9 https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
# debian10 https://wiki.debian.org/Cloud/AmazonEC2Image/Buster
# centos https://wiki.centos.org/Cloud/AWS
# rhel https://access.redhat.com/articles/3135121
# fedora https://alt.fedoraproject.org/cloud/
# ubuntu https://cloud-images.ubuntu.com/locator/ec2/
# RockyLinux https://rockylinux.org/cloud-images/
# AlmaLinux https://wiki.almalinux.org/cloud/AWS.html#aws-marketplace

# Usernames:
# https://alestic.com/2014/01/ec2-ssh-username/
# https://asvignesh.in/default-user-name-for-the-linux-ami-in-amazon-aws/


data "aws_ami" "debian9" {
  most_recent = true
  owners      = ["379101102735"]
  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-*"]
  }
}


data "aws_ami" "debian10" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-10-amd64-*"]
  }
}


data "aws_ami" "debian11" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-11-amd64*"]
  }
}


data "aws_ami" "centos7" {
  most_recent = true
  owners      = ["741001768971"]
  filter {
    name   = "name"
    values = ["*centos7*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}



data "aws_ami" "alma8" {
  most_recent = true
  owners      = ["764336703387"]
  filter {
    name   = "name"
    values = ["AlmaLinux OS 8.* x86_64"]
  }
}



data "aws_ami" "alma9" {
  most_recent = true
  owners      = ["764336703387"]
  filter {
    name   = "name"
    values = ["AlmaLinux OS 9.* x86_64"]
  }
}



data "aws_ami" "rocky8" {
  most_recent = true
  owners      = ["792107900819"]
  filter {
    name   = "name"
    values = ["Rocky-8-ec2*x86_64"]
  }
}


data "aws_ami" "rhel8" {
  most_recent = true
  owners      = ["309956199498"]
  filter {
    name   = "name"
    values = ["RHEL-8.*_HVM-*-x86_64-0-Hourly2-GP2"]
  }
}


data "aws_ami" "rhel9" {
  most_recent = true
  owners      = ["309956199498"]
  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-0-Hourly2-GP2"]
  }
}


data "aws_ami" "fedora36" {
  most_recent = true
  owners      = ["125523088429"]
  filter {
    name   = "name"
    values = ["Fedora-Cloud-Base-36*x86_64-hvm-us-east-1-gp2-0"]
  }
}


data "aws_ami" "fedora37" {
  most_recent = true
  owners      = ["125523088429"]
  filter {
    name   = "name"
    values = ["Fedora-Cloud-Base-37*x86_64-hvm-us-east-1-gp2-0"]
  }
}




data "aws_ami" "ubuntu18" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


data "aws_ami" "ubuntu20" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


data "aws_ami" "ubuntu22" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}



