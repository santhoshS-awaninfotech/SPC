
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