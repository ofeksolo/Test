resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fw" {
  name                = var.fw_name
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                 = "fw_ip_config"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_firewall_network_rule_collection" "time" {
  name                = "time"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group
  priority            = 101
  action              = "Allow"

  rule {
    description           = "aks node time sync rule"
    name                  = "allow network"
    source_addresses      = ["*"]
    destination_ports     = ["123"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "dns" {
  name                = "dns"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group
  priority            = 102
  action              = "Allow"

  rule {
    description           = "aks node dns rule"
    name                  = "allow network"
    source_addresses      = ["*"]
    destination_ports     = ["53"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "servicetags" {
  name                = "servicetags"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group
  priority            = 110
  action              = "Allow"

  rule {
    description       = "allow service tags"
    name              = "allow service tags"
    source_addresses  = ["*"]
    destination_ports = ["*"]
    protocols         = ["Any"]

    destination_addresses = [
      "AzureContainerRegistry",
      "MicrosoftContainerRegistry",
      "AzureActiveDirectory"
    ]
  }
}

resource "azurerm_firewall_application_rule_collection" "aksallowegress" {
  name                = "aksbasics"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group
  priority            = 101
  action              = "Allow"

  rule {
    name             = "allow network"
    source_addresses = ["*"]

    target_fqdns = ["*"]

    protocol {
      port = "80"
      type = "Http"
    }

    protocol {
      port = "443"
      type = "Https"
    }
  }
}