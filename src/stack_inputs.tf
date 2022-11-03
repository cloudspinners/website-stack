variable "website_name" {}
variable "instance_name" {}

locals {
  website_hostname  = "${var.instance_name}.${var.website_name}"
}
