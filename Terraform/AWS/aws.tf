# VPC
resource "aws_vpc" "spcvpc" {
  cidr_block = "10.100.0.0/22"
  tags = merge(var.common_tags, { Name = "SPC_VPC" })
}

resource "aws_subnet" "spcsubnet" {
  count             = var.resource_count
  vpc_id            = aws_vpc.spcvpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zone
  tags = merge(var.common_tags, {
    Name = "SPC_SUBNET${count.index + 1}"
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

resource "aws_route_table_association" "assoc" {
  count          = var.resource_count
  subnet_id      = aws_subnet.spcsubnet[count.index].id
  route_table_id = aws_route_table.spcrt.id
}

# Security Group
resource "aws_security_group" "vm1_sg" {
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "SG-SPC-FOR-VM1" })

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.100.2.0/24", "0.0.0.0/0"] # Example: only allow DB traffic inside VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vm2_sg" {
  vpc_id = aws_vpc.spcvpc.id
  tags   = merge(var.common_tags, { Name = "SG-SPC-FOR-VM2" })

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
resource "aws_eip" "spcpip" {
  count  = var.resource_count
  domain = "vpc"
  tags = merge(var.common_tags, { Name = "SPC_PIP_VM1" })
}

# Create a Network Interface
resource "aws_network_interface" "spc_nic" {
  count           = var.resource_count
  subnet_id       = aws_subnet.spcsubnet[count.index].id
    security_groups = [
    element([aws_security_group.vm1_sg.id, aws_security_group.vm2_sg.id], count.index)
  ]
  tags = merge(var.common_tags, { Name = "SPC_NIC${count.index}" })
}

resource "aws_eip_association" "pip_assoc" {
  count                = var.resource_count
  allocation_id        = aws_eip.spcpip[count.index].id
  network_interface_id = aws_network_interface.spc_nic[count.index].id
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
resource "aws_instance" "spcVM" {
  count         = var.resource_count
  ami           = data.aws_ami.windows.id
  instance_type = var.instance_type
  #subnet_id     = aws_subnet.spcsubnet.id
  key_name      = aws_key_pair.akp.key_name
  #associate_public_ip_address = true
  tags          = merge(var.common_tags, { Name = "spc-mumbai-vm-${count.index}" })

  network_interface {
    network_interface_id = aws_network_interface.spc_nic[count.index].id
    device_index         = 0 
  }
  root_block_device {
    volume_size = 50        
    volume_type = "gp3"    
    delete_on_termination = true
  }

  # Equivalent to Azure Custom Script Extension
  user_data     = templatefile("${path.module}/scripts/user_data.ps1", {
  ADMIN_PASSWORD = var.admin_password
  USERA_PASSWORD = var.userA_password
  USERB_PASSWORD = var.userB_password
  PGSQLPASSWORD  = var.pgsql_password
})
  }