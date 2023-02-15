terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.region
}


#01. create ec2 instance
resource "aws_instance" "dp-ec2-1" {
  ami                    = var.ami-id
  instance_type          = var.instance-type
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = aws_subnet.dp_pub_sub_1.id
  

  depends_on = [
    aws_vpc.dp-vpc-1
  ]

  tags = {
    Name = "dp-ec2-1-new"
  }
}

# 02. create vpc
resource "aws_vpc" "dp-vpc-1" {
  cidr_block           = var.vpc-cidr-block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "dp-vpc-1"
  }
}

# 02. create vpc
resource "aws_vpc" "dp-vpc-2" {
  cidr_block           = var.vpc-cidr-block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "dp-vpc-2"
  }
}

#03. create subent
resource "aws_subnet" "dp_pub_sub_1" {
  vpc_id     = aws_vpc.dp-vpc-1.id
  cidr_block = var.dp_pub_sub_1_cidr_block

  tags = {
    Name = "dp_pub_sub_1"
  }
}


#03. create subent
resource "aws_subnet" "dp_priv_sub_1" {
  vpc_id     = aws_vpc.dp-vpc-1.id
  cidr_block = var.dp_priv_sub_1_cidr_block
  tags = {
    Name = "dp_priv_sub_1"
  }
}



# 04. routable
resource "aws_route_table" "dp-rtb-pub-1" {
  vpc_id = aws_vpc.dp-vpc-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dp-igw-1.id
  }

  tags = {
    Name = "dp-rtb-pub-1"
  }
}


#05. internet gateway
resource "aws_internet_gateway" "dp-igw-1" {
  vpc_id = aws_vpc.dp-vpc-1.id

  tags = {
    Name = "dp-igw-1"
  }
}


#06. associate route table to pub subnet 1
resource "aws_route_table_association" "dp_pub_sub_rt_assoc" {
  subnet_id      = aws_subnet.dp_pub_sub_1.id
  route_table_id = aws_route_table.dp-rtb-pub-1.id
}





# 08. nat gateway
resource "aws_nat_gateway" "dp-natgw-1" {
  allocation_id = aws_eip.dp-eip-1.id

  #add nat gateway to public subnet
  subnet_id = aws_subnet.dp_pub_sub_1.id

  tags = {
    Name = "dp-natgw-1"
  }

}


# 07. private route table
resource "aws_route_table" "dp-rtb-priv-1" {
  vpc_id = aws_vpc.dp-vpc-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dp-natgw-1.id
  }
  tags = {
    Name = "dp-rtb-priv-1"
  }
}


#07. associate route table to priv subnet 1
resource "aws_route_table_association" "dp_priv_sub_rt_assoc" {
  subnet_id      = aws_subnet.dp_priv_sub_1.id
  route_table_id = aws_route_table.dp-rtb-priv-1.id
}



#allocation 
resource "aws_eip" "dp-eip-1" {
  vpc = true
}


#security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.dp-vpc-1.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dp-vpc-1.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


output "dp-ec2-1-id" {
  value = aws_instance.dp-ec2-1.id
}

output "dp-ec2-1-public-ip" {
  value = aws_instance.dp-ec2-1.public_ip
}

output "dp-ec2-1-public-dns" {
  value = aws_instance.dp-ec2-1.public_dns
}


resource "local_file" "outpval"{
  content = aws_instance.dp-ec2-1.id
  filename = "instance.txt"
}

/* #data source
data "aws_instance" "mywebserdata"{
    filter {
      name= "tag:Name"
      values= ["dp-ec2-1-new"]  
    }
  depends_on = [
    aws_instance.dp-ec2-1
  ]
}


output "ec2_public_ip" {
  value = data.aws_instance.mywebserdata.public_ip
} */