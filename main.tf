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

  tags = {
    Name = "main_vpc"
  }
}