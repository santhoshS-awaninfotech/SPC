#This is to create EC2 in AWS  with required settings

# VPC
resource "aws_vpc" "spcvpc" {
  cidr_block = "10.100.0.0/22"
}

# Subnet
resource "aws_subnet" "spcsubnet" {
  vpc_id            = aws_vpc.spcvpc.id
  cidr_block        = "10.100.1.0/25"
  availability_zone = var.availability_zone
  tags              = var.common_tags
}

# Internet Gateway
resource "aws_internet_gateway" "spcgw" {
  vpc_id = aws_vpc.spcvpc.id
  tags   = var.common_tags
}

# Route Table
resource "aws_route_table" "spcrt" {
  vpc_id = aws_vpc.spcvpc.id
  tags   = var.common_tags
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.spcrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.spcgw.id
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.spcsubnet.id
  route_table_id = aws_route_table.spcrt.id
}

# Security Group
resource "aws_security_group" "rdprule" {
  vpc_id = aws_vpc.spcvpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a Network Interface
resource "aws_network_interface" "spc_nic" {
  subnet_id       = aws_subnet.spcsubnet.id
  security_groups = [aws_security_group.rdprule.id]

  tags = merge(var.common_tags, { Name = "windows-nic" })
}

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

# EC2 Instance
resource "aws_instance" "spcec2" {
  ami           = data.aws_ami.windows.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.spcsubnet.id
  key_name      = aws_key_pair.akp.key_name
  #associate_public_ip_address = true

  network_interface {
    network_interface_id = aws_network_interface.spc_nic.id
    device_index         = 0   # primary NIC
  }
  root_block_device {
    volume_size = 50        # Size in GB
    volume_type = "gp3"     # General Purpose SSD
    delete_on_termination = true
  }

  # Equivalent to Azure Custom Script Extension
  user_data     = file("${path.module}/scripts/user_data.ps1")
  tags          = merge(var.common_tags, { Name = "spc-mumbai-vm" })

  }

