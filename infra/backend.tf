
terraform {
  backend "s3" {
    bucket  = "eks-fargate-cluster-sandbox"
    key     = "eks-fargate-cluster-sandbox/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}
