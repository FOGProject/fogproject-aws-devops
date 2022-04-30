resource "aws_instance" "bastion" {
  count                       = var.make_instances ? 1 : 0
  ami                         = data.aws_ami.debian11.id
  instance_type               = "t3.nano"
  subnet_id                   = data.terraform_remote_state.base.outputs.public_subnet_a
  vpc_security_group_ids      = [data.terraform_remote_state.base.outputs.sg_ssh_from_anywhere, data.terraform_remote_state.base.outputs.sg_internet_connectivity, aws_security_group.bastion_instance.id]
  associate_public_ip_address = true
  key_name                    = data.terraform_remote_state.base.outputs.ssh_public_key_name
  iam_instance_profile        = aws_iam_instance_profile.profile[0].name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    tags = {
      Name = "${var.project}-bastion"
    }
  }

  tags = {
    Name = "${var.project}-bastion"
  }
  lifecycle {
    ignore_changes = [
      associate_public_ip_address, ami, root_block_device[0].volume_type,
    ]
  }

  user_data = <<END_OF_USERDATA
#!/bin/bash
apt-get update
apt-get -y dist-upgrade
apt-get -y install awscli groff python3 python3-pip git vim jq
pip3 install boto3
aws secretsmanager get-secret-value --region ${var.region} --secret-id ${data.terraform_remote_state.base.outputs.ssh_private_key_arn} | jq -r .SecretString > /home/admin/.ssh/id_rsa

chmod 400 /home/admin/.ssh/id_rsa
echo '${data.template_file.ssh-config.rendered}' > /home/admin/.ssh/config
mkdir -p /home/admin/.aws
echo '${data.template_file.aws-config.rendered}' > /home/admin/.aws/config
chmod 600 /home/admin/.aws/config
sed -i.bak 's/set mouse=a/\"set mouse=a/' /usr/share/vim/vim82/defaults.vim
git clone ${var.fogproject-aws-devops-repo} /home/admin/fogproject-aws-devops

# Fix all permissions, because user_data is run as root.
chown -R admin:admin /home/admin

# Setup cron file to run tests.
cat > /etc/cron.d/run_tests<<my_awesome_cron_file
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
0 12 * * * admin /home/admin/fogproject-aws-devops/fog_testing/scripts/test_all.py
my_awesome_cron_file

(sleep 10 && reboot)&
END_OF_USERDATA
}

resource "aws_iam_instance_profile" "profile" {
  count = var.make_instances ? 1 : 0
  name  = "bastion_profile"
  role  = aws_iam_role.role[0].name
}

resource "aws_iam_role_policy" "policy" {
  count = var.make_instances ? 1 : 0
  name  = "bastion_policy"
  role  = aws_iam_role.role[0].id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ReadPrivateSshKey",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "${data.terraform_remote_state.base.outputs.ssh_private_key_arn}"
        },
        {
            "Sid": "s3Perms",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "${aws_s3_bucket.results_bucket.arn}",
                "${aws_s3_bucket.results_bucket.arn}/*"
            ],
            "Condition": {"IpAddress": {"aws:SourceIp": "${aws_instance.bastion[0].public_ip}/32"}}
        },
        {
            "Sid": "ec2ReadPerms",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeSnapshotAttribute",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeTags"
            ],
            "Resource": "*",
            "Condition": {"IpAddress": {"aws:SourceIp": "${aws_instance.bastion[0].public_ip}/32"}}
        },
        {
            "Sid": "ec2SpecialPerms",
            "Effect": "Allow",
            "Action": [
                "ec2:ModifyInstanceAttribute",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*",
            "Condition": {"IpAddress": {"aws:SourceIp": "${aws_instance.bastion[0].public_ip}/32"}}
        },
        {
            "Sid": "ec2ModifyPerms",
            "Effect": "Allow",
            "Action": [
                "ec2:DetachVolume",
                "ec2:AttachVolume",
                "ec2:StartInstances",
                "ec2:CreateTags",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "ec2:RebootInstances"
            ],
            "Resource": [
                "${aws_instance.centos7[0].arn}",
                "${aws_instance.rhel8[0].arn}",
                "${aws_instance.fedora35[0].arn}",
                "${aws_instance.alma8[0].arn}",
                "${aws_instance.rocky8[0].arn}",
                "${aws_instance.debian10[0].arn}",
                "${aws_instance.debian11[0].arn}",
                "${aws_instance.ubuntu18_04[0].arn}",
                "${aws_instance.ubuntu20_04[0].arn}",
                "arn:aws:ec2:*::snapshot/*",
                "arn:aws:ec2:*:*:volume/*"
            ],
            "Condition": {"IpAddress": {"aws:SourceIp": "${aws_instance.bastion[0].public_ip}/32"}}
        }
    ]
}
EOF

}

resource "aws_iam_role" "role" {
  count              = var.make_instances ? 1 : 0
  name               = "bastion_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_route53_record" "bastion-dns-record" {
  count   = var.make_instances ? 1 : 0
  zone_id = data.terraform_remote_state.base.outputs.zone_id
  name    = "fogbastion.${data.terraform_remote_state.base.outputs.zone_name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_instance.bastion[0].public_dns]
}

resource "aws_security_group" "test_instances" {
  count       = var.make_instances ? 1 : 0
  name        = "${data.terraform_remote_state.base.outputs.vpc_name}_test_instances"
  description = "This security group is for ${var.project} test instances."
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion[0].private_ip}/32"]
    description = "Allow all traffic from the bastion instance."
  }
  tags = {
    Name = "${var.project}_test_instances"
  }
}



resource "aws_security_group" "bastion_instance" {
  name        = "${data.terraform_remote_state.base.outputs.vpc_name}_bastion_instance"
  description = "This security group is for ${var.project} bastion instance."
  vpc_id      = data.terraform_remote_state.base.outputs.vpc_id
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.base.outputs.vpc_cidr]
  }
  tags = {
    Name = "${var.project}_bastion"
  }
}
