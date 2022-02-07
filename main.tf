# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

module "network" {
  source = "./modules/vnet"
  location = data.azurerm_resource_group.rg.location
  resource_group = data.azurerm_resource_group.rg.name
  prefix = var.prefix
  tags = var.tags
}

module "rand" {
  source = "./modules/rand"
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.prefix}TFVM"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  network_interface_ids = [module.network.nic_id]
  vm_size               = "Standard_DS1_v2"
  tags                  = var.tags

  storage_os_disk {
    name              = "${var.prefix}OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = lookup(var.vm_sku, data.azurerm_resource_group.rg.location)
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}TFVM"
    admin_username = var.admin_username
    admin_password = module.rand.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
