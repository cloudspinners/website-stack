resource "aws_s3_bucket" "website_bucket" {
  bucket = local.bucket_name
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${local.bucket_name}/*"]
    }
  ]
}
POLICY

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
