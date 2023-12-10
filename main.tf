provider "aws" {
  region = "ap-southeast-1"
  profile = "network-basics"

  default_tags {
    tags = {
      Created-For = "network-basics-tutorial"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "first" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "first_subnet"
  }
}

resource "aws_subnet" "second" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "second_subnet"
  }
}