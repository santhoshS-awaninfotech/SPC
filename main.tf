# Create a Resource Group
resource "azurerm_resource_group" "SRG1" {
  name     = "RG_SANT_DELETE1"
  location = var.location
  tags = var.common_tags


}

# Create a Resource Group
resource "azurerm_resource_group" "SRG2" {
  name     = "RG_SANT_DELETE2"
  location = "West US2"
  tags = merge(
    var.common_tags,
    {
      Environment = "Testing"   # override just this one
      Name        = "specialRG"
    }
  )
}

resource "azurerm_resource_group" "rg" {
  count    = var.rg_count
  name     = "RG_SANT_SAMPLE${count.index + 1}"
  location = var.location
  tags     = var.common_tags
}


resource "azurerm_virtual_network" "VNET1" {
  name                = "SANT_VNET1"
  location            = azurerm_resource_group.SRG1.location
  resource_group_name = azurerm_resource_group.SRG1.name
  address_space       = ["10.20.0.0/22"]
  tags = var.common_tags
}

resource "azurerm_subnet" "SUBN1" {
  name                 = "sant_subnet1"
  resource_group_name  = azurerm_resource_group.SRG1.name
  virtual_network_name = azurerm_virtual_network.VNET1.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "SUBN2" {
  name                 = "sant_subnet2"
  resource_group_name  = azurerm_resource_group.SRG1.name
  virtual_network_name = azurerm_virtual_network.VNET1.name
  address_prefixes     = ["10.20.2.0/24"]

}

