terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "twitter-clone-terraform-state-gil-gerassi"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}
