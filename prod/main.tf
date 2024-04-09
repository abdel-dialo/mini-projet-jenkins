provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

module "ec2_prod" {
    source = "../modules/ec2module"
    instancetype = "t2.micro"
     ec2_common_tag = {
    Name = "ec2-prod-abdoul"
    }
    ec2_sg_name="ec2-prod-sg"
  
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-abdoul"
    key = "./abdoul.tfstate"
    region = "us-east-1"
    
  }
}