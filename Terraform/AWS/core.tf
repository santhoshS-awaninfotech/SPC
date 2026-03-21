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
  tags = merge(var.common_tags, { Name = "SPC_VPC" })
}

resource "aws_subnet" "discsubnet" {
  vpc_id            = aws_vpc.spcvpc.id
  cidr_block        = var.discsubnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = merge(var.common_tags, {Name = "Discovery_Subnet"
  })
}

resource "aws_subnet" "backsubnet" {
  vpc_id            = aws_vpc.spcvpc.id
  cidr_block        = var.backsubnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = merge(var.common_tags, {Name = "Backend_Subnet"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "spcgw" {
  vpc_id = aws_vpc.spcvpc.id
  tags = merge(var.common_tags, { Name = "SPC_IGW" })
}

# Route Table
resource "aws_route_table" "spcrt" {
  vpc_id = aws_vpc.spcvpc.id
  tags = merge(var.common_tags, { Name = "SPC_ROUTETABLE" })
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
