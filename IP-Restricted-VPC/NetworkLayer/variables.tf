variable "env"{
    default= "dev"
}

variable "vpc_cidr"{
    default= "100.0.0.0/16"
}

variable "private_subnet_cidrs"{
    default = [
        "100.0.1.0/24",
        "100.0.2.0/24",
    ]
}

variable "public_subnet_cidrs"{
    default = [
        "100.0.11.0/24",
        "100.0.22.0/24",
    ]
}

variable "tags"{
    default ={
        Owner = "Prajjwal-Khanal"
        Project = "IP-Restricted-VPC"

    }
}

