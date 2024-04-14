provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

module "ec2_review" {
    source = "../modules/ec2module"
    instancetype = var.instancetype
    env_tag = var.env_tag
    ssh_key_file= var.ssh_key_file
    sg_name= var.sg_name

}

terraform {
  backend "s3" {
    bucket = "terraform-backend-abdoul"
    key = "./env_review.tfstate"
    region = "us-east-1"
    
  }
}