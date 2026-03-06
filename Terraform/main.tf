# Create a Resource Group
# resource "azurerm_resource_group" "SRG1" {
#   name     = "RG_SANT_DELETE1"
#   location = var.location
#   tags = var.common_tags


# }

# # Create a Resource Group
# resource "azurerm_resource_group" "SRG2" {
#   name     = "RG_SANT_DELETE2"
#   location = "West US2"
#   tags = merge(
#     var.common_tags,
#     {
#       Environment = "Testing"   # override just this one
#       Name        = "specialRG"
#     }
#   )
# }

# resource "azurerm_resource_group" "rg" {
#   count    = var.rg_count
#   name     = "RG_SANT_SAMPLE${count.index + 1}"
#   location = var.location
#   tags     = var.common_tags
# }


# resource "azurerm_virtual_network" "VNET1" {
#   name                = "SANT_VNET1"
#   location            = azurerm_resource_group.SRG1.location
#   resource_group_name = azurerm_resource_group.SRG1.name
#   address_space       = ["10.20.0.0/22"]
#   tags = var.common_tags
# }

# resource "azurerm_subnet" "SUBN1" {
#   name                 = "sant_subnet1"
#   resource_group_name  = azurerm_resource_group.SRG1.name
#   virtual_network_name = azurerm_virtual_network.VNET1.name
#   address_prefixes     = ["10.20.1.0/24"]
# }

# resource "azurerm_subnet" "SUBN2" {
#   name                 = "sant_subnet2"
#   resource_group_name  = azurerm_resource_group.SRG1.name
#   virtual_network_name = azurerm_virtual_network.VNET1.name
#   address_prefixes     = ["10.20.2.0/24"]

# }

#-----------------------------------

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

resource "azurerm_windows_virtual_machine" "spcvm" {
  name                  = "VM-SANT-SPCSPT1"
  resource_group_name   = azurerm_resource_group.spcrg.name
  location              = azurerm_resource_group.spcrg.location
  size                  = "Standard_D2als_v6"
  admin_username        = "azureuser"
  admin_password        = var.ADMIN_PASSWORD
  network_interface_ids = [azurerm_network_interface.spcnic.id]
  tags                  = var.common_tags

  os_disk {
    name                 = "osdisk-VM-SANT-SPC-SPOT1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  priority        = "Spot"
  eviction_policy = "Deallocate"
  #max_price = -1
}
