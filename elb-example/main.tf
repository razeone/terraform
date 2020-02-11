
provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The target port for the web server"
  default = 8080
}

resource "aws_launch_configuration" "web_launch_conig" {
  image_id = "ami-40d2"
}


resource "aws_security_group" "allow_http" {
  name        = "public_http"
  description = "Allows incoming public HTTP traffic"

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

resource "aws_security_group" "allow_http_from_lb" {
  name        = "http_from_lb"
  description = "Allows incoming public HTTP traffic"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["${aws_security_group.allow_http.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}