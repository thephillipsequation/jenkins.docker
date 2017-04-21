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
    environment = "jenkins"
  }
}

resource "azure_security_group" "ssh_access" {
	name = "ssh_access"
	location = "East US"
}

resource "azure_security_group_rule" "ssh_access" {
	depends_on = ["azure_security_group.testnsg"]
	name = "my-ssh-access-rule"
	security_group_names = ["${azure_security_group.ssh_access.name}"]
	type = "Inbound"
	action = "Allow"
	priority = 200
	source_address_prefix = "*"
	source_port_range = "*"
	destination_address_prefix = "*"
	destination_port_range = "22"
	protocol = "TCP"
}

#Create Jenkins vnet
resource "azurerm_virtual_network" "jenkinsNetwork"{
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

resource "azure_storage_service" "storage" {
	name = "myvmstorage"
	location = "East US"
	description = "Made by Terraform"
	account_type = "Standard_LRS"
}

resource "azure_instance" "jenkinsMaster" {
	depends_on = ["azure_virtual_network.jenkinsNetwork", "azure_storage_service.storage", "azure_security_group.ssh_access", "azure_security_group.jenkinsPublic" ]
	name = "jenkinsMaster"
	hosted_service_name = "${azure_hosted_service.myservice.name}"
	description = "my linux server"
  #change this image name
	image = "Ubuntu Server 14.04 LTS"
	size = "Basic_A1"
	subnet = "moduleone"
	virtual_network = "${azure_virtual_network.jenkinsNetwork.name}"
	storage_service_name = "${azure_storage_service.storage.name}"
	location = "East US"
	username = "Github123"
	password = "Github123"
	count = "1"
	endpoint {
		name = "SSH"
		protocol = "tcp"
		public_port = 22
		private_port = 22
	}
	security_group = "${azure_security_group.ssh_access.name}"
}