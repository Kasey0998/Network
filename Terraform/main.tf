provider "aws" {
  region = "eu-west-1"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "kasey-aws-krishna"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID for eu-west-1"
  type        = string
  default     = "ami-09d95fab7fff3776c"
}

data "aws_key_pair" "kasey_aws_krishna" {
  key_name = var.key_name
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = data.aws_key_pair.kasey_aws_krishna.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = "Terraform-WebServer"
  }
}
