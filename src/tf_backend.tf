terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = var.terraform_cloud_organization
    workspaces {
      name = "spin-${var.site_name}-s3_bucket-${var.instance_name}"
    }
  }
}
