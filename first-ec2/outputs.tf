output "instance_id" {
  description = "The ID of the Instance"
  value       = "${coalescelist(aws_instance.example.id)}"
}

output "elastic_ip" {
    description = "The created Elastic IP"
    value       = "${aws_eip.ip}"
}