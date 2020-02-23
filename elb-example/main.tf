
provider "aws" {
  region = "${var.deploy_region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# I'll be using default VPC and subnets for this example
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.deploy_region}a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "${var.deploy_region}b"

  tags = {
    Name = "Default subnet for us-east-1b"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = "${var.server_port}"
  protocol = "HTTP"
  vpc_id   = "${aws_default_vpc.default.id}"
}

resource "aws_security_group" "allow_http" {
  name        = "public_http"
  description = "Allows incoming public HTTP traffic"

  ingress {
    from_port   = "${var.load_balancer_port}"
    to_port     = "${var.load_balancer_port}"
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

resource "aws_launch_configuration" "web_launch_config" {
  name            = "web_config"
  image_id        = "${data.aws_ami.ubuntu.id}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.allow_http_from_lb.id}"]

  user_data = <<-EOF
		#! /bin/bash
    sudo apt-get update
		sudo apt-get install -y apache2
		sudo systemctl start apache2
		sudo systemctl enable apache2
		echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	EOF
}


resource "aws_autoscaling_group" "asg_test" {
  name                 = "terraform-asg-test"
  launch_configuration = "${aws_launch_configuration.web_launch_config.name}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  availability_zones   = ["${var.deploy_region}a"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "allow_http_from_lb" {
  name        = "http_from_lb"
  description = "Allows incoming public HTTP traffic"

  ingress {
    from_port       = "${var.server_port}"
    to_port         = "${var.server_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.allow_http.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.allow_http.id}"]
  subnets            = ["${aws_default_subnet.default_az1.id}", "${aws_default_subnet.default_az2.id}"]

  enable_deletion_protection = true

  #access_logs {
  #  bucket  = "${aws_s3_bucket.lb_logs.bucket}"
  #  prefix  = "test-lb"
  #  enabled = true
  #}

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.asg_test.id}"
  alb_target_group_arn   = "${aws_lb_target_group.web_tg.arn}"
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = "${aws_lb.test.arn}"
  port              = "${var.load_balancer_port}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web_tg.arn}"
  }
}