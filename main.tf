terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.75.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "azurerm_resource_group" "mtc-rg" {
  name     = "mtc-resources"
  location = "East US"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "mtc-vn" {
  name                = "mtc-network"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "mtc-subnet" {
  name                 = "mtc-subnet"
  resource_group_name  = azurerm_resource_group.mtc-rg.name
  virtual_network_name = azurerm_virtual_network.mtc-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "mtc-sg" {
  name                = "mtc-sg"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "mtc-dev-rule" {
  name                        = "mtc-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.mtc-rg.name
  network_security_group_name = azurerm_network_security_group.mtc-sg.name
}

resource "azurerm_subnet_network_security_group_association" "mtc-sga" {
  subnet_id                 = azurerm_subnet.mtc-subnet.id
  network_security_group_id = azurerm_network_security_group.mtc-sg.id
}

resource "azurerm_public_ip" "mtc-ip" {
  name                = "mtc-ip"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "mtc-nic" {
  name                = "mtc-nic"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mtc-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mtc-ip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "mtc-vm" {
  name                            = "mtc-vm"
  resource_group_name             = azurerm_resource_group.mtc-rg.name
  location                        = azurerm_resource_group.mtc-rg.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.mtc-nic.id]

  custom_data = filebase64("${path.module}/customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.admin_ssh_pubkey
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/windows-ssh-script.tpl", {
      hostname     = self.public_ip_address,
      user         = "adminuser",
      identityfile = "~/.ssh/mtcazurekey"
    })
    interpreter = ["Powershell", "-Command"]
  }
  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "mtc-ip-data" {
  name                = azurerm_public_ip.mtc-ip.name
  resource_group_name = azurerm_resource_group.mtc-rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.mtc-vm.name}: ${data.azurerm_public_ip.mtc-ip-data.ip_address}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "mtc_kv" {
  name                        = "mtc-keyvault-${random_id.suffix.hex}"
  location                    = azurerm_resource_group.mtc-rg.location
  resource_group_name         = azurerm_resource_group.mtc-rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_key_vault_access_policy" "tf_sp" {
  key_vault_id       = azurerm_key_vault.mtc_kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = var.sp_object_id
  secret_permissions = ["Get", "List", "Set", "Delete"]
}

# -------------------------------
# Local user policy (optional)
# -------------------------------
variable "user_object_id" {
  description = "Object ID of the human user running Terraform locally"
  type        = string
  default     = null
}

resource "azurerm_key_vault_access_policy" "local_user" {
  count              = var.user_object_id == null ? 0 : 1
  key_vault_id       = azurerm_key_vault.mtc_kv.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = var.user_object_id
  secret_permissions = ["Get", "List"]
}

# -------------------------------
# Store VM admin password in Key Vault
# -------------------------------
resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  value        = "P@ssword123!"
  key_vault_id = azurerm_key_vault.mtc_kv.id
}

output "client_id" {
  value = data.azurerm_client_config.current.client_id
}

resource "azurerm_log_analytics_workspace" "mtc_workspace" {
  name                = "mtc-log-workspace"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    environment = "dev"
  }
}

resource "azurerm_monitor_diagnostic_setting" "vm_diagnostics" {
  name                       = "mtc-vm-diagnostics"
  target_resource_id         = azurerm_linux_virtual_machine.mtc-vm.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.mtc_workspace.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.mtc_workspace.id
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.mtc_workspace.name
}

resource "azurerm_monitor_data_collection_endpoint" "mtc_dce" {
  name                = "mtc-dce"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name
  kind                = "Linux"
  description         = "Data Collection Endpoint for mtc-vm"
}

resource "azurerm_monitor_data_collection_rule" "mtc_dcr" {
  name                        = "mtc-dcr"
  location                    = azurerm_resource_group.mtc-rg.location
  resource_group_name         = azurerm_resource_group.mtc-rg.name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.mtc_dce.id

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.mtc_workspace.id
      name                  = "logAnalyticsDestination"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["logAnalyticsDestination"]
  }

  data_sources {
    syslog {
      name = "syslogDataSource"

      facility_names = ["auth", "cron", "daemon", "kern", "syslog", "user"]
      log_levels     = ["Alert", "Critical", "Debug", "Emergency", "Error", "Info", "Notice", "Warning"]
    }
  }
}

terraform {
  backend "azurerm" {}
}

