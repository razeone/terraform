variable "deploy_region" {
    description = "The region where the resources will be placed"
}

variable "server_port" {
    description = "The target port for the web server"
}

variable "load_balancer_port" {
    description = "The port that will serve traffic for the LB"
}

variable "min_size" {
    description = "Min size for ASG"
}

variable "max_size" {
    description = "Max size for ASG"
}

variable "environment" {
    description = "The environment tag"
}

