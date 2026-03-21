resource "aws_eip" "disc_pip" {
  count  = var.discvm_count
  domain = "vpc"
  tags = merge(var.common_tags, { Name = "PIP_discoveryVM${count.index + 1}" })
}

# Create a Network Interface
resource "aws_network_interface" "discvm_nic" {
  count           = var.discvm_count
  subnet_id       = aws_subnet.discsubnet.id
  security_groups = [aws_security_group.discovery_sg.id]
  tags = merge(var.common_tags, { Name = "DISC_NIC${count.index + 1}" })
}

resource "aws_eip_association" "disc_pip_assoc" {
  count                = var.discvm_count
  allocation_id        = aws_eip.disc_pip[count.index].id
  network_interface_id = aws_network_interface.discvm_nic[count.index].id
}

# EC2 Instance
resource "aws_instance" "DiscVM" {
  count         = var.discvm_count
  ami           = data.aws_ami.windows.id
  instance_type = var.disc_instance_type
  key_name      = aws_key_pair.akp.key_name
    tags          = merge(var.common_tags, { Name = "${var.reg_code}-SPC-STG-UIDB-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}-${count.index + 1}"})

  network_interface {
    network_interface_id = aws_network_interface.discvm_nic[count.index].id
    device_index         = 0 
  }
  root_block_device {
    volume_size = 50        
    volume_type = "gp3"    
    delete_on_termination = true
  }

  user_data     = templatefile("${path.module}/scripts/discovery_ud.ps1", {
  ADMIN_PASSWORD = var.admin_password
  USERA_PASSWORD = var.userA_password
  USERB_PASSWORD = var.userB_password
  HOSTNAME       = "${var.reg_code}STGSPCRNR${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}${count.index + 1}"
})
  }