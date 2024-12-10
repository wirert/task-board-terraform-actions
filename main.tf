terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = azurerm_resource_group.taskboardrg.name
    storage_account_name = azurerm_storage_account.taskboardstorage.name
    container_name       = azurerm_storage_container.taskboardstoragecontainer.name
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "1b3a85f2-9578-4620-bfe9-300fe840cfc7"
  features {}
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "taskboardrg" {
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_group_location
}

resource "azurerm_storage_account" "taskboardstorage" {
  name                     = "taskboardstorage${random_integer.ri.result}"
  resource_group_name      = azurerm_resource_group.taskboardrg.name
  location                 = azurerm_resource_group.taskboardrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "taskboardstoragecontainer" {
  name                  = "taskboardstoragecontainer"
  storage_account_id    = azurerm_storage_account.taskboardstorage.id
  container_access_type = "private"
}

resource "azurerm_service_plan" "taskboardsp" {
  name                = "${var.app_service_plan_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.taskboardrg.name
  location            = azurerm_resource_group.taskboardrg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "taskboardlwa" {
  name                = "${var.app_service_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.taskboardrg.name
  location            = azurerm_resource_group.taskboardrg.location
  service_plan_id     = azurerm_service_plan.taskboardsp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }

    always_on = false
  }
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sqlserverkn.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.taskboarddb.name};User ID=${azurerm_mssql_server.sqlserverkn.administrator_login};Password=${azurerm_mssql_server.sqlserverkn.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_mssql_server" "sqlserverkn" {
  name                         = "${var.sql_server_name}${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.taskboardrg.name
  location                     = azurerm_resource_group.taskboardrg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "taskboarddb" {
  name           = "${var.sql_database_name}${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.sqlserverkn.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 2
  sku_name       = "S0"
  zone_redundant = false
}

resource "azurerm_mssql_firewall_rule" "sqlserverfr" {
  name             = "${var.firewall_rule_name}${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.sqlserverkn.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "taskboardassc" {
  app_id                 = azurerm_linux_web_app.taskboardlwa.id
  repo_url               = var.repo_url
  branch                 = var.branch_name
  use_manual_integration = true
}

