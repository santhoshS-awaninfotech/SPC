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

# resource "aws_subnet" "backsubnet" {
#   vpc_id            = aws_vpc.spcvpc.id
#   cidr_block        = var.backsubnet_cidr
#   availability_zone = data.aws_availability_zones.available.names[0]
#   tags   = merge(var.common_tags, { Name = "SUBNET-${var.reg_code}-SPC-STG-UIDB"})
# }

resource "aws_subnet" "discsubnet" {
  count             = var.discvm_count 
  vpc_id            = aws_vpc.spcvpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index) 
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "SUBNET-${var.reg_code}-SPC-STG-RUNR-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}-${count.index + 1}"
  })
}

resource "aws_subnet" "backsubnet" {
  count             = var.backendvm_count 
  vpc_id            = aws_vpc.spcvpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 10) 
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "SUBNET-${var.reg_code}-SPC-STG-UIDB-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}-${count.index + 1}"
  })
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
  count             = var.discvm_count 
  subnet_id      = aws_subnet.discsubnet[count.index].id
  route_table_id = aws_route_table.spcrt.id
}

resource "aws_route_table_association" "assoc_backend" {
  count          = var.backendvm_count 
  subnet_id      = aws_subnet.backsubnet[count.index].id
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

resource "aws_resourcegroups_group" "SPCRG" {
  name        = "${var.reg_code}_SPC_ResourceGroup_POC"
  description = "Resource group for SPC POC resources"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": ["AWS::AllSupported"],
  "TagFilters": [
    {
      "Key": "Project",
      "Values": ["SPC"]
    }
  ]
}
JSON
  }

  tags = {
    Project       = "SPC"
    Environment = "Staging"
  }
}