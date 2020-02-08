provider "aws" {
  profile = "default"
  region  = "${var.region}"
}

# Using locals

locals {
  common_tags = {
    Component   = "awesome-app"
    Environment = "production"
    Terraform   = "true"
  }
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "awesome-app-server",
      "Role", "server"
    )
  )}"

 # Provisioners
  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  }
}

# Example Elastic IP
resource "aws_eip" "ip" {
    vpc = true
    instance = "${aws_instance.example.id}"
}
