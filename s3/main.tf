
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "website_test" {
  bucket = "s3-website-test.raze.mx"
  acl    = "public-read"
  # policy = "${file("policy.json")}"

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

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${aws_s3_bucket.website_test.id}"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
	"Sid":"PublicReadGetObject",
        "Effect":"Allow",
	  "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::s3-website-test.raze.mx/*"
      ]
    }
  ]
}
POLICY
}

output "s3_website_url" {
  description = "Final URL"
  value       = "${aws_s3_bucket.website_test.website_endpoint}"
}