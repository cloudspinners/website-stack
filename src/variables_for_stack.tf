variable "website_name" {}
variable "instance_name" {}
variable "unique_id" {}

locals {
  bucket_name = "spinsite-${var.website_name}-${var.instance_name}-${var.unique_id}"
}
