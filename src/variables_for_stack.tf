variable "website_name" {}
variable "instance_name" {}
variable "unique_id" {}

locals {
  website_hostname  = "${var.instance_name}.${var.website_name}"
  bucket_name       = "spinsite-${var.website_name}-${var.instance_name}-${var.unique_id}"
}
