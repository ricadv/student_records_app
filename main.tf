terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "TF4640" {
  cidr_block = "10.55.0.0/16"
  tags = {
    Name = "TF4640_VPC"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.TF4640.id
  availability_zone = "us-west-2a"
  cidr_block        = "10.55.10.0/24"
  tags = {
    Name = "TF4640_SUBNET"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.TF4640.id
  tags = {
    Name = "TF4640_IGW"
  }
}

resource "aws_route_table" "routes" {
  vpc_id = aws_vpc.TF4640.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "TF4640_RTBL"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.routes.id
}

resource "aws_security_group" "allow_ssh_http_db" {
  name        = "allow_ssh_http_db"
  description = "Allow SSH, HTTP, MYSQL inbound traffic"
  vpc_id      = aws_vpc.TF4640.id

  ingress {
    description = "SSH to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP to EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "DB to EC2"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.subnet.cidr_block]
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

resource "aws_instance" "app" {
  subnet_id                   = aws_subnet.subnet.id
  ami                         = "ami-0c09c7eb16d3e8e70"
  key_name                    = "aws_private_key"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http_db.id]

  tags = {
    Name    = "app"
    Service = "APP"
  }
}

resource "aws_instance" "db" {
  subnet_id                   = aws_subnet.subnet.id
  ami                         = "ami-0c09c7eb16d3e8e70"
  key_name                    = "aws_private_key"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http_db.id]

  tags = {
    Name    = "db"
    Service = "DB"
  }
}
