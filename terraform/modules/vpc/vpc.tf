resource "aws_vpc" "daliVPC" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "daliVPC"
  }
}

resource "aws_internet_gateway" "daliIGW" {
  vpc_id = aws_vpc.daliVPC.id

  tags = {
    Name = "daliIGW"
  }
}

resource "aws_eip" "ccNatGatewayEIP1" {
  tags = {
    Name = "ccNatGatewayEIP1"
  }
}

resource "aws_nat_gateway" "ccNatGateway1" {
  allocation_id = aws_eip.ccNatGatewayEIP1.id
  subnet_id     = aws_subnet.ccPublicSubnet1.id
  tags = {
    Name = "ccNatGateway1"
  }
}


resource "aws_subnet" "ccPublicSubnet1" {
  vpc_id            = aws_vpc.daliVPC.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "ccPublicSubnet1"
  }
}

resource "aws_eip" "ccNatGatewayEIP2" {
  tags = {
    Name = "ccNatGatewayEIP2"
  }
}
resource "aws_nat_gateway" "ccNatGateway2" {
  allocation_id = aws_eip.ccNatGatewayEIP2.id
  subnet_id     = aws_subnet.ccPublicSubnet1.id
  tags = {
    Name = "ccNatGateway2"
  }
}

resource "aws_subnet" "ccPublicSubnet2" {
  vpc_id            = aws_vpc.daliVPC.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "ccPublicSubnet2"
  }
}

resource "aws_subnet" "ccPrivateSubnet1" {
  vpc_id            = aws_vpc.daliVPC.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "ccPrivateSubnet1"
  }
}
resource "aws_subnet" "ccPrivateSubnet2" {
  vpc_id            = aws_vpc.daliVPC.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "ccPrivateSubnet2"
  }
}

resource "aws_route_table" "ccPublicRT" {
  vpc_id = aws_vpc.daliVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.daliIGW.id
  }
  tags = {
    Name = "ccPublicRT"
  }
}
resource "aws_route_table" "ccPrivateRT1" {
  vpc_id = aws_vpc.daliVPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ccNatGateway1.id
  }
  tags = {
    Name = "ccPrivateRT1"
  }
}

resource "aws_route_table" "ccPrivateRT2" {
  vpc_id = aws_vpc.daliVPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ccNatGateway2.id
  }
  tags = {
    Name = "ccPrivateRT2"
  }
}

resource "aws_route_table_association" "ccPublicRTassociation1" {
  subnet_id      = aws_subnet.ccPublicSubnet1.id
  route_table_id = aws_route_table.ccPublicRT.id
}
resource "aws_route_table_association" "ccPublicRTassociation2" {
  subnet_id      = aws_subnet.ccPublicSubnet2.id
  route_table_id = aws_route_table.ccPublicRT.id
}
resource "aws_route_table_association" "ccPrivateRTassociation1" {
  subnet_id      = aws_subnet.ccPrivateSubnet1.id
  route_table_id = aws_route_table.ccPrivateRT1.id
}
resource "aws_route_table_association" "ccPrivateRTassociation2" {
  subnet_id      = aws_subnet.ccPrivateSubnet2.id
  route_table_id = aws_route_table.ccPrivateRT2.id
}


# Define a security group that allows inbound HTTP and SSH traffic from a specific IP address
resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow inbound HTTP and SSH traffic"
  vpc_id      = aws_vpc.daliVPC.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # should replace with specific IP address for security
    description = "HTTP"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # same
    description = "SSH"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # same
    description = "HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

}


resource "aws_launch_template" "main" {
  name_prefix   = "armadav2"
  image_id      = "ami-00983e8a26e4c9bd9" #  Debian AMI
  instance_type = "t2.micro"
  key_name      = "ssh_private_key"

  user_data = base64encode(<<-EOF
          #!/bin/bash

          # Update packages and install prerequisites
          sudo apt update
          sudo apt install -y git curl

          # Install Node.js v20.9.0 LTS
          curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
          sudo apt-get install -y nodejs

          # Install NPM
          npm install -g npm

          # Install pnpm and pm2 globally 
          npm install -g pnpm pm2

          # Create app directory and clone repo
          mkdir -p /home/ubuntu/app
          cd /home/ubuntu/app
          git clone https://github.com/MEDALIALPHA331/armada_devops_challenge .

          # Install dependencies 
          pnpm install

          #Build the app
          pnpm build
        
          # Start app
          pm2 start dist/src/server.js --name "armada_api"

          # Logs
          pm2 logs
          EOF
  )


  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_http_ssh.id]
  }
}



# resource "aws_instance" "foo" {
#   subnet_id = aws_subnet.ccPublicSubnet1.id
#   launch_template {
#     id = aws_launch_template.main.id
#   }
# }


# Define the load balancer
resource "aws_lb" "main" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_ssh.id]
  subnets            = [aws_subnet.ccPrivateSubnet1.id, aws_subnet.ccPublicSubnet2.id]
}

# Define the target group
resource "aws_lb_target_group" "main" {
  name = "tgapi"
  port = 8000
  # port     = 80     # FOR TEST WITH NGINX
  protocol = "HTTP"
  vpc_id   = aws_vpc.daliVPC.id
}

# Define the listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# resource "aws_lb_target_group_attachment" "alb_asg_attachment" {
#  target_group_arn = aws_lb_target_group.main.arn
#  target_id       = aws_autoscaling_group.main.id
#  port            = 8000
# }



resource "aws_autoscaling_group" "main" {
  desired_capacity    = 2
  max_size            = 4 # THIS IS BASED ON NEEDS OFC
  min_size            = 1
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.ccPrivateSubnet1.id, aws_subnet.ccPublicSubnet2.id]
  # vpc_zone_identifier  = [aws_subnet.ccPrivateSubnet1.id, aws_subnet.ccPublicSubnet2.id, aws_subnet.ccPublicSubnet1.id, aws_subnet.ccPrivateSubnet2.id]

  target_group_arns = [aws_lb_target_group.main.arn]


  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "main-asg"
    propagate_at_launch = true
  }
}


# Monitoring and alerts
# SNS topic for sending email notifications
resource "aws_sns_topic" "cpu_high" {
  name = "cpu-high"
}

# email subscription for the SNS topic
resource "aws_sns_topic_subscription" "cpu_high" {
  topic_arn = aws_sns_topic.cpu_high.arn
  protocol  = "email"
  endpoint  = "medali.khaled.swe@gmail.com" # my email address
}

# CloudWatch metric alarm: CPU utilizations 70%
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric checks for high CPU utilization"
  alarm_actions       = [aws_sns_topic.cpu_high.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}