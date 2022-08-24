
resource "aws_s3_bucket" "website_bucket" {
  bucket = local.bucket_name
  acl    = "public-read"
  timeouts {
    create = "30s"
    read   = "30s"
    update = "30s"
    delete = "30s"
  }
}

resource "aws_s3_bucket_website_configuration" "website_bucket_configuration" {
  bucket = aws_s3_bucket.website_bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}


# resource "aws_ssm_parameter" "spin_tools_test" {
#   name  = "spin_tools_test_parameter"
#   type  = "String"
#   value = local.bucket_name
# }
