provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "random" {}

resource "random_string" "sa-name" {
  length = 5
  lower = true
  upper = false
  numeric = false
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-infracost"
  location = "westeurope"
}

resource "azurerm_storage_account" "sa" {
  name                     = "${"sa"}${random_string.sa-name.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_network_interface" "vm_nic" {
  location            = azurerm_resource_group.rg.location
  name                = "linux-nic-primary"
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "primary"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "my_vm" {
  name                = "vm-infracost"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus"

  size           = "Standard_NC24s_v3" # <<<<< Try changing this to Basic_A4 to compare the costs
  admin_username = "fakeuser"
  admin_password = "fakepass"

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}