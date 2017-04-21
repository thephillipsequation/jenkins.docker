# Configure Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

#Create Jenkins resource group
resource "azurerm_resource_group" "jenkins" {
  name     = "jenkins"
  location = "East US"
}

#Create Jenkins public security group
resource "azurerm_network_security_group" "jenkinsPublic" {
  name                = "jenkinsPublic"
  location            = "East US"
  resource_group_name = "${azurerm_resource_group.jenkins.name}"

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "jenkins"
  }
}

#Create Jenkins Private security group
resource "azurerm_network_security_group" "jenkinsPrivate" {
  name                = "jenkinsPrivate"
  location            = "East US"
  resource_group_name = "${azurerm_resource_group.jenkins.name}"

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "10.0.0.0/16"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Production"
  }
}

#Create Jenkins vnet
resource "azurerm_virtual_network" "network"{
  name          = "jenkinsNetwork"
  address_space = ["10.0.0.0/16"]
  location      = "East US"
  resource_group_name = "${azurerm_resource_group.jenkins.name}"

  subnet {
    name                = "public_subnet_1"
    address_prefix      = "10.0.1.0/24"
    security_group      = "${azurerm_network_security_group.jenkinsPublic.id}"
  }

  subnet { 
    name                = "private_subnet_1"
    address_prefix      = "10.0.2.0/24"
    security_group      = "${azurerm_network_security_group.jenkinsPrivate.id}"
  }
}