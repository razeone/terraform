provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

locals {
  common_tags = {
    Component   = "awesome-app"
    Environment = "production"
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
}
