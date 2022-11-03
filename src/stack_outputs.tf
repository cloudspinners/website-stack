
output "website_hostname" {
  value = aws_route53_record.base.fqdn
}

output "website_bucket_name" {
  value = aws_s3_bucket.website_bucket.bucket
}

output "website_bucket_endpoint" {
  value = aws_s3_bucket_website_configuration.website_bucket_configuration.website_endpoint 
}
