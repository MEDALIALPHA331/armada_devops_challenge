variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs for Subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs for Public Subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for Private Subnets"
  type        = list(string)
}


variable "lab_listening_port" {
  description = "the Port where the app is running"
  type        = number
  default     = 8000
}