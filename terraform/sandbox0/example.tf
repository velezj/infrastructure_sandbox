provider "aws" {
  profile    = "33x.sandbox-dev"
  region     = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-e086a285"
  instance_type = "t2.micro"
}
