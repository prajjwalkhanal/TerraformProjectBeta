provider "aws" {
    region = "ap-southeast-2"
}
resource "aws_instance" "BETAAWSWS02" {
    ami = "ami-0186908e2fdeea8f3"
    instance_type = "t2.micro"

    tags = {
      Description = "Webserver-02"
      Type = "LAB"
    }  
}
resource "aws_instance" "BETAAWSWS03" {
  ami = "ami-0186908e2fdeea8f3"
  instance_type = "t2.micro"

  tags = {
      Description = "Webserver-03"
      Type = "Lab"
  }
}