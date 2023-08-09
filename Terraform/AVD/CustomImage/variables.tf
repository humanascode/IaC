variable "resource_group_location" {
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "rg_name" {
  type        = string
  default     = "rg-avd-resources"
  description = "Name of the Resource group in which to deploy service objects"
}

variable "workspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop workspace"
  default     = "AVD TF Workspace"
}

variable "hostpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop host pool"
  default     = "AVD-TF-HP"
}


variable "prefix" {
  type        = string
  default     = "avdtfcus"
  description = "Prefix of the name of the AVD machine(s)"
}


### host creation varaibles ###

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
  default     = 2
}

variable "vm_size" {
  description = "Size of the machine to deploy"
  default     = "Standard_DS2_v2"
}

variable "local_admin_username" {
  type        = string
  default     = "localadm"
  description = "local admin username"
}

variable "local_admin_password" {
  type        = string
  default     = "ChangeMe123!"
  description = "local admin password"
  sensitive   = true
}


###networkCreation ###

variable "vnet_range" {
  type        = list(string)
  default     = ["10.2.0.0/16"]
  description = "Address range for deployment VNet"
}

variable "subnet_range" {
  type        = list(string)
  default     = ["10.2.0.0/24"]
  description = "Address range for session host subnet"
}

variable "source_image_id" {
  type        = string
  description = "The ID of the source image to use to create the virtual machine."
}