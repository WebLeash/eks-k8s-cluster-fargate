
# //////////////////////////////
#          Providers
# //////////////////////////////
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.16.0" # Specify the version you want to use
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "me-central-1"
}


