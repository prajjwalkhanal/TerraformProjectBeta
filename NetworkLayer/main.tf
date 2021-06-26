#--------------------------------------------------------------------
#                      Network Layer for Web Application 
#--------------------------------------------------------------------

provider "aws" {
    default = "ap-southeast-2" // Defaulted region to Sydney
}

terraform {
  backend "s3" {
    bucket = "terraformstatefile-projectbeta"            // Bucket where to SAVE Terraform State
    key    = "dev/network-layer/terraform.tfstate"      // Object name in the bucket to SAVE Terraform State
    region = "ap-southeast-2"                           // Region where bucket created
  }
}

data "aws_availability_zones" "available"{}              //Get map of all available zone in default region

resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr                          //Create VPC 
    tags = merge(var.tags, {Name = "${var.env}-vpc"})
}

resource "aws_internet_gateway" "main"{
    vpc_id = aws_vpc.main.id                            //Create InternetGateway
    tags = merge(var.tags ,{Name = "${var.env}-igw"})
}

resource "aws_subnet" "public_subnets"{
    count = length(var.public_subnet_cidrs)                                             //Create Subenet
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.public_subnet_cidrs,count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
    tags = merge(var.tags, {Name = "${var.env}-public}-${count.index+1}"})
}

resource "aws_route_table" "public_subnets"{
    vpc_id = aws_vpc.main.id
    route{                                                                                 //Create Public Routing Table
        cidr_block = "0.0.0.0/0"
        gateway_id =aws_internet_gateway.main.id
    }
    tags = merge(var.tags, {Name = "${var.env}-route-public-subnets"})
}

resource "aws_route_table_association" "public_routes"{
    count = length(aws_subnet.public_subnets[*].id)
    route_table_id = aws_route_table.public_subnets.id                                       //Associcate Subnet with Routing table
    subnet_id = aws_subnet.public_subnets[count.index].id
}

resource "aws_eip" "nat"{
    count = length(var.private_subnet_cidrs)                                                 //Create elastic IP 
    vpc = true
    tags = merge(var.tags, {Name = "${var.env}-nat-gw-${count.index+1}"})
}

resource "aws_nat_gateway" "nat"{
    count = length(var.private_subnet_cidrs)
    allocation_id = aws_eip.nat[count.index].id                                             //Create NAT gatway for private subnet
    subnet_id = aws_subnet.public_subnets[count.index].id
    tags = merge(var.tags, {Name = "$(var.env)-nat-gw-${count.index+1}"})
}

resource "aws_subnet" "private_subnets" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]        //Create Private Subnet
    tags = merge(var.tags,{Name="${var.env}-private-${count.index+1}"})
}

resource "aws_route_table" "private_subnets" {
    count = length(var.private_subnet_cidrs)                                                //Create Private Subnet
    vpc_id = aws_vpc.main.id
    route{
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat[count.index].id
    }
    tags = merge(var.tags, {Name="${var.env}-route-private-subent-${count.index +1}"})
}

resource "aws_route_table_association" "private_routes"{
    count = length(aws_subnet.private_subnets[*].id)
    route_table_id = aws_route_table.private_subnets[count.index].id                        //Associate private subnet with private routing table
    subnet_id = aws_subnet.private_subnets[count.index].id
}
