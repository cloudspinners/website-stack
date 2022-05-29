terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = var.terraform_cloud_organization
    workspaces {
      name = "spin-${var.instance_id}-s3_bucket-${var.bucket_name}"
    }
  }
}
