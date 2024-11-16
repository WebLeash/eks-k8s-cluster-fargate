variable "rds_master_username_staging" {
  description = "The username for the RDS database"
  type        = string
}

variable "rds_master_password_staging" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_username_staging" {
  description = "Username for the staging database"
  type        = string
}

variable "db_password_staging" {
  description = "Password for the staging database"
  type        = string
}

variable "db_username_prod" {
  description = "Username for the production database"
  type        = string
}

variable "db_password_prod" {
  description = "Password for the production database"
  type        = string
}

variable "rds_password_master_prod" {
  description = "Master Password for the production database"
  type        = string
}

variable "rds_username_master_prod" {
  description = "Master Username for the production database"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "me-central-1"  # Or any region you want to use as default
}

