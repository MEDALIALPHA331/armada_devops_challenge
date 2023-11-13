terraform {

  # backend "s3" {
  #   bucket         = "tf-state-backend"
  #   key            = "tf-infra/terraform.tfstate"
  #   region         = "eu-west-3"
  #   dynamodb_table = "terraform-state-locking"
  #   encrypt        = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6.3"
}

provider "aws" {
  region = "eu-west-3"
}


# module "tf-state" {
#   source      = "./modules/tfstate"
#   bucket_name = "tf-state-backend"
# }


module "vpc-infra" {
  source = "./modules/vpc"


  vpc_cidr             = local.vpc_cidr
  availability_zones   = local.availability_zones
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
}