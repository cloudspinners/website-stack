terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  # assume_role {
  #   role_arn     = var.assume_role_arn
  #   session_name = "session-${var.aws_region}-${var.aws_profile}"
  # }
}
