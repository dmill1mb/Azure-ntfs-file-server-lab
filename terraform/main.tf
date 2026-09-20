provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-fslab"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  # Points every domain member's DNS at DC01 so lab.local (and its SRV
  # records) can actually be resolved. Added after initial apply — a VM
  # that was already running needs a restart to pick this up.
  dns_servers = [var.dc01_private_ip]
}

resource "azurerm_subnet" "lab" {
  name                 = "snet-fslab"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = var.subnet_address_prefix
}

resource "azurerm_network_security_group" "lab" {
  name                = "nsg-fslab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "Allow-RDP-From-Me"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.allowed_rdp_source_ip
    destination_address_prefix = "*"
  }
  # Everything else is denied by the NSG's implicit DenyAllInBound rule.
}

resource "azurerm_subnet_network_security_group_association" "lab" {
  subnet_id                 = azurerm_subnet.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

# ---------- DC01 ----------

resource "azurerm_public_ip" "dc01" {
  name                = "pip-dc01"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "dc01" {
  name                = "dc01-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.dc01_private_ip
    public_ip_address_id          = azurerm_public_ip.dc01.id
  }
}

resource "azurerm_windows_virtual_machine" "dc01" {
  name                   = "DC01"
  resource_group_name    = azurerm_resource_group.lab.name
  location               = azurerm_resource_group.lab.location
  size                   = var.server_vm_size
  admin_username         = var.admin_username
  admin_password         = var.admin_password
  network_interface_ids  = [azurerm_network_interface.dc01.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

# ---------- FS01 ----------

resource "azurerm_public_ip" "fs01" {
  name                = "pip-fs01"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# depends_on forces this NIC to wait until dc01-nic is created, so its
# Dynamic allocation can never grab the address DC01's Static request
# needs. Without this, Terraform creates all NICs in parallel and a
# Dynamic NIC finishing first can steal DC01's IP (PrivateIPAddressIsAllocated).
resource "azurerm_network_interface" "fs01" {
  name                = "fs01-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.fs01.id
  }

  depends_on = [azurerm_network_interface.dc01]
}

resource "azurerm_windows_virtual_machine" "fs01" {
  name                   = "FS01"
  resource_group_name    = azurerm_resource_group.lab.name
  location               = azurerm_resource_group.lab.location
  size                   = var.server_vm_size
  admin_username         = var.admin_username
  admin_password         = var.admin_password
  network_interface_ids  = [azurerm_network_interface.fs01.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

# ---------- CLIENT01 ----------

resource "azurerm_public_ip" "client01" {
  name                = "pip-client01"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "client01" {
  name                = "client01-nic"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.client01.id
  }

  depends_on = [azurerm_network_interface.dc01]
}

resource "azurerm_windows_virtual_machine" "client01" {
  name                   = "CLIENT01"
  resource_group_name    = azurerm_resource_group.lab.name
  location               = azurerm_resource_group.lab.location
  size                   = var.client_vm_size
  admin_username         = var.admin_username
  admin_password         = var.admin_password
  network_interface_ids  = [azurerm_network_interface.client01.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = var.client_image_sku
    version   = "latest"
  }
}
