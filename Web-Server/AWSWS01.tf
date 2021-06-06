provider "aws" {
  profile = "default"
  region = "ap-southeast-2"
}
resource "aws_instance" "AWSWS01" {
    ami = "ami-830c94e3"
    instance_type = "t3.micro"

    tags = {
        Name ="BETAAWSWS01"
    }
    
}