resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# Private subnet only: nothing here is meant to be reachable from the internet.
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.name_prefix}-private-a"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app"
  description = "App server: admin SSH from the approved network only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-app"
  }
}

# Administrative access is only allowed from the approved Irish admin network.
resource "aws_vpc_security_group_ingress_rule" "admin_ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH from the approved Irish admin network"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.admin_ssh_cidr
}

# Only created by the non-compliant scenario: every port open to the internet.
resource "aws_vpc_security_group_ingress_rule" "debug_all" {
  count = var.open_all_ports ? 1 : 0

  security_group_id = aws_security_group.app.id
  description       = "Debug rule: all traffic from anywhere"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "https_out" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS out for package updates"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}
