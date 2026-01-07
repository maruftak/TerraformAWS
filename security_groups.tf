# Team-specific security groups with strict rules

# SalesTeam: public-facing web; optional SSH from admin CIDR; egress restricted to HTTP/HTTPS
resource "aws_security_group" "sales_team_sg" {
  name        = "SalesTeam-sg"
  description = "SalesTeam security group: allow HTTP/HTTPS inbound, optional SSH; restrict egress"
  vpc_id      = aws_vpc.main.id

  # Inbound: HTTP
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound: HTTPS
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optional Inbound: SSH from admin CIDR
  dynamic "ingress" {
    for_each = var.ssh_admin_cidr == null ? [] : [var.ssh_admin_cidr]
    content {
      description = "SSH from admin CIDR"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Egress: restrict to HTTP/HTTPS only
  egress {
    description = "Egress HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Egress HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "SalesTeam-sg" })
}

# ComplianceTeam: no inbound; egress minimal (HTTPS only)
resource "aws_security_group" "compliance_team_sg" {
  name        = "ComplianceTeam-sg"
  description = "ComplianceTeam security group: block inbound; minimal egress"
  vpc_id      = aws_vpc.main.id

  # No ingress rules -> implicit deny

  # Egress: HTTPS only
  egress {
    description = "Egress HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "ComplianceTeam-sg" })
}

# DevOpsTeam: SSH from admin CIDR; egress HTTPS
resource "aws_security_group" "devops_team_sg" {
  name        = "DevOpsTeam-sg"
  description = "DevOps security group: admin SSH; minimal egress"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ssh_admin_cidr == null ? [] : [var.ssh_admin_cidr]
    content {
      description = "SSH from admin CIDR"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Egress HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "DevOpsTeam-sg" })
}

# D-TransformationTeam: admin SSH; egress HTTPS
resource "aws_security_group" "dtrans_team_sg" {
  name        = "D-TransformationTeam-sg"
  description = "D-Transformation security group: admin SSH; minimal egress"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ssh_admin_cidr == null ? [] : [var.ssh_admin_cidr]
    content {
      description = "SSH from admin CIDR"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Egress HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "D-TransformationTeam-sg" })
}

# RedTeam: zero trust by default; no ingress; no egress (can be toggled later)
resource "aws_security_group" "red_team_sg" {
  name        = "RedTeam-sg"
  description = "RedTeam security group: no inbound/egress by default"
  vpc_id      = aws_vpc.main.id

  tags = merge(local.tags, { Name = "RedTeam-sg" })
}

# AdministrativeTeam: admin SSH; egress HTTPS
resource "aws_security_group" "admin_team_sg" {
  name        = "AdministrativeTeam-sg"
  description = "Admin security group: admin SSH; minimal egress"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ssh_admin_cidr == null ? [] : [var.ssh_admin_cidr]
    content {
      description = "SSH from admin CIDR"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Egress HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "AdministrativeTeam-sg" })
}

  # Load Balancer SG: allow HTTP from internet, egress to app fleet
  resource "aws_security_group" "alb_sg" {
    name        = "ALB-sg"
    description = "ALB security group: HTTP from internet"
    vpc_id      = aws_vpc.main.id

    ingress {
      description = "HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(local.tags, { Name = "ALB-sg" })
  }

  # App Fleet SG: allow HTTP only from ALB SG; egress HTTP/HTTPS
  resource "aws_security_group" "app_fleet_sg" {
    name        = "AppFleet-sg"
    description = "App fleet security group: HTTP from ALB only; egress HTTP/HTTPS"
    vpc_id      = aws_vpc.main.id

    ingress {
      description                = "HTTP from ALB"
      from_port                  = 80
      to_port                    = 80
      protocol                   = "tcp"
      security_groups            = [aws_security_group.alb_sg.id]
    }

    egress {
      description = "Egress HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      description = "Egress HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(local.tags, { Name = "AppFleet-sg" })
  }
