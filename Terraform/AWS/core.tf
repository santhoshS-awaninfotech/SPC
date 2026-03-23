terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# VPC
resource "aws_vpc" "spcvpc" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.common_tags, { Name = "VPC-${var.reg_code}-SPC"})
}

# resource "aws_subnet" "discsubnet" {
#   vpc_id            = aws_vpc.spcvpc.id
#   cidr_block        = var.discsubnet_cidr
#   availability_zone = data.aws_availability_zones.available.names[0]
#   tags   = merge(var.common_tags, { Name = "SUBNET-${var.reg_code}-SPC-STG-RUNR"})
# }


# Create multiple subnets, one per AZ up to the count you specify
resource "aws_subnet" "discsubnet" {
  count             = var.discvm_count 
  vpc_id            = aws_vpc.spcvpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index) 
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "SUBNET-${var.reg_code}-SPC-STG-RUNR-${count.index + 1}"
  })
}


resource "aws_subnet" "backsubnet" {
  vpc_id            = aws_vpc.spcvpc.id
  cidr_block        = var.backsubnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags   = merge(var.common_tags, { Name = "SUBNET-${var.reg_code}-SPC-STG-UIDB"})
}

# Internet Gateway
resource "aws_internet_gateway" "spcgw" {
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "IGW-${var.reg_code}-SPC-STG"})
}

# Route Table
resource "aws_route_table" "spcrt" {
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "RT-${var.reg_code}-SPC-STG"})
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.spcrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.spcgw.id
}

resource "aws_route_table_association" "assoc_disc" {
  #count          = var.resource_count
  subnet_id      = aws_subnet.discsubnet.id
  route_table_id = aws_route_table.spcrt.id
}

resource "aws_route_table_association" "assoc_backend" {
  subnet_id      = aws_subnet.backsubnet.id
  route_table_id = aws_route_table.spcrt.id
}

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}