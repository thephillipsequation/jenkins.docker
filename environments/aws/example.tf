#Note must have a defined secrets .tf file with aws credentials. See https://www.terraform.io/intro/getting-started/variables.html for more info

#Define AWS parameters
provider "aws" {  
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

#Demo security group only. It is NOT recommended to use this. 
resource "aws_security_group" "allow_all" {
    name        = "allow_all"
    description = "Allow all inbound traffic"

    ingress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    } 

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]  
    }

    tags {
      Name = "allow_all"
    }
}

#EC2 Resource Definitions
resource "aws_instance" "jenkins_master" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  associate_public_ip_address = true

  tags {
      name = "JenkinsMaster"
  }
}