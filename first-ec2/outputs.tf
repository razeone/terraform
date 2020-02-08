output "instance_id" {
  description = "The ID of the Instance"
  value       = "${coalescelist(aws_instance.example.id)}"
}