provider "aws" {
  region = "ap-southeast-1"
  profile = "network-basics"

  default_tags {
    tags = {
      Created-For = "network-basics-tutorial"
    }
  }
}
