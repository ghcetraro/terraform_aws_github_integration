#
terraform {
  required_version = "= 1.12.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.84.0"
    }
  }
}
#
provider "aws" {
  region  = var.region
  profile = local.aws_profile
  default_tags {
    tags = local.tags
  }
}