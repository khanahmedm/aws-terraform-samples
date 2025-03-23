provider "aws" {
  region = "us-east-1"  # Change this to your preferred AWS region
}

# Create an SSH key pair
resource "tls_private_key" "terraform_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-key"
  public_key = tls_private_key.terraform_key.public_key_openssh
}

# Store the private key locally
resource "local_file" "private_key" {
  filename = "terraform-key.pem"
  content  = tls_private_key.terraform_key.private_key_pem
}

# Security Group for EC2 instances
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this for security (e.g., allow only your IP)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch two EC2 instances
resource "aws_instance" "ec2_instances" {
  count         = 2  # Number of instances
  ami           = "ami-085925f297f89fce1"  # Amazon Linux 2 AMI (Update based on your region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "Terraform-Instance-${count.index + 1}"
  }
}

# Output the public IPs of the instances
output "public_ips" {
  value = aws_instance.ec2_instances[*].public_ip
}

# Output the SSH private key location
output "private_key_path" {
  value     = local_file.private_key.filename
  sensitive = true  # Hides it from Terraform logs
}