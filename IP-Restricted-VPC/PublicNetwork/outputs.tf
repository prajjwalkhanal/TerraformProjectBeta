output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public-subnet-main[*].id
}

output "instance_id" {
  value = aws_instance.BetaAWS001.host_id
}