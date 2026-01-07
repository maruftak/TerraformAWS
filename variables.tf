variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_b" {
  description = "CIDR for the second public subnet (required for ALB across AZs)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "eu-west-2a"
}

variable "availability_zone_b" {
  description = "Second availability zone for ALB/ASG spread"
  type        = string
  default     = "eu-west-2b"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS key pair name to attach to instances"
  type        = string
  default     = null
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = null
}

variable "ssh_admin_cidr" {
  description = "CIDR block allowed for SSH admin access (e.g., your office IP). If null, SSH is disabled."
  type        = string
  default     = null
}

variable "project_bucket_name" {
  description = "S3 bucket name for D-Transformation read/write policy (created in later tasks)."
  type        = string
  default     = "securecloud-coursework02-project-bucket"
}

variable "s3_force_destroy" {
  description = "Allow Terraform to delete all S3 objects on destroy (useful for demos)."
  type        = bool
  default     = true
}

variable "asg_min_size" {
  description = "Auto Scaling Group minimum size"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Auto Scaling Group desired capacity"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Auto Scaling Group maximum size"
  type        = number
  default     = 4
}
