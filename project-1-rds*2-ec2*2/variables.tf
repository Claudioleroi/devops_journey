variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "172.16.0.0/16"
}

variable "public_subnet_cidr_a" {
  description = "CIDR block for public subnet in AZ 1"
  default     = "172.16.1.0/24"
}

variable "public_subnet_cidr_b" {
  description = "CIDR block for public subnet in AZ 2"
  default     = "172.16.2.0/24"
}

variable "private_subnet_cidr_a" {
  description = "CIDR block for private subnet in AZ 1"
  default     = "172.16.3.0/24"
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for private subnet in AZ 2"
  default     = "172.16.4.0/24"
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  default     = "ValidPassword123"
  }
