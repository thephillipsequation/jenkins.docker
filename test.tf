provider "aws" {
  access_key = "AKIAJHEQDYS3ODKXSS2Q,NnV8MLqZIKSEsxkKWWmfnAGqxfPslb136c9sSuw6"
  secret_key = "SECRET_KEY_HERE"
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}