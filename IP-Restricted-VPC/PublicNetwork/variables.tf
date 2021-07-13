variable "env"{
    default= "dev"
}

variable "vpc_cidr"{
    default= "100.0.0.0/16"
}


variable "public_subnet_cidrs"{
    default = [
        "100.0.11.0/24",
        "100.0.22.0/24",
    ]
}

variable "allowed_ip" {
  default = [
      "202.7.202.199/32",
  ]
}

variable "allowed_rule" {
  default = [
      "200",
      "210",
  ]
}

variable "tags"{
    default ={
        Owner = "Prajjwal-Khanal"
        Project = "IP-Restricted-Public-VPC"

    }
}

