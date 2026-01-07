output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the created VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Public subnet ID"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "Private subnet ID"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
  description = "NAT Gateway ID"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "Internet Gateway ID"
}

output "sales_instance_id" {
  value       = aws_instance.sales.id
  description = "SalesTeam EC2 instance ID"
}

output "compliance_instance_id" {
  value       = aws_instance.compliance.id
  description = "ComplianceTeam EC2 instance ID"
}

output "sales_security_group_id" {
  value       = aws_security_group.sales_team_sg.id
  description = "SalesTeam security group ID"
}

output "compliance_security_group_id" {
  value       = aws_security_group.compliance_team_sg.id
  description = "ComplianceTeam security group ID"
}

output "sales_instance_profile" {
  value       = aws_iam_instance_profile.sales_ec2_profile.name
  description = "SalesTeam EC2 instance profile name"
}

output "compliance_instance_profile" {
  value       = aws_iam_instance_profile.compliance_ec2_profile.name
  description = "ComplianceTeam EC2 instance profile name"
}

output "alb_dns_name" {
  value       = aws_lb.app_alb.dns_name
  description = "Public DNS name of the Application Load Balancer"
}

output "asg_name" {
  value       = aws_autoscaling_group.app_asg.name
  description = "Name of the application Auto Scaling Group"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.project.bucket
  description = "Name of the project S3 bucket"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.project.arn
  description = "ARN of the project S3 bucket"
}

output "s3_kms_key_arn" {
  value       = aws_kms_key.project.arn
  description = "ARN of the KMS key used to encrypt the S3 bucket"
}

# Team-friendly outputs for demo clarity
output "sales_public_subnet_id" {
  value       = aws_subnet.public.id
  description = "SalesTeam public subnet ID"
}

output "compliance_private_subnet_id" {
  value       = aws_subnet.private.id
  description = "ComplianceTeam private subnet ID"
}

output "sales_instance_public_ip" {
  value       = aws_instance.sales.public_ip
  description = "Public IP address of SalesTeam EC2 (should exist)"
}

output "compliance_instance_private_ip" {
  value       = aws_instance.compliance.private_ip
  description = "Private IP address of ComplianceTeam EC2 (no public IP)"
}
