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

resource "aws_security_group" "first_instance_sg" {
  name        = "first_instance_sg"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "first_instance_sg"
  }
}

resource "aws_instance" "first" {
  ami           = data.aws_ami.aml2.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.first.id
  vpc_security_group_ids = [aws_security_group.first_instance_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "first_instance"
  }
}

resource "aws_security_group" "second_instance_sg" {
  name        = "second_instance_sg"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "second_instance_sg"
  }
}

resource "aws_instance" "second" {
  ami           = data.aws_ami.aml2.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.second.id
  vpc_security_group_ids = [aws_security_group.second_instance_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "second_instance"
  }
}
