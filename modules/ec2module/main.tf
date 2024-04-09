
data "aws_ami" "my_aws_ami" {
  most_recent = true
  owners      = ["amazon"] # Canonical

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }


}

resource "aws_instance" "my_ec2_instance" {
  ami             = data.aws_ami.my_aws_ami.id
  instance_type   = var.instancetype
  key_name        = "centosEasyTraining"
  tags            = var.ec2_common_tag
  security_groups = ["${aws_security_group.ssh_http_https.name}"]

  connection {
    type        = "ssh"
    user = "ec2-user"
    private_key = file("./centosEasyTraining.pem")
    host        = self.public_ip
    timeout = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y nginx1.12",
      "sudo systemctl start nginx"
    ]
  }

}

resource "aws_security_group" "ssh_http_https" {
  name        = var.ec2_sg_name
  description = "Allow HTTPS and HTTP inbound traffic"

  ingress {
    description = "HTTP trafic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh trafic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS trafic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_eip" "my_eip" {
  instance = aws_instance.my_ec2_instance.id
  domain   = "vpc"
  provisioner "local-exec" {
    command = "echo PUBLIC IP: ${self.public_ip}  INSTANCE ID: ${aws_instance.my_ec2_instance.id}  ZONE AVAIBILITY:${aws_instance.my_ec2_instance.availability_zone}  >> infos_ec2.txt"
  }
}



