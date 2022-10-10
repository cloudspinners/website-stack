
data "aws_route53_zone" "zone" {
  name = "${var.website_name}."
}

resource "aws_route53_record" "base" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.website_hostname
  type    = "A"

  alias {
    name                    = aws_s3_bucket_website_configuration.website_bucket_configuration.website_domain
    zone_id                 = aws_s3_bucket.website_bucket.hosted_zone_id
    evaluate_target_health  = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "www.${local.website_hostname}"
  type    = "CNAME"
  ttl     = "5"

  records = [local.website_hostname]
}
