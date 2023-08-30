terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = "ap-south-1" 
}

terraform {
  backend "s3" {
    bucket         = "terraform-tf-state-files-setup"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
  }
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_subnet" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "example_security_group" {
  name_prefix = "Terraform-"
  vpc_id = aws_vpc.example_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "example_instance" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example_subnet.id

  tags = {
    Name = "Terraform-instances"
  }

  vpc_security_group_ids = [aws_security_group.example_security_group.id]
}

output "instance_ip" {
  value = aws_instance.example_instance.public_ip
}
