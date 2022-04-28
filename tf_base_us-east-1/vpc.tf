resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "${var.project}-public-subnet-a"
  }
}


resource "aws_vpc_dhcp_options" "option_set" {
  domain_name_servers = ["AmazonProvidedDNS"]
  ntp_servers         = ["169.254.169.123"] # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html
}

resource "aws_vpc_dhcp_options_association" "option_set_association" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.option_set.id
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name = "${var.project}-public-routes"
  }
}

resource "aws_route_table_association" "public-route-table-association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-internet-gateway"
  }
}

resource "aws_security_group" "ssh_from_anywhere" {
  name        = "ssh_from_anywhere"
  description = "Allow all inbound SSH - use cautiously."
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_ssh_from_anywhere"
  }
}

resource "aws_security_group" "internet_connectivity" {
  name        = "internet_connectivity"
  description = "This allows dns, http, and https."
  vpc_id      = aws_vpc.vpc.id
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    description = "TCP DNS to VPC"
  }
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    description = "UDP DNS to VPC"
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http to everywhere"
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "https to everywhere"
  }


  tags = {
    Name = "${var.project}-ssh"
  }
}



output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_a" {
  value = aws_subnet.public_subnet_a.id
}

output "sg_ssh_from_anywhere" {
  value = aws_security_group.ssh_from_anywhere.id
}

output "sg_internet_connectivity" {
  value = aws_security_group.internet_connectivity.id
}

