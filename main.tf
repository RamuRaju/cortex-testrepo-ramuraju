provider "aws" {
  region = "us-east-1"
}

# 1. MISCONFIGURATION: S3 Bucket allows public read access
resource "aws_s3_bucket" "test_bucket" {
  bucket = "my-test-testing-bucket-12345"
}

resource "aws_s3_bucket_acl" "bad_acl" {
  bucket = aws_s3_bucket.test_bucket.id
  acl    = "public-read" 
}

# 2. MISCONFIGURATION: Security group allows SSH (Port 22) open to the entire internet
resource "aws_security_group" "bad_sg" {
  name        = "allow_ssh_everywhere"
  description = "Insecure security group for testing"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Critical vulnerability
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. MISCONFIGURATION: EBS Volume is not encrypted
resource "aws_instance" "test_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Placeholder Ubuntu AMI
  instance_type = "t2.micro"
  security_groups = [aws_security_group.bad_sg.name]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    encrypted             = false # Critical vulnerability (should be true)
  }

  tags = {
    Name = "Insecure-Test-Instance"
  }
}
