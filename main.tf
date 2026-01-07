locals {
  tags = {
    Project = "SecureCloudCoursework02"
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, { Name = "coursework-main-vpc" })
}

# Internet Gateway for public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "SalesTeam-igw" })
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = merge(local.tags, { Name = "SalesTeam-public-subnet" })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true
  tags = merge(local.tags, { Name = "SalesTeam-public-subnet-b" })
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone
  tags = merge(local.tags, { Name = "ComplianceTeam-private-subnet" })
}

# NAT Gateway (in public subnet)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(local.tags, { Name = "ComplianceTeam-nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags          = merge(local.tags, { Name = "ComplianceTeam-nat-gateway" })
  depends_on    = [aws_internet_gateway.igw]
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "SalesTeam-public-rt" })
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "ComplianceTeam-private-rt" })
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Minimal security group (egress only) — stricter SGs will be added in Q2
// default_egress SG removed in favor of team-specific SGs in security_groups.tf

# EC2 Instances
# SalesTeam instance in PUBLIC subnet with public IP via IGW
resource "aws_instance" "sales" {
  ami                         = coalesce(var.ami_id, data.aws_ami.ubuntu.id)
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.sales_team_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.sales_ec2_profile.name

  tags = merge(local.tags, {
    Name = "SalesTeam-ec2",
    Team = "SalesTeam"
  })
}

# ComplianceTeam instance in PRIVATE subnet — no public IP, internet via NAT
resource "aws_instance" "compliance" {
  ami                    = coalesce(var.ami_id, data.aws_ami.ubuntu.id)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  associate_public_ip_address = false
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.compliance_team_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.compliance_ec2_profile.name

  tags = merge(local.tags, {
    Name = "ComplianceTeam-ec2",
    Team = "ComplianceTeam"
  })
}

# IAM Groups for each team
resource "aws_iam_group" "devops" {
  name = "DevOpsTeam"
}

resource "aws_iam_group" "compliance" {
  name = "ComplianceTeam"
}

resource "aws_iam_group" "red" {
  name = "RedTeam"
}

resource "aws_iam_group" "dtrans" {
  name = "D-TransformationTeam"
}

resource "aws_iam_group" "sales" {
  name = "SalesTeam"
}

resource "aws_iam_group" "admin" {
  name = "AdministrativeTeam"
}

# AMI lookup (Ubuntu LTS)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
