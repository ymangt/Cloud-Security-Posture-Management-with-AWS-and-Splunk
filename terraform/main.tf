# main.tf - Terraform configuration for CSPM Lab on AWS

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2" # Matches your instance's region
}

# Create an IAM Role for Prowler
resource "aws_iam_role" "prowler_role" {
  name = "ProwlerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AmazonEC2ReadOnlyAccess policy to the IAM Role
resource "aws_iam_role_policy_attachment" "prowler_policy_attachment" {
  role       = aws_iam_role.prowler_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Create an IAM Instance Profile for the EC2 instance
resource "aws_iam_instance_profile" "prowler_instance_profile" {
  name = "ProwlerInstanceProfile"
  role = aws_iam_role.prowler_role.name
}

# Create a Security Group
resource "aws_security_group" "lab_security_group" {
  name        = "launch-wizard-2"
  description = "Security group for CSPM lab EC2 instance"
  vpc_id      = "vpc-014202cc7fb735b11" # Your VPC ID

  # Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["99.243.40.25/32"] # Your launch IP, update if changed
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "launch-wizard-2"
  }
}

# Create an EC2 Instance
resource "aws_instance" "cloud_security_vm" {
  ami           = "ami-06d53ad9c5c4da96d" # Amazon Linux 2023 AMI in us-east-2
  instance_type = "t3.micro"
  key_name      = "cloud-security-key"

  iam_instance_profile = aws_iam_instance_profile.prowler_instance_profile.name
  vpc_security_group_ids = [aws_security_group.lab_security_group.id]
  subnet_id             = "subnet-0dc4c113d2d4da216" # Your subnet ID
  availability_zone     = "us-east-2c"

  tags = {
    Name = "Cloud-Security-VM"
  }
}

# Output the instance public IP for reference
output "instance_public_ip" {
  value = aws_instance.cloud_security_vm.public_ip
}
