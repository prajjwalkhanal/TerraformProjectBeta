#-------------------------------------------------------------------#
#    AWS Highly Available Web Cluster with Blue Green Deployment 
#-------------------------------------------------------------------#

provider "aws"{
  region = "ap-southeast-2"
}

data "aws_avaialbility_zones" "working"{}

data "aws_ami" "latest_aws_linux"{
  owner="[137112412989]"
  most_recent = True
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "web" {
  name = "Web Security Group"
  dynamic "ingress" {
    for_each =["80","443"]
    content{
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Web Security Group"
    Owner = "Prajjwal Khanal"
  }
}

resource "aws_launch_configuration" "web" {
  name_prefix = "WebServer-Highly-Available-LC-"
  image_id = data.aws_ami.latest_aws_linux.id
  instance_type = "t3.micro"
  security_groups = [aws_security_group.web.id]
  user_data = file("user_data.sh")

  lifecycle{
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size = 3
  max_size = 3
  min_elb_capacity = 3
  health_check_type = "ELB"
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers = [aws_elb.web.name]

  dynamic "tag" {
    for_each ={
      Name = "WebServer in ASG"
      Owner = "Prajjwal Khanal"
      TAGKEY = "TAGVALUE"
    }
    content{
      key= tag.key
      value = tag.value
      propagate_at_lunch = true
    }
  }
  lifecycle{
    create_before_destroy = true
  }
}

resource "aws_elb" "web" {
  name = "WebServer-HighlyAvailable-ELB"
  availability_zones = [data.aws_availability_zones.working.names[0],data.aws_avaialbility_zones.working.names[1]]
  security_groups = [aws_security_group.web.id]
  listener {
    lb_port=80
    lb_protocol="http"
    instance_port = 80
    instance_protocol ="http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 10
  }
  tags ={
    Name = "WebServer-HighlyAvailable-ELB"
    Owner = "Prajjwal Khanal"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_avaialbility_zones.working.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_avaialbility_zones.working.names[1]
}

output "web_loadbalancer_url" {
  value = aws_elb.web.dns_name
}
