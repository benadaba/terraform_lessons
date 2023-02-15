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
  #vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = aws_subnet.dp_pub_sub_1.id
  

  /* depends_on = [
    aws_vpc.dp-vpc-1
  ] */

  tags = {
    Name = "dp-ec2-1-new"
  }
}

