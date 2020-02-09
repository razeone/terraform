
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

variable "bucket_name" {
  description = "Bucket name"
  default     = "s3-website-test"
}

variable "domain_name" {
  description = "Parent domain name"
  default     = "raze.mx"
}


resource "aws_s3_bucket" "website_test" {
  bucket = "${var.bucket_name}.${var.domain_name}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }
}

data "aws_iam_policy_document" "bucket_policy_doc" {
  statement {
    sid       = "PublicReadGetObject"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}.${var.domain_name}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${aws_s3_bucket.website_test.id}"
  policy = "${data.aws_iam_policy_document.bucket_policy_doc.json}"
}

output "s3_website_url" {
  description = "Final URL"
  value       = "${aws_s3_bucket.website_test.website_endpoint}"
}
