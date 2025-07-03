provider "aws" {
  region = "eu-west-1"
}

# Security group allowing SSH (22) and HTTP (80)
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

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

  tags = {
    Name = "allow_ssh_http"
  }
}

# Get default VPC for security group
data "aws_vpc" "default" {
  default = true
}

# EC2 instance using provided AMI
resource "aws_instance" "free_tier_instance" {
  ami                    = "ami-0803576f0c0169402"
  instance_type          = "t2.micro"
  key_name               = "kasey-aws-krishna"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "FreeTierAmazonLinux"
  }
}
