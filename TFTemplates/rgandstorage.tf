#Postfix for storage account
resource "random_string" "storage_postfix" {
  length = 4
  special = false
  upper = false
}

# Create a resource group
resource "azurerm_resource_group" "tftemplate" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_storage_account" "tftemplate" {
  name                     = join([var.storage_name_prefix], [random_string.storage_postfix.result])
  resource_group_name      = azurerm_resource_group.tftemplate.name
  location                 = azurerm_resource_group.tftemplate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "terraformdemo"
  }
}
}