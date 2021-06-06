provider "aws" {
  profile = "default"
  region = "ap-southeast-2"
}
resource "aws_instance" "BETAAWSWS01" {
    ami = "ami-0186908e2fdeea8f3"       //AWS Linux 2 AMI
    instance_type= "t3.micro"
    vpc_security_group_ids = [aws_security_group.SG-WebServer.id]

    user_data = <<EOF
        #!/bin/bash
        yum -y update
        yum -y install httpd
        MYIP= curl httpd://169.254.169.254/latest/meta-data/local-ipv4
        echo "<h2>Webserver with Private: $MYIP </h2><br>Build by Terraform" > /var/www/html/index.html
        service httpd start
        chconfig httpd on
        EOF 
    tags = {
        Name ="BETAAWSWS01"
        Environment ="Personal"
    }
}

resource "aws_security_group" "SG-WebServer" {
  name = "SG-WebServer"
  description = "Security group to Webserver"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS Inbound Rule"
    from_port = 80
    protocol = "TCP"
    to_port = 80
  }

  ingress {
      cidr_blocks=["0.0.0.0/0"]
      description ="HTTPS Inbound Rule"
      from_port = 443
      protocol = "tcp"
      to_port = 443
  }

   egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS Outbound Rules"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }

  tags = {
    Environment= "Personal"
  }

}