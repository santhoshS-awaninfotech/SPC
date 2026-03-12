#This is to create VM in Azure with required settings

resource "azurerm_resource_group" "spcrg" {
  name     = "RG_SANT_TEMP"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_virtual_network" "spcvnet" {
  name                = "VNET_SANT_SPC1"
  address_space       = ["10.11.0.0/22"]
  location            = azurerm_resource_group.spcrg.location
  resource_group_name = azurerm_resource_group.spcrg.name
  tags = var.common_tags
}

resource "azurerm_subnet" "spcsubnet" {
  name                 = "SN_SANT_SPC"
  resource_group_name  = azurerm_resource_group.spcrg.name
  virtual_network_name = azurerm_virtual_network.spcvnet.name
  address_prefixes     = ["10.11.0.0/25"]
}

resource "azurerm_public_ip" "spcpip" {
  name                = "PIP_SANT_SPC_VM1"
  location            = azurerm_resource_group.spcrg.location
  resource_group_name = azurerm_resource_group.spcrg.name
  allocation_method   = "Dynamic"
  tags                = var.common_tags
}

resource "azurerm_application_security_group" "spcasg" {
  name                = "ASG-SANT-FOR-SPC-VM"
  location            = azurerm_resource_group.spcrg.location
  resource_group_name = azurerm_resource_group.spcrg.name
  tags                  = var.common_tags
}

resource "azurerm_network_interface" "spcnic" {
  name                = "NIC-SANT-SPC-VM1"
  location            = azurerm_resource_group.spcrg.location
  resource_group_name = azurerm_resource_group.spcrg.name
  tags                = var.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spcsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.spcpip.id
  }
}

resource "azurerm_network_interface_application_security_group_association" "spc_asg_assoc" {
  network_interface_id          = azurerm_network_interface.spcnic.id
  application_security_group_id = azurerm_application_security_group.spcasg.id
}

resource "azurerm_network_security_group" "spcnsg" {
  name                = "NSG-SANT-FOR-SPC-VM"
  location            = azurerm_resource_group.spcrg.location
  resource_group_name = azurerm_resource_group.spcrg.name
  tags                  = var.common_tags
  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = ["183.82.27.94/32", "59.144.62.30/32", "49.249.168.130/32"]

    destination_application_security_group_ids = [
      azurerm_application_security_group.spcasg.id
    ]

  }

  security_rule {
    name                       = "Allow-ICMP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/8"
    destination_application_security_group_ids = [
      azurerm_application_security_group.spcasg.id
    ]

    #destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "spc_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.spcnic.id
  network_security_group_id = azurerm_network_security_group.spcnsg.id
}

resource "azurerm_windows_virtual_machine" "spcvm" {
  name                  = "VM-SANT-SPCSPT1"
  resource_group_name   = azurerm_resource_group.spcrg.name
  location              = azurerm_resource_group.spcrg.location
  size                  = "Standard_D2als_v6"
  admin_username        = "azadmin"
  admin_password        = var.ADMIN_PASSWORD
  network_interface_ids = [azurerm_network_interface.spcnic.id]
  tags                  = var.common_tags

  os_disk {
    name                 = "osdisk-VM-SANT-SPC-SPOT1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-25h2-ent"
    version   = "latest"
  }

  priority        = "Spot"
  eviction_policy = "Deallocate" 

  #custom_data = filebase64("${path.module}/scripts/boot.ps1")
}





