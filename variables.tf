variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the app service plan"
  type        = string
}

variable "app_service_name" {
  description = "The name of the app service"
  type        = string
}

variable "sql_server_name" {
  description = "The name of the SQL server"
  type        = string
}

variable "sql_database_name" {
  description = "The name of the SQL database"
  type        = string
}

variable "sql_admin_login" {
  description = "The SQL admin login"
  type        = string
}

variable "sql_admin_password" {
  description = "The SQL admin password"
  type        = string
}

variable "firewall_rule_name" {
  description = "The name of the SQL firewall rule"
  type        = string
}

variable "repo_url" {
  description = "The URL of the repository"
  type        = string
}

variable "branch_name" {
  description = "The name of the branch"
  type        = string
}