##Provider details
provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAZGIP2ZOBDMZAVWHF"
  secret_key = "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"
}
#Provider detail end here

##Creating AWS EC2 instance deploye apache2
resource "aws_instance" "web" {
  ami             = "ami-03d3eec31be6ef6f9"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.TrootSG.name}"]
  key_name        = "Troot-key"
  tags = {
    Name = "Demo Web Server"
  }
  user_data = <<-EOF
        #! /bin/bash
        sudo apt-get install apache2 -y
        sudo systemctl start apache2
        sudo systemctl enable apache2
        sudo echo "Hi Rahul, This is Terraform testing page!!" > /var/www/html/index.html
    
        #! /bin/bash
        sudo chmod 666 /etc/ssh/sshd_config
        sudo echo "Port 44332" >> /etc/ssh/sshd_config
        sudo systemctl restart sshd.service
    EOF
}
#AWS EC2 instance creted here

##Elastic_ip create and associate it
resource "aws_eip" "lb" {
  instance = aws_instance.web.id
  vpc      = true
}
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.lb.id
}
#Elastic ip end here

## Create Security group
resource "aws_security_group" "TrootSG" {
  name        = "TrootSG"
  description = "Allow ssh and http/https ports"

  ingress {
    description = "Allow ssh"
    from_port   = 22
    to_port     = 44332
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Security Groups ends here
