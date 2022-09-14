

output "website_domain" {
  value = aws_s3_bucket_website_configuration.website_bucket_configuration.website_domain
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.website_bucket_configuration.website_endpoint 
}
