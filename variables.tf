# Variable definitions

variable "environment" {
  description = "Environment name"
  default = "sandbox"
}

variable "name" {
  description = "App name"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-2"
}
