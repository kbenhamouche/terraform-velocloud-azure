// Azure variables
variable "azure_region" {
  description = "Enter your region (example: canadacentral for Canada Central)"
  default = "canadacentral"
}

variable "vnet_cidr_block" {
  description = "Enter the VNET subnet (example: 172.17.0.0/16)"
  default = "172.17.0.0/16"
}

variable "public_sn_cidr_block" {
  description = "Enter the public subnet (example: 172.17.0.0/24)"
  default = "172.17.0.0/24"
}

variable "private_sn_cidr_block" {
  description = "Enter the private subnet (example: 172.17.100.0/24)"
  default = "172.17.100.0/24"
}

variable "private_ip" {
  description = "Enter the private IP for the LAN interface (example: 172.17.100.5)"
  default = "172.17.100.100"
}

variable "public_ip" {
  description = "Enter the public IP for the WAN interface (example: 172.17.0.5)"
  default = "172.17.0.5"
}

variable "instance_type" {
  description = "Enter the instance type (example: Standard_D3_v2)"
  default = "Standard_D3_v2"
}

variable "vce_username" {
  description = "Enter the username for ssh access"
  default = "vce"
}

variable "vce_password" {
  description = "Enter the password for the ssh access"
  default = "VeloCloud123"
}

