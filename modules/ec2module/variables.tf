
variable "instancetype" {
 type = string
 description = "aws instance type"
 default= "t2.nano"
 }

 variable "ec2_sg_name" {
 type = string
 description = "ec2 security group name"
 default= "ec2-dev-sg"
 }

 variable "ec2_common_tag" {
   type = map
   description = "instance tag"
   default = {
    Name= "devops-Name"
   }

 }





