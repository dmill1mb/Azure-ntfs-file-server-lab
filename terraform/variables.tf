variable "resource_group_name" {
  description = "Resource group that holds every resource in this lab"
  type        = string
  default     = "RG-FileServerLab"
}

variable "location" {
  description = "Azure region to deploy into"
  type        = string
  default     = "centralus"
}

variable "admin_username" {
  description = "Local admin username for every VM in the lab"
  type        = string
  default     = "labadmin"
}

variable "admin_password" {
  description = "Local admin password for every VM. Set via $env:TF_VAR_admin_password — never typed into a file."
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Active Directory domain promoted on DC01"
  type        = string
  default     = "lab.local"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "dc01_private_ip" {
  description = "Static private IP reserved for DC01, so DNS never breaks after a reboot"
  type        = string
  default     = "10.0.1.4"
}

variable "allowed_rdp_source_ip" {
  description = "The one public IP the NSG allows through on port 3389 — no default, must be supplied"
  type        = string
}

variable "server_vm_size" {
  description = "DC01 / FS01 size. Must support Gen2 boot"
  type        = string
  default     = "Standard_D2_v4"
}

variable "client_vm_size" {
  type    = string
  default = "Standard_D2_v4"
}

variable "client_image_sku" {
  description = "Windows 11 Pro Marketplace SKU — verify with az vm image list-skus first, retired SKUs 404 without warning"
  type        = string
  default     = "win11-24h2-pro"
}

variable "key_vault_name" {
  description = "Must be globally unique across all of Azure, not just this subscription"
  type        = string
}
