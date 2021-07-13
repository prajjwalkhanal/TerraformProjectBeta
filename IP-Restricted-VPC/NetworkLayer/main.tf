#---------------------------------------------------------------------------------------------#
#
#                                 VPC with Restricted IP    
#
#---------------------------------------------------------------------------------------------#

provider "aws" {
    region = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "terraformstatefile-projectbeta"         // Bucket where to SAVE Terraform State
    key    = "ip-restricted/dev/terraform.tf"         // Object name in the bucket to SAVE Terraform State
    region = "ap-southeast-2"                         // Region where bucket created
  }
}

#----------------------------- VPC - AZ - internetgateway  ----------------------------------#

data "aws_availability_zones" "availability" {}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    tags = merge(var.tags,{Name = "${var.env}-vpc-main"})
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags= merge(var.tags,{Name = "${var.env}-igw"})   
}

#---------------------------------------------------------------------------------------------#


#------------------------ public subnet and route table --------------------------------------#

resource "aws_subnet" "public_subnet_main" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.public_subnet_cidrs,count.index)
    availability_zone = data.aws_availability_zones.availability.names[count.index]
    map_public_ip_on_launch = true
    tags= merge(var.tags,{Name = "${var.env}-public-subnet-${count.index+1}"})
}

resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.main.id
    route {
            cidr_block= "0.0.0.0/0"
            gateway_id = aws_internet_gateway.main.id
    }
    tags = merge(var.tags,{Name="${var.env}-public-route-table"})
}

resource "aws_route_table_association" "public-assocation-table" {
    depends_on = [
      aws_route_table.public-route-table,
      aws_subnet.public_subnet_main,
    ]
    count = length(var.public_subnet_cidrs)
    route_table_id = aws_route_table.public-route-table.id
    subnet_id = aws_subnet.private_subnet_main[count.index].id
}

#---------------------------------------------------------------------------------------------#

#---------------- Network ACL with IP access for Public Subent -------------------------------#

resource "aws_network_acl" "DedicatedIP" {
    vpc_id = aws_vpc.main.id
    subnet_ids = [aws_subnet.private_subnet_main[0].id]
    tags = var.tags
}

resource "aws_network_acl_rule" "VPCNetworkE" {
    network_acl_id = aws_network_acl.DedicatedIP.id
    rule_number = 100
    egress = false
    protocol = -1
    rule_action ="allow"
    cidr_block = var.vpc_cidr
    from_port = 0
    to_port = 0
}

resource "aws_network_acl_rule" "OfficeNtwE" {
    count = length(var.allowed_ip)
    network_acl_id = aws_network_acl.DedicatedIP.id
    rule_number = var.allowed_rule[count.index]
    egress = false
    protocol = -1
    rule_action ="allow"
    cidr_block = var.allowed_ip[count.index]
    from_port = 0
    to_port = 0
}

resource "aws_network_acl_rule" "VPCNetworkI" {
    network_acl_id = aws_network_acl.DedicatedIP.id
    rule_number = 100
    egress = true
    protocol = -1
    rule_action ="allow"
    cidr_block = var.vpc_cidr
    from_port = 0
    to_port = 0
}

resource "aws_network_acl_rule" "OfficeNtwI" {
    count = length(var.allowed_ip)
    network_acl_id = aws_network_acl.DedicatedIP.id
    rule_number = var.allowed_rule[count.index]
    egress = true
    protocol = -1
    rule_action ="allow"
    cidr_block = var.allowed_ip[count.index]
    from_port = 0
    to_port = 0
}

#---------------------------------------------------------------------------------------------#

#--------------- NAT Gateways with Elastic IP ------------------------------------------------#
resource "aws_eip" "nat" {
    count = length(var.private_subnet_cidrs)
    vpc = true
    tags = merge(var.tags,{Name="${var.env}-nat-gw-${count.index + 1}"})
}

resource "aws_nat_gateway" "nat" {
    count = length(var.private_subnet_cidrs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.private_subnet_main[count.index].id
    tags = merge(var.tags, {Name = "${var.env}-nat-gw-${count.index+1}"})
}

#---------------------------------------------------------------------------------------------#

#------------------------- private subnet and nat gateway for each subnet --------------------#

resource "aws_subnet" "private_subnet_main" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = element(var.private_subnet_cidrs,count.index)
    availability_zone = data.aws_availability_zones.availability.names[count.index]
    tags= merge(var.tags,{Name="${var.env}-private-subnet-${count.index+1}"})
}

resource "aws_route_table" "private-route-table" {    
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    route {
        cidr_block= "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat[count.index].id
    }
    tags = merge(var.tags, { Name = "${var.env}-private-route-table-${count.index + 1}"})
}

resource "aws_route_table_association" "private_routes" {
    depends_on = [
      aws_route_table.private-route-table,
    ]
    count = length(aws_subnet.private_subnet_main[*].id)
    route_table_id = aws_route_table.private-route-table[count.index].id
    subnet_id = element(aws_subnet.private_subnet_main[*].id,count.index)
}

#--------------------------------------------------------------------------------------------#