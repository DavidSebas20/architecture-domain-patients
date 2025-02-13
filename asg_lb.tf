# Crear un grupo de seguridad para la instancia
resource "aws_security_group" "patient_sg" {
  name_prefix = "domain-patient"
  vpc_id      = "vpc-07d9bd0b898725449"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6000
    to_port     = 6003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
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
}

# Crear Launch Template para ms-createpatient y ms-readpatients
resource "aws_launch_template" "patient_lt_1" {
  name_prefix   = "domain-patient-lt-1"
  image_id      = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.patient_sg.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "domain-patient-instance-1"
    }
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              exec > >(tee /dev/tty) 2>&1
              set -x
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io
              curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              # Crear archivo docker-compose.yml
              cat <<EOL > /home/ubuntu/docker-compose.yml
              version: '3'
              services:
                ms-createpatient:
                  image: dssanguano/ms-createpatient:${var.BRANCH_NAME}
                  ports:
                    - "${var.PORT_CREATE_PATIENT}:${var.PORT_CREATE_PATIENT}"
                  environment:
                    DB_URL: ${var.DB_URL}
                    DB_USERNAME: ${var.DB_USERNAME}
                    DB_PASSWORD: ${var.DB_PASSWORD}
                    HASH_SERVICE_URL: ${var.HASH_SERVICE_URL}
                    PORT_CREATE_PATIENT: ${var.PORT_CREATE_PATIENT}
                ms-readpatient:
                  image: dssanguano/ms-readpatients:${var.BRANCH_NAME}
                  ports:
                    - "${var.PORT_READ_PATIENT}:${var.PORT_READ_PATIENT}"
                  environment:
                    DB_URL: ${var.DB_URL}
                    DB_USERNAME: ${var.DB_USERNAME}
                    DB_PASSWORD: ${var.DB_PASSWORD}
                    PORT_READ_PATIENT: ${var.PORT_READ_PATIENT}
              EOL
              # Arrancar Docker y Docker Compose
              systemctl start docker
              systemctl enable docker
              cd /home/ubuntu
              docker-compose -f docker-compose.yml up -d
              docker ps
              EOF
            )
}

# Crear Launch Template para ms-updatepatient y ms-deletepatient
resource "aws_launch_template" "patient_lt_2" {
  name_prefix   = "domain-patient-lt-2"
  image_id      = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.patient_sg.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "domain-patient-instance-2"
    }
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              exec > >(tee /dev/tty) 2>&1
              set -x
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io
              curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              # Crear archivo docker-compose.yml
              cat <<EOL > /home/ubuntu/docker-compose.yml
              version: '3'
              services:
                ms-updatepatient:
                  image: dssanguano/ms-updatepatients:${var.BRANCH_NAME}
                  ports:
                    - "${var.PORT_UPDATE_PATIENT}:${var.PORT_UPDATE_PATIENT}"
                  environment:
                    DB_URL: ${var.DB_URL}
                    DB_USERNAME: ${var.DB_USERNAME}
                    DB_PASSWORD: ${var.DB_PASSWORD}
                    HASH_SERVICE_URL: ${var.HASH_SERVICE_URL}
                    VERIFY_SERVICE_URL: ${var.VERIFY_SERVICE_URL}
                    PORT_UPDATE_PATIENT: ${var.PORT_UPDATE_PATIENT}
                ms-deletepatient:
                  image: dssanguano/ms-deletepatients:${var.BRANCH_NAME}
                  ports:
                    - "${var.PORT_DELETE_PATIENT}:${var.PORT_DELETE_PATIENT}"
                  environment:
                    DB_URL: ${var.DB_URL}
                    DB_USERNAME: ${var.DB_USERNAME}
                    DB_PASSWORD: ${var.DB_PASSWORD}
                    VERIFY_SERVICE_URL: ${var.VERIFY_SERVICE_URL}
                    PORT_DELETE_PATIENT: ${var.PORT_DELETE_PATIENT}
              EOL
              # Arrancar Docker y Docker Compose
              systemctl start docker
              systemctl enable docker
              cd /home/ubuntu
              docker-compose -f docker-compose.yml up -d
              docker ps
              EOF
            )
}

# Crear Load Balancer
resource "aws_lb" "patient_alb" {
  name               = "patient-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.patient_sg.id]
  subnets            = ["subnet-041cbc7f89b590956", "subnet-03a0b49bf24b5e7f9"]
}

# Crear Target Groups
resource "aws_lb_target_group" "patient_tg_6000" {
  name     = "patient-tg-6000"
  port     = 6000
  protocol = "HTTP"
  vpc_id   = "vpc-07d9bd0b898725449"
  health_check {
    path                = "/create-patient/patients/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}
resource "aws_lb_target_group" "patient_tg_6001" {
  name     = "patient-tg-6001"
  port     = 6001
  protocol = "HTTP"
  vpc_id   = "vpc-07d9bd0b898725449"
  health_check {
    path                = "/read-patient/patients/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}
resource "aws_lb_target_group" "patient_tg_6002" {
  name     = "patient-tg-6002"
  port     = 6002
  protocol = "HTTP"
  vpc_id   = "vpc-07d9bd0b898725449"
  health_check {
    path                = "/update-patient/patients/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}
resource "aws_lb_target_group" "patient_tg_6003" {
  name     = "patient-tg-6003"
  port     = 6003
  protocol = "HTTP"
  vpc_id   = "vpc-07d9bd0b898725449"
  health_check {
    path                = "/delete-patient/patients/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Configurar Listener y Reglas
resource "aws_lb_listener" "patient_listener" {
  load_balancer_arn = aws_lb.patient_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.patient_tg_6000.arn
  }
}
resource "aws_lb_listener_rule" "patient_rule_6000" {
  listener_arn = aws_lb_listener.patient_listener.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["/create-patient*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.patient_tg_6000.arn
  }
}
resource "aws_lb_listener_rule" "patient_rule_6001" {
  listener_arn = aws_lb_listener.patient_listener.arn
  priority     = 101
  condition {
    path_pattern {
      values = ["/read-patient*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.patient_tg_6001.arn
  }
}
resource "aws_lb_listener_rule" "patient_rule_6002" {
  listener_arn = aws_lb_listener.patient_listener.arn
  priority     = 102
  condition {
    path_pattern {
      values = ["/update-patient*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.patient_tg_6002.arn
  }
}
resource "aws_lb_listener_rule" "patient_rule_6003" {
  listener_arn = aws_lb_listener.patient_listener.arn
  priority     = 103
  condition {
    path_pattern {
      values = ["/delete-patient*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.patient_tg_6003.arn
  }
}

# Configurar Auto Scaling Group para ms-createpatient y ms-readpatients
resource "aws_autoscaling_group" "patient_asg_1" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["subnet-041cbc7f89b590956", "subnet-03a0b49bf24b5e7f9"]
  target_group_arns    = [
    aws_lb_target_group.patient_tg_6000.arn,
    aws_lb_target_group.patient_tg_6001.arn
  ]
  launch_template {
    id      = aws_launch_template.patient_lt_1.id
    version = "$Latest"
  }
}

# Configurar Auto Scaling Group para ms-updatepatient y ms-deletepatient
resource "aws_autoscaling_group" "patient_asg_2" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["subnet-041cbc7f89b590956", "subnet-03a0b49bf24b5e7f9"]
  target_group_arns    = [
    aws_lb_target_group.patient_tg_6002.arn,
    aws_lb_target_group.patient_tg_6003.arn
  ]
  launch_template {
    id      = aws_launch_template.patient_lt_2.id
    version = "$Latest"
  }
}

# Add CPU Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high_alarm" {
  alarm_name          = "HighCPUUsageAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm triggers when the average CPU usage exceeds 80% for 2 consecutive periods of 2 minutes."
  alarm_actions       = [aws_sns_topic.cpu_alarm_topic.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.patient_asg_1.name
  }
}

# Crear SNS Topic
resource "aws_sns_topic" "cpu_alarm_topic" {
  name = "HighCPUAlarmTopic"
}

# Suscribe Email to SNS Topic
resource "aws_sns_topic_subscription" "cpu_alarm_email_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_topic.arn
  protocol  = "email"
  endpoint  = "dssanguano@uce.edu.ec"
}