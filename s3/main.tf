# Terraform code to deploy a S3 bucket with website support

provider "aws" {
  region = "${var.default_region}"
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

resource "aws_s3_bucket_object" "index" {
  bucket  = "${aws_s3_bucket.website_test.id}"
  key     = "index.html"
  content_type = "text/html"
  content = <<EOF
  <h1>Deployed with Terraform</h1>
  EOF
}

resource "aws_s3_bucket_object" "error" {
  bucket  = "${aws_s3_bucket.website_test.id}"
  key     = "error.html"
  content = <<EOF
  <h1>Error</h1>
  EOF
}

