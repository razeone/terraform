variable "bucket_name" {
  description = "Bucket name"
  default     = "s3-website-test"
}

variable "domain_name" {
  description = "Parent domain name"
  default     = ""
}

variable "default_region" {
  description = "default region where the resources will be placed"
  default = "us-east-1"
}
