#01. ami -id 
variable "ami-id" {
  default = "ami-08cd358d745620807"
}


#01. instance
variable "instance-type" {
  type = string
  default = "t2.micro"
}

#03 variable 
variable "vpc-cidr-block" {
  default = "10.0.0.0/16"
}


#04 "aws_subnet" "dp_pub_sub_1" cidr block
variable "dp_pub_sub_1_cidr_block" {
  default = "10.0.1.0/24"
}


#05 "aws_subnet" "dp_priv_sub_1" cidr block
variable "dp_priv_sub_1_cidr_block" {
  default = "10.0.2.0/24"
}

/* variable "sec-group-ids"{
    #type = list
    default = aws_security_group.allow_ssh.id
} */

variable "dns_hostnames"{
    type = bool
    default = true
}

variable "region"{
    default = "eu-west-2"
}
#number of ec2 to create = 3
#3 = number
