resource "aws_eip" "back_pip" {
  count  = var.backendvm_count
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "PIP-${var.reg_code}-SPC-STG-UIDB-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}-${count.index + 1}"})
}

# Create a Network Interface
resource "aws_network_interface" "back_nic" {
  count           = var.backendvm_count
  subnet_id       = aws_subnet.backsubnet[count.index].id
  security_groups = [aws_security_group.backend_sg.id]
  tags            = merge(var.common_tags, { Name = "NIC-${var.reg_code}-SPC-STG-UIDB-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}-${count.index + 1}"})
}

resource "aws_eip_association" "back_pip_assoc" {
  count                = var.backendvm_count
  allocation_id        = aws_eip.back_pip[count.index].id
  network_interface_id = aws_network_interface.back_nic[count.index].id
}

# EC2 Instance
resource "aws_instance" "backVM" {
  count         = var.backendvm_count
  ami           = data.aws_ami.windows.id
  instance_type = var.be_instance_type
  key_name      = aws_key_pair.akp.key_name
  tags          = merge(var.common_tags, { Name = "VM-${var.reg_code}-SPC-STG-UIDB-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}-${count.index + 1}"})

  network_interface {
    network_interface_id = aws_network_interface.back_nic[count.index].id
    device_index         = 0 
  }
  root_block_device {
    volume_size           = 50        
    volume_type           = "gp3"    
    delete_on_termination = true
    tags   = merge(var.common_tags, { Name = "DISK-ROOT-C-${var.reg_code}-SPC-STG-UIDB"})
  }
    ebs_block_device {
    device_name           = "xvdf" 
    volume_size           = 50      
    volume_type           = "gp3"
    delete_on_termination = true
    tags   = merge(var.common_tags, { Name = "DISK-DATA-F-${var.reg_code}-SPC-STG-UIDB"})
  }

  user_data     = templatefile("${path.module}/scripts/backend_ud.ps1", {
  ADMIN_PASSWORD = var.admin_password
  USERA_PASSWORD = var.userA_password
  USERB_PASSWORD = var.userB_password
  PGSQLPASSWORD  = var.pgsql_password
  HOSTNAME       = "${var.reg_code}SPC2UIDB${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}${count.index + 1}"

})
  }