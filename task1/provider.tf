terraform {
  required_version = ">= 0.13"
}

provider "aws" {
  version = ">= 3.11"
  region  = var.aws_region
}
