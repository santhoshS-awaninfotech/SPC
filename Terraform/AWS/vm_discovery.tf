resource "aws_eip" "disc_pip" {
  count  = var.discvm_count
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "PIP-${var.reg_code}-SPC-STG-RUNR-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}-${count.index + 1}"})
}

# Create a Network Interface
resource "aws_network_interface" "discvm_nic" {
  count           = var.discvm_count
  subnet_id       = aws_subnet.discsubnet.id
  security_groups = [aws_security_group.discovery_sg.id]
  tags            = merge(var.common_tags, { Name = "NIC-${var.reg_code}-SPC-STG-RUNR-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}-${count.index + 1}"})
}

resource "aws_eip_association" "disc_pip_assoc" {
  count                = var.discvm_count
  allocation_id        = aws_eip.disc_pip[count.index].id
  network_interface_id = aws_network_interface.discvm_nic[count.index].id
}

# EC2 Instance
# resource "aws_instance" "DiscVM" {
#   count         = var.discvm_count
#   ami           = data.aws_ami.windows.id
#   instance_type = var.disc_instance_type
#   key_name      = aws_key_pair.akp.key_name
#   tags          = merge(var.common_tags, { Name = "VM-${var.reg_code}-SPC-STG-RUNR-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}-${count.index + 1}"})

#    # Spot instance configuration
#   instance_market_options {
#     market_type = "spot"

#     spot_options {
#       instance_interruption_behavior = "stop"   # or "stop", "hibernate"
#       spot_instance_type             = "persistent" # "one-time" or "persistent"
#     }
#   }

#   network_interface {
#     network_interface_id = aws_network_interface.discvm_nic[count.index].id
#     device_index         = 0 
#   }
#   root_block_device {
#     volume_size = 50        
#     volume_type = "gp3"    
#     delete_on_termination = true
#     tags   = merge(var.common_tags, { Name = "DISK-ROOT-C-${var.reg_code}-SPC-STG-RUNR"})
#   }

#   user_data     = templatefile("${path.module}/scripts/discovery_ud.ps1", {
#   ADMIN_PASSWORD = var.admin_password
#   USERA_PASSWORD = var.userA_password
#   USERB_PASSWORD = var.userB_password
#   HOSTNAME       = "${var.reg_code}SPC2RUNR${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 2))}${count.index + 1}"
# })
#   }



resource "aws_launch_template" "discvmtemplate" {
  name_prefix   = "discvm-"
  image_id      = data.aws_ami.windows.id
  instance_type = var.disc_instance_type
  key_name      = aws_key_pair.akp.key_name

  network_interfaces {
    network_interface_id = aws_network_interface.discvm_nic[0].id
    device_index         = 0
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      delete_on_termination = true
      # tags = merge(var.common_tags, {
      #   Name = "DISK-ROOT-C-${var.reg_code}-SPC-STG-RUNR"
      # })
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "VM-${var.reg_code}-SPC-STG-RUNR"
    })
  }

  user_data = templatefile("${path.module}/scripts/discovery_ud.ps1", {
    ADMIN_PASSWORD = var.admin_password
    USERA_PASSWORD = var.userA_password
    USERB_PASSWORD = var.userB_password
    HOSTNAME       = "${var.reg_code}SPC2RUNR"
  })
}

resource "aws_ec2_fleet" "discvm_fleet" {
  launch_template_config {
    launch_template_specification {
      launch_template_id = aws_launch_template.discvmtemplate.id
    }
  }

  target_capacity_specification {
    total_target_capacity        = var.discvm_count
    default_target_capacity_type = "spot"   # prefer Spot
    on_demand_target_capacity    = 0        # only fallback if Spot unavailable
  }

  spot_options {
    allocation_strategy = "capacity-optimized"  # reduce interruptions
  }

  on_demand_options {
    allocation_strategy = "lowestPrice"         # fallback to cheapest On‑Demand
  }
}