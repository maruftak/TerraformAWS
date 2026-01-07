# Application Load Balancer, Target Group, Listener, Launch Configuration, and Auto Scaling Group

# Load Balancer
resource "aws_lb" "app_alb" {
  name               = "coursework-app-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_b.id]

  tags = merge(local.tags, { Name = "SalesTeam-app-alb" })
}

# Target Group for HTTP traffic
resource "aws_lb_target_group" "app_tg" {
  name     = "coursework-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200-399"
  }

  tags = merge(local.tags, { Name = "AppFleet-target-group" })
}

# Listener on port 80 forwarding to target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Launch Template for app instances (replaces deprecated Launch Configuration)
resource "aws_launch_template" "app_lt" {
  name_prefix   = "coursework-app-lt-"
  image_id      = coalesce(var.ami_id, data.aws_ami.ubuntu.id)
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.sales_ec2_profile.name
  }

  # Ensure instances have public IPs in public subnets and use the App Fleet SG
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_fleet_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -euo pipefail
              export DEBIAN_FRONTEND=noninteractive
              apt-get update -y
              apt-get install -y nginx curl
              INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
              echo "<h1>App instance: $INSTANCE_ID</h1>" > /var/www/html/index.nginx-debian.html
              systemctl enable nginx
              systemctl restart nginx
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                = "coursework-app-asg"
  vpc_zone_identifier = [aws_subnet.public.id, aws_subnet.public_b.id]
  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  health_check_type   = "ELB"
  health_check_grace_period = 300
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "AppFleet-ec2"
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = local.tags["Project"]
    propagate_at_launch = true
  }

  depends_on = [aws_lb_listener.http]
}

# Target tracking scaling policy based on average CPU utilization
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "coursework-app-asg-cpu-tt"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}
