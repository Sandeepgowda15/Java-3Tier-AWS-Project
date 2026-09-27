variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for AWS resource naming"
  type        = string
  default     = "java-3tier-app"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
  default     = "192.168.0.0/16"
}
variable "availability_zone_a" {
  description = "First Availability Zone"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_b" {
  description = "Second Availability Zone"
  type        = string
  default     = "us-east-1b"
}

variable "database_name" {
  description = "Name of the application database"
  type        = string
  default     = "java_login_db"
}

variable "database_username" {
  description = "RDS database username"
  type        = string
  default     = "javaapp"
}
