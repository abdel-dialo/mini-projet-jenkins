provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

module "ec2_dev" {
    source = "../modules/ec2module"
    instancetype = "t2.nano"
     ec2_common_tag = {
    Name = "ec2-dev-abdoul"
}

    
  
}
terraform {
  backend "s3" {
    bucket = "terraform-backend-abdoul"
    key = "./abdoul.tfstate"
    region = "us-east-1"
    
  }
}