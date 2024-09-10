# One VPC with two subnets (public and private).
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Create a VPC
resource "aws_vpc" "gravity.vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "gravity_vpc"
  }
}

# Create a Public Subnet
resource "aws_subnet" "pub_subnet" {
  vpc_id                  = "aws_vpc.gravity.vpc.id"
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"  
  map_public_ip_on_launch = true
  tags = {
    Name = "pub_subnet"
  }
}

# Create a Private Subnet
resource "aws_subnet" "Pri_subnet" {
  vpc_id            = "aws_vpc.gravity.vpc.id"
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-1b"  
  tags = {
    Name = "Pri_subnet"
  }
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "gravity_vpc_igw" {
  vpc_id = "aws_vpc.gravity.vpc.id"
  tags = {
    Name = "gravity_vpc_igw"
  }
}

# Route Table for the Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = "aws_vpc.gravity.vpc.id"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "aws_internet_gateway.gravity_vpc_igw.id"
  }
  tags = {
    Name = "public_route_table"
  }
}

# Associate the Route Table with the Public Subnet
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = "aws_subnet.pub_subnet.id"
  route_table_id = "aws_route_table.public_route_table.id"
}
# Firewall rules that allow HTTP/HTTPS traffic to the instance.

resource "aws_security_group" "gravity-SG" {
  vpc_id = "aws_vpc.gravity.vpc.id"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
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
  tags = {
    Name = "gravity-SG"
  }
}

# A Compute Engine instance in the public subnet with a web server installed (e.g., Nginx or Apache).

resource "aws_instance" "web_applications" {
  ami                    = "ami-0123456789" 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.pub_subnet.id
  vpc_security_group_ids = [aws_security_group.gravity-SG.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "web_application"
  }
}